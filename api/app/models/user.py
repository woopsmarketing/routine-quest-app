# 👤 사용자 모델
# PRD 데이터 모델: users(id, tier, tz, pbt_time, streak, grace_tokens, created_at)
# 사용자 기본 정보, 구독 티어, 스트릭, 보호권 등을 관리

from sqlalchemy import Column, Integer, String, DateTime, Boolean, Time
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum

from app.core.database import Base


class UserTier(str, Enum):
    """사용자 구독 티어"""

    FREE = "free"  # 무료 - 루틴 1개, 5스텝, 광고 있음
    BASIC = "basic"  # 베이직 - 광고 제거, 무제한 루틴/스텝
    PRO = "pro"  # 프로 - 길드, 시즌 풀보상, 고급 통계
    TEAM = "team"  # 팀 - 팀 보드/리포트


class User(Base):
    """사용자 테이블"""

    __tablename__ = "users"

    # 🆔 기본 필드
    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(
        String, unique=True, index=True, nullable=True
    )  # Firebase Auth UID (개발용으로 nullable)
    email = Column(String, unique=True, index=True, nullable=False)
    username = Column(String, unique=True, index=True, nullable=True)  # 개발용 사용자명
    full_name = Column(String, nullable=True)  # 개발용 전체 이름
    display_name = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)

    # 💰 구독 및 티어
    tier = Column(String, default=UserTier.FREE, nullable=False)

    # 🕐 시간대 및 개인화
    timezone = Column(String, default="Asia/Seoul", nullable=False)  # tz
    pbt_time = Column(Time, nullable=True)  # 퍼스널 부스트 타임

    # 🔥 스트릭 관련
    streak = Column(Integer, default=0, nullable=False)  # 연속일수
    grace_tokens = Column(Integer, default=1, nullable=False)  # 주간 보호권
    last_activity_date = Column(DateTime, nullable=True)  # 마지막 활동일

    # ⚙️ 앱 설정
    is_active = Column(Boolean, default=True, nullable=False)
    push_enabled = Column(Boolean, default=True, nullable=False)
    language = Column(String, default="ko", nullable=False)

    # 📊 통계 (캐시된 값들)
    total_xp = Column(Integer, default=0, nullable=False)
    completed_chains = Column(Integer, default=0, nullable=False)
    total_steps_done = Column(Integer, default=0, nullable=False)

    # 📅 타임스탬프
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    last_login_at = Column(DateTime, nullable=True)

    # 🔗 관계 설정
    routines = relationship(
        "Routine", back_populates="user", cascade="all, delete-orphan"
    )

    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, tier={self.tier})>"
