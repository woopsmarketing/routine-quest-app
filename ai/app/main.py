# 🤖 AI 마이크로서비스 메인 애플리케이션
# 루틴 퀘스트의 AI 코치 기능을 담당하는 분리된 서비스
# PRD 요구사항: 짧은 팁(200-300자), 월 n회 제한, 캐싱, 배치 생성

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

from app.core.config import settings
from app.services.coach_service import CoachService
from app.core.auth import verify_token

# Sentry 초기화
if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        integrations=[FastApiIntegration()],
        environment=settings.ENVIRONMENT,
    )

# 🤖 AI 서비스 앱 인스턴스
app = FastAPI(
    title="Routine Quest AI Service",
    description="AI 코치 마이크로서비스 - 개인화된 루틴 팁 생성",
    version="1.0.0",
    docs_url="/docs" if settings.ENVIRONMENT == "development" else None,
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 내부 서비스간 통신
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 📋 코치 서비스 인스턴스
coach_service = CoachService()

@app.get("/health")
async def health_check():
    """AI 서비스 헬스체크"""
    return {"status": "healthy", "service": "ai"}

@app.post("/coach/tip")
async def generate_tip(
    user_id: int,
    routine_data: dict,
    user_stats: dict,
    user_token: dict = Depends(verify_token)
):
    """
    🎯 AI 코치 팁 생성
    
    PRD 요구사항:
    - 200-300자 짧은 팁
    - 구독 크레딧 차감
    - Redis 캐싱
    - 개인화된 조언
    """
    try:
        # 캐시 확인
        cached_tip = await coach_service.get_cached_tip(user_id, routine_data)
        if cached_tip:
            return {"tip": cached_tip, "source": "cache"}
        
        # 새로운 팁 생성
        tip = await coach_service.generate_personalized_tip(
            user_id=user_id,
            routine_data=routine_data,
            user_stats=user_stats
        )
        
        # 캐시 저장
        await coach_service.cache_tip(user_id, routine_data, tip)
        
        return {"tip": tip, "source": "generated"}
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"팁 생성 중 오류가 발생했습니다: {str(e)}"
        )

@app.post("/coach/batch-generate")
async def batch_generate_tips(
    batch_request: dict,
    admin_token: dict = Depends(verify_token)  # 관리자 전용
):
    """
    📦 배치 팁 생성 (Celery 작업용)
    
    대량의 사용자를 위한 팁을 미리 생성하여
    응답 속도를 개선하고 API 비용을 절약
    """
    try:
        result = await coach_service.batch_generate_tips(batch_request)
        return {"status": "success", "generated_count": result}
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"배치 생성 중 오류: {str(e)}"
        )

@app.get("/coach/usage/{user_id}")
async def get_usage_stats(
    user_id: int,
    user_token: dict = Depends(verify_token)
):
    """
    📊 사용자별 AI 코치 이용 현황
    
    월 사용 횟수, 남은 크레딧 등을 반환
    """
    try:
        usage = await coach_service.get_user_usage(user_id)
        return usage
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"사용 현황 조회 오류: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8001,  # 메인 API와 다른 포트
        reload=True if settings.ENVIRONMENT == "development" else False,
    )