# 📋 루틴 관리 API 엔드포인트
# 루틴 CRUD 작업과 스텝 관리를 담당하는 API
from typing import List, Optional
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel

from app.core.database import get_db
from app.models.routine import Routine, Step, StepType, StepDifficulty
from app.models.user import User

router = APIRouter()


# 📝 Pydantic 모델들
class StepCreate(BaseModel):
    """스텝 생성 요청 모델"""

    title: str
    description: Optional[str] = None
    order: Optional[int] = None  # 선택사항으로 변경 (자동 계산)
    type: StepType = StepType.ACTION
    difficulty: StepDifficulty = StepDifficulty.EASY
    t_ref_sec: int = 120
    is_optional: bool = False
    xp_reward: int = 10


class StepResponse(BaseModel):
    """스텝 응답 모델"""

    id: int
    title: str
    description: Optional[str]
    order: int
    type: str
    difficulty: str
    t_ref_sec: int
    is_optional: bool
    xp_reward: int
    completion_count: int
    skip_count: int
    avg_time_spent: int

    class Config:
        from_attributes = True


class RoutineCreate(BaseModel):
    """루틴 생성 요청 모델"""

    title: str
    description: Optional[str] = None
    icon: str = "🎯"
    color: str = "#6366F1"
    is_public: bool = False
    steps: List[StepCreate] = []


class RoutineUpdate(BaseModel):
    """루틴 수정 요청 모델"""

    title: Optional[str] = None
    description: Optional[str] = None
    icon: Optional[str] = None
    color: Optional[str] = None
    is_public: Optional[bool] = None
    is_active: Optional[bool] = None


class RoutineResponse(BaseModel):
    """루틴 응답 모델"""

    id: int
    title: str
    description: Optional[str]
    icon: str
    color: str
    is_public: bool
    is_active: bool
    today_display: bool
    version: int
    total_completions: int
    success_rate: int
    avg_completion_time: int
    created_at: datetime
    updated_at: datetime
    steps: List[StepResponse] = []

    class Config:
        from_attributes = True


# 🔍 현재 사용자 가져오기 (실제 인증 구현 필요)
def get_current_user(db: Session = Depends(get_db)) -> User:
    """현재 사용자 가져오기"""
    # TODO: 실제 JWT 토큰에서 사용자 정보를 가져와야 함
    # 임시로 첫 번째 사용자를 반환 (실제 구현에서는 인증 토큰에서 사용자 ID 추출)
    user = db.query(User).first()
    if not user:
        raise HTTPException(status_code=401, detail="인증이 필요합니다")
    return user


# 📋 루틴 목록 조회
@router.get("/", response_model=List[RoutineResponse])
async def get_routines(
    skip: int = 0,
    limit: int = 100,
    is_active: Optional[bool] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """사용자의 루틴 목록 조회"""
    query = db.query(Routine).filter(Routine.user_id == current_user.id)

    if is_active is not None:
        query = query.filter(Routine.is_active == is_active)

    routines = query.offset(skip).limit(limit).all()
    return routines


# 📋 루틴 상세 조회
@router.get("/{routine_id}", response_model=RoutineResponse)
async def get_routine(
    routine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """특정 루틴 상세 조회"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="루틴을 찾을 수 없습니다"
        )

    return routine


# ➕ 새 루틴 생성
@router.post("/", response_model=RoutineResponse)
async def create_routine(
    routine_data: RoutineCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """새 루틴 생성"""
    # 루틴 생성
    routine = Routine(
        user_id=current_user.id,
        title=routine_data.title,
        description=routine_data.description,
        icon=routine_data.icon,
        color=routine_data.color,
        is_public=routine_data.is_public,
        is_active=True,
    )

    db.add(routine)
    db.commit()
    db.refresh(routine)

    # 스텝들 생성
    for step_data in routine_data.steps:
        step = Step(
            routine_id=routine.id,
            title=step_data.title,
            description=step_data.description,
            order=step_data.order,
            type=step_data.type,
            difficulty=step_data.difficulty,
            t_ref_sec=step_data.t_ref_sec,
            is_optional=step_data.is_optional,
            xp_reward=step_data.xp_reward,
        )
        db.add(step)

    db.commit()
    db.refresh(routine)

    return routine


# ✏️ 루틴 수정
@router.put("/{routine_id}", response_model=RoutineResponse)
async def update_routine(
    routine_id: int,
    routine_data: RoutineUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴 정보 수정"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="루틴을 찾을 수 없습니다"
        )

    # 업데이트할 필드들만 수정
    update_data = routine_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(routine, field, value)

    routine.version += 1  # 버전 증가

    db.commit()
    db.refresh(routine)

    return routine


# 🗑️ 루틴 삭제
@router.delete("/{routine_id}")
async def delete_routine(
    routine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴 삭제"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="루틴을 찾을 수 없습니다"
        )

    db.delete(routine)
    db.commit()

    return {"message": "루틴이 삭제되었습니다"}


# 🔄 루틴 활성화/비활성화
@router.patch("/{routine_id}/toggle")
async def toggle_routine(
    routine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴 활성화/비활성화 토글"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="루틴을 찾을 수 없습니다"
        )

    routine.is_active = not routine.is_active
    routine.version += 1

    db.commit()
    db.refresh(routine)

    return {
        "message": f"루틴이 {'활성화' if routine.is_active else '비활성화'}되었습니다",
        "is_active": routine.is_active,
    }


# 📊 루틴 통계 조회
@router.get("/{routine_id}/stats")
async def get_routine_stats(
    routine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴 통계 조회"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="루틴을 찾을 수 없습니다"
        )

    return {
        "routine_id": routine.id,
        "title": routine.title,
        "total_completions": routine.total_completions,
        "success_rate": routine.success_rate,
        "avg_completion_time": routine.avg_completion_time,
        "total_steps": len(routine.steps),
        "created_at": routine.created_at,
        "last_completed": None,  # TODO: 실제 완료 기록에서 가져오기
    }


# 🎯 오늘 페이지 표시 토글
@router.patch("/{routine_id}/today-display")
async def toggle_today_display(
    routine_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴 오늘 페이지 표시 토글"""
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(status_code=404, detail="루틴을 찾을 수 없습니다")

    # 🎯 현재 루틴의 today_display 토글 (여러 루틴 동시 표시 가능)
    routine.today_display = not routine.today_display
    routine.updated_at = datetime.now()
    db.commit()
    db.refresh(routine)

    return {
        "message": f"루틴이 오늘 페이지에 {'표시' if routine.today_display else '숨김'}됩니다",
        "today_display": routine.today_display,
    }


# ➕ 루틴에 스텝 추가
@router.post("/{routine_id}/steps", response_model=StepResponse)
async def add_step_to_routine(
    routine_id: int,
    step_data: StepCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """루틴에 새 스텝 추가"""
    # 루틴 존재 및 권한 확인
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(status_code=404, detail="루틴을 찾을 수 없습니다")

    # 순서 결정 (제공된 값이 있으면 사용, 없으면 자동 계산)
    if step_data.order is not None:
        order = step_data.order
    else:
        # 다음 순서 자동 계산 (기존 스텝들 중 가장 큰 order + 1)
        max_order = (
            db.query(Step.order)
            .filter(Step.routine_id == routine_id)
            .order_by(Step.order.desc())
            .first()
        )
        order = (max_order[0] if max_order else 0) + 1

    # 스텝 생성
    step = Step(
        routine_id=routine_id,
        title=step_data.title,
        description=step_data.description,
        order=order,  # 결정된 순서 사용
        type=step_data.type,
        difficulty=step_data.difficulty,
        t_ref_sec=step_data.t_ref_sec,
        is_optional=step_data.is_optional,
        xp_reward=step_data.xp_reward,
    )

    db.add(step)
    db.commit()
    db.refresh(step)

    return step


# ✏️ 스텝 수정
@router.put("/{routine_id}/steps/{step_id}", response_model=StepResponse)
async def update_step(
    routine_id: int,
    step_id: int,
    step_data: StepCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """스텝 정보 수정"""
    # 루틴 권한 확인
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(status_code=404, detail="루틴을 찾을 수 없습니다")

    # 스텝 존재 확인
    step = (
        db.query(Step).filter(Step.id == step_id, Step.routine_id == routine_id).first()
    )

    if not step:
        raise HTTPException(status_code=404, detail="스텝을 찾을 수 없습니다")

    # 스텝 정보 업데이트
    step.title = step_data.title
    step.description = step_data.description
    step.type = step_data.type
    step.difficulty = step_data.difficulty
    step.t_ref_sec = step_data.t_ref_sec
    step.is_optional = step_data.is_optional
    step.xp_reward = step_data.xp_reward

    db.commit()
    db.refresh(step)

    return step


# 🗑️ 스텝 삭제
@router.delete("/{routine_id}/steps/{step_id}")
async def delete_step(
    routine_id: int,
    step_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """스텝 삭제"""
    # 루틴 권한 확인
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(status_code=404, detail="루틴을 찾을 수 없습니다")

    # 스텝 존재 확인
    step = (
        db.query(Step).filter(Step.id == step_id, Step.routine_id == routine_id).first()
    )

    if not step:
        raise HTTPException(status_code=404, detail="스텝을 찾을 수 없습니다")

    db.delete(step)
    db.commit()

    return {"message": "스텝이 삭제되었습니다"}


# 🔄 스텝 순서 변경
@router.patch("/{routine_id}/steps/{step_id}/reorder")
async def reorder_step(
    routine_id: int,
    step_id: int,
    new_order: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """스텝 순서 변경"""
    # 루틴 권한 확인
    routine = (
        db.query(Routine)
        .filter(Routine.id == routine_id, Routine.user_id == current_user.id)
        .first()
    )

    if not routine:
        raise HTTPException(status_code=404, detail="루틴을 찾을 수 없습니다")

    # 스텝 존재 확인
    step = (
        db.query(Step).filter(Step.id == step_id, Step.routine_id == routine_id).first()
    )

    if not step:
        raise HTTPException(status_code=404, detail="스텝을 찾을 수 없습니다")

    old_order = step.order

    # 순서 재정렬 로직
    if new_order > old_order:
        # 아래로 이동: old_order < order <= new_order 인 스텝들을 -1
        db.query(Step).filter(
            Step.routine_id == routine_id,
            Step.order > old_order,
            Step.order <= new_order,
        ).update({Step.order: Step.order - 1})
    else:
        # 위로 이동: new_order <= order < old_order 인 스텝들을 +1
        db.query(Step).filter(
            Step.routine_id == routine_id,
            Step.order >= new_order,
            Step.order < old_order,
        ).update({Step.order: Step.order + 1})

    # 해당 스텝의 순서 변경
    step.order = new_order
    db.commit()

    return {"message": "스텝 순서가 변경되었습니다", "new_order": new_order}
