# 🚀 API v1 라우터 통합
# 모든 API 엔드포인트를 통합하는 메인 라우터
from fastapi import APIRouter

from app.api.api_v1.endpoints import routines

api_router = APIRouter()

# 📋 루틴 관련 엔드포인트
api_router.include_router(routines.router, prefix="/routines", tags=["routines"])
