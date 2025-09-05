# 🗄️ 데이터베이스 연결 설정
# SQLAlchemy를 사용한 PostgreSQL 데이터베이스 연결 관리
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.core.config import settings

# 📊 데이터베이스 엔진 생성
# 개발 환경에서는 SQLite 사용 (PostgreSQL 설정 전까지)
if settings.ENVIRONMENT == "development":
    # SQLite 개발용 설정
    SQLALCHEMY_DATABASE_URL = "sqlite:///./routine_quest.db"
    engine = create_engine(
        SQLALCHEMY_DATABASE_URL,
        connect_args={"check_same_thread": False},  # SQLite 전용
        poolclass=StaticPool,
    )
else:
    # PostgreSQL 프로덕션 설정
    SQLALCHEMY_DATABASE_URL = (
        f"postgresql://{settings.POSTGRES_USER}:{settings.POSTGRES_PASSWORD}"
        f"@{settings.POSTGRES_SERVER}:{settings.POSTGRES_PORT}/{settings.POSTGRES_DB}"
    )
    engine = create_engine(SQLALCHEMY_DATABASE_URL)

# 🔧 세션 팩토리 생성
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 📋 베이스 모델 클래스
Base = declarative_base()


# 🔌 데이터베이스 세션 의존성
def get_db():
    """데이터베이스 세션을 제공하는 의존성 함수"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
