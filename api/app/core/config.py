# ⚙️ 애플리케이션 설정 관리
# 환경변수 기반 설정, 데이터베이스 URL, API 키 등을 관리
# Pydantic Settings를 사용해 타입 안전성과 검증 제공

from typing import List, Optional
from pydantic import Field, validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """애플리케이션 전역 설정"""

    # 🏷️ 기본 앱 정보
    PROJECT_NAME: str = "Routine Quest API"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = Field(default="development", env="ENVIRONMENT")

    # 🌐 API 설정
    API_V1_STR: str = "/api/v1"
    ALLOWED_HOSTS: List[str] = ["localhost", "127.0.0.1", "0.0.0.0"]
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",  # Flutter Web 개발 서버
        "http://localhost:8080",  # 대안 개발 서버
    ]

    # 🗄️ 데이터베이스 설정
    POSTGRES_SERVER: str = Field(env="POSTGRES_SERVER")
    POSTGRES_USER: str = Field(env="POSTGRES_USER")
    POSTGRES_PASSWORD: str = Field(env="POSTGRES_PASSWORD")
    POSTGRES_DB: str = Field(env="POSTGRES_DB")
    POSTGRES_PORT: int = Field(default=5432, env="POSTGRES_PORT")

    @property
    def DATABASE_URL(self) -> str:
        """PostgreSQL 연결 URL 생성"""
        return (
            f"postgresql+asyncpg://{self.POSTGRES_USER}:"
            f"{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:"
            f"{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    # 🔄 Redis 설정 (캐시/큐용)
    REDIS_URL: str = Field(default="redis://localhost:6379", env="REDIS_URL")

    # 🔐 보안 설정
    SECRET_KEY: str = Field(env="SECRET_KEY")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8  # 8일
    ALGORITHM: str = "HS256"

    # 🔥 Firebase 설정 (개발용으로 선택적)
    FIREBASE_PROJECT_ID: Optional[str] = Field(default=None, env="FIREBASE_PROJECT_ID")
    FIREBASE_PRIVATE_KEY: Optional[str] = Field(
        default=None, env="FIREBASE_PRIVATE_KEY"
    )
    FIREBASE_CLIENT_EMAIL: Optional[str] = Field(
        default=None, env="FIREBASE_CLIENT_EMAIL"
    )

    # 📊 모니터링
    SENTRY_DSN: Optional[str] = Field(default=None, env="SENTRY_DSN")

    # 📧 이메일 설정 (나중에 필요시)
    SMTP_TLS: bool = Field(default=True, env="SMTP_TLS")
    SMTP_PORT: Optional[int] = Field(default=None, env="SMTP_PORT")
    SMTP_HOST: Optional[str] = Field(default=None, env="SMTP_HOST")
    SMTP_USER: Optional[str] = Field(default=None, env="SMTP_USER")
    SMTP_PASSWORD: Optional[str] = Field(default=None, env="SMTP_PASSWORD")

    # 🤖 AI 서비스 설정
    AI_SERVICE_URL: str = Field(default="http://localhost:8001", env="AI_SERVICE_URL")

    @validator("CORS_ORIGINS", pre=True)
    def assemble_cors_origins(cls, v):
        """CORS Origins 문자열을 리스트로 변환"""
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    class Config:
        # 환경변수 파일 경로
        env_file = ".env"
        case_sensitive = True


# 전역 설정 인스턴스
settings = Settings()
