# 📊 데이터베이스 모델 패키지
# 모든 SQLAlchemy 모델들을 여기서 임포트하여 중앙 관리
# Alembic 마이그레이션이 모든 모델을 인식할 수 있도록 함

from app.core.database import Base

# 🧑‍💼 사용자 관련 모델
from .user import User

# 📋 루틴 관련 모델  
from .routine import Routine, Step

# 📊 세션 및 체크인 모델
from .session import Session, Checkin

# 🎁 보상 및 시즌 패스 모델
from .reward import Reward, SeasonPass, SeasonReward

# 👥 길드 관련 모델
from .guild import Guild, GuildMember

# 💳 구독 관련 모델
from .subscription import Subscription

# 📈 통계 모델
from .stats import DailyStats

# 모든 모델 리스트 (Alembic이 자동으로 인식)
__all__ = [
    "Base",
    "User", 
    "Routine",
    "Step",
    "Session",
    "Checkin", 
    "Reward",
    "SeasonPass",
    "SeasonReward",
    "Guild",
    "GuildMember",
    "Subscription",
    "DailyStats",
]