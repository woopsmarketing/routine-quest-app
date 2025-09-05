# 🔍 루틴 상세 정보 디버깅 (색상, 아이콘 포함)
import requests
import json


def debug_routine_detail():
    """API에서 루틴 상세 데이터 확인"""
    try:
        response = requests.get("http://localhost:8000/api/v1/routines/")
        routines = response.json()

        print("=== 루틴 상세 정보 ===")
        for routine in routines[:3]:  # 첫 3개만 확인
            print(f'\n루틴 ID: {routine["id"]}')
            print(f'제목: {routine["title"]}')
            print(
                f'색상: {routine.get("color", "없음")} (타입: {type(routine.get("color"))})'
            )
            print(f'아이콘: {routine.get("icon", "없음")}')
            print(f'활성화: {routine["is_active"]}')

            # 전체 데이터 구조 확인
            print("전체 필드:")
            for key, value in routine.items():
                if key not in ["steps"]:  # 스텝은 너무 길어서 제외
                    print(f"  {key}: {value} ({type(value).__name__})")
            print("---")

    except Exception as e:
        print(f"오류 발생: {e}")


if __name__ == "__main__":
    debug_routine_detail()
