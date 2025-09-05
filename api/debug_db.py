# 🔍 데이터베이스 상태 디버깅 스크립트
from app.core.database import engine, SessionLocal
from app.models.routine import Routine
from app.models.user import User
from app.models import Base


def check_database():
    """데이터베이스 상태 확인 및 초기화"""
    try:
        # 테이블 생성
        print("📊 데이터베이스 테이블 생성 중...")
        Base.metadata.create_all(bind=engine)
        print("✅ 테이블 생성 완료!")

        # 세션 생성
        db = SessionLocal()

        # 사용자 확인
        user_count = db.query(User).count()
        print(f"👤 사용자 수: {user_count}")

        # 루틴 확인
        routine_count = db.query(Routine).count()
        print(f"📋 루틴 수: {routine_count}")

        if user_count == 0:
            print("🔧 더미 사용자 생성 중...")
            user = User(
                email="demo@routinequest.com",
                username="demo_user",
                full_name="데모 사용자",
                is_active=True,
            )
            db.add(user)
            db.commit()
            print("✅ 더미 사용자 생성 완료!")

        # 루틴 목록 출력
        if routine_count > 0:
            print("\n📋 현재 루틴 목록:")
            routines = db.query(Routine).all()
            for routine in routines:
                print(
                    f"- ID: {routine.id}, 제목: {routine.title}, 활성화: {routine.is_active}"
                )
                print(f"  스텝 수: {len(routine.steps)}")

        db.close()

    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback

        traceback.print_exc()


if __name__ == "__main__":
    check_database()
