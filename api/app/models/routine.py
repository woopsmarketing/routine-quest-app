# 📋 루틴 및 스텝 모델
# PRD 데이터 모델: routines(id, user_id, title, is_public, version, last_changed_at)
#                  steps(id, routine_id, "order", title, difficulty, t_ref_sec, type)
# 사용자가 만든 루틴과 각 루틴의 스텝들을 관리

from sqlalchemy import Column, Integer, String, DateTime, Boolean, ForeignKey, Text
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from enum import Enum

from app.core.database import Base


class StepType(str, Enum):
    """스텝 타입 분류"""

    ACTION = "action"  # 일반 액션 (물 마시기, 운동하기 등)
    TIMER = "timer"  # 시간 기반 (명상 5분, 독서 30분 등)
    CHECK = "check"  # 체크 확인 (일기 썼는지, 정리했는지 등)
    HABIT = "habit"  # 습관 체크 (양치질, 세수 등)


class StepDifficulty(str, Enum):
    """스텝 난이도"""

    EASY = "easy"  # 쉬움 (30초~2분)
    MEDIUM = "medium"  # 보통 (2분~10분)
    HARD = "hard"  # 어려움 (10분 이상)


class Routine(Base):
    """루틴 테이블 - 사용자가 만든 루틴 목록"""

    __tablename__ = "routines"

    # 🆔 기본 필드
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)

    # 📝 루틴 기본 정보
    title = Column(String(200), nullable=False)  # 루틴 이름
    description = Column(Text, nullable=True)  # 루틴 설명
    icon = Column(String(50), default="🎯", nullable=False)  # 이모지 아이콘
    color = Column(String(7), default="#6366F1", nullable=False)  # 헥스 컬러

    # ⚙️ 루틴 설정
    is_public = Column(Boolean, default=False, nullable=False)  # 공개 여부
    is_active = Column(Boolean, default=True, nullable=False)  # 활성화 여부
    today_display = Column(
        Boolean, default=False, nullable=False
    )  # 오늘 페이지 표시 여부
    version = Column(Integer, default=1, nullable=False)  # 버전 (변경 추적용)

    # 📊 통계 (캐시된 값들)
    total_completions = Column(Integer, default=0, nullable=False)
    success_rate = Column(Integer, default=0, nullable=False)  # 성공률 (0-100)
    avg_completion_time = Column(
        Integer, default=0, nullable=False
    )  # 평균 완료 시간(초)

    # 📅 타임스탬프
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())
    last_changed_at = Column(DateTime, server_default=func.now())  # 마지막 편집 시간

    # 🔗 관계 설정
    user = relationship("User", back_populates="routines")
    steps = relationship(
        "Step",
        back_populates="routine",
        cascade="all, delete-orphan",
        order_by="Step.order",
    )

    def __repr__(self):
        return f"<Routine(id={self.id}, title={self.title}, user_id={self.user_id})>"


class Step(Base):
    """스텝 테이블 - 각 루틴의 개별 단계들"""

    __tablename__ = "steps"

    # 🆔 기본 필드
    id = Column(Integer, primary_key=True, index=True)
    routine_id = Column(Integer, ForeignKey("routines.id"), nullable=False, index=True)

    # 📝 스텝 정보
    order = Column(Integer, nullable=False)  # 순서 (1, 2, 3...)
    title = Column(String(200), nullable=False)  # 스텝 제목
    description = Column(Text, nullable=True)  # 스텝 설명

    # ⚙️ 스텝 설정
    type = Column(String, default=StepType.ACTION, nullable=False)
    difficulty = Column(String, default=StepDifficulty.EASY, nullable=False)
    t_ref_sec = Column(Integer, default=120, nullable=False)  # 예상 소요 시간(초)

    # 🎯 선택적 설정
    is_optional = Column(Boolean, default=False, nullable=False)  # 선택적 스텝
    xp_reward = Column(Integer, default=10, nullable=False)  # XP 보상

    # 📊 통계 (캐시된 값들)
    completion_count = Column(Integer, default=0, nullable=False)
    skip_count = Column(Integer, default=0, nullable=False)
    avg_time_spent = Column(Integer, default=0, nullable=False)  # 실제 평균 소요 시간

    # 📅 타임스탬프
    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # 🔗 관계 설정
    routine = relationship("Routine", back_populates="steps")

    def __repr__(self):
        return f"<Step(id={self.id}, title={self.title}, order={self.order})>"
