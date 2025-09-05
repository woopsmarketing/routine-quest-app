# 🚀 FastAPI 메인 애플리케이션
# 루틴 퀘스트 백엔드 API 서버의 진입점
# 라우터 등록, 미들웨어 설정, 전역 설정을 담당

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

from app.core.config import settings
from app.core.database import engine
from app.models import Base
from app.api.api_v1.api import api_router

# Sentry 에러 모니터링 초기화 (프로덕션용)
if settings.SENTRY_DSN:
    sentry_sdk.init(
        dsn=settings.SENTRY_DSN,
        integrations=[FastApiIntegration()],
        environment=settings.ENVIRONMENT,
    )

# 📱 FastAPI 앱 인스턴스 생성
app = FastAPI(
    title="Routine Quest API",
    description="순서 기반 퀘스트형 루틴 앱 백엔드 API",
    version="1.0.0",
    openapi_url=(
        f"{settings.API_V1_STR}/openapi.json"
        if settings.ENVIRONMENT == "development"
        else None
    ),
    docs_url="/docs" if settings.ENVIRONMENT == "development" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT == "development" else None,
)

# 🔒 보안 미들웨어 설정
app.add_middleware(TrustedHostMiddleware, allowed_hosts=settings.ALLOWED_HOSTS)

# 🌐 CORS 설정 (클라이언트 앱에서 API 접근 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# 🔤 UTF-8 인코딩 미들웨어
@app.middleware("http")
async def add_charset_header(request: Request, call_next):
    """모든 JSON 응답에 UTF-8 charset 추가"""
    response = await call_next(request)
    if response.headers.get("content-type", "").startswith("application/json"):
        response.headers["content-type"] = "application/json; charset=utf-8"
    return response


# 📡 API 라우터 등록
app.include_router(api_router, prefix=settings.API_V1_STR)


# 🏥 헬스체크 엔드포인트
@app.get("/health")
async def health_check():
    """서버 상태 확인용 엔드포인트"""
    return {"status": "healthy", "version": "1.0.0"}


# 🚨 글로벌 예외 핸들러
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """예기치 못한 에러에 대한 글로벌 핸들러"""
    return JSONResponse(
        status_code=500,
        content={
            "detail": "Internal server error",
            "path": str(request.url),
        },
    )


# 🏁 앱 시작 이벤트
@app.on_event("startup")
async def startup_event():
    """서버 시작 시 실행되는 초기화 작업"""
    # 데이터베이스 테이블 생성 (개발용 - 프로덕션에서는 Alembic 사용)
    if settings.ENVIRONMENT == "development":
        Base.metadata.create_all(bind=engine)


# 🛑 앱 종료 이벤트
@app.on_event("shutdown")
async def shutdown_event():
    """서버 종료 시 정리 작업"""
    pass


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True if settings.ENVIRONMENT == "development" else False,
    )
