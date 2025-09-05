# 🔍 루틴 데이터 디버깅 스크립트
import requests
import json


def debug_routines():
    """API에서 루틴 데이터를 가져와서 상세히 분석"""
    try:
        response = requests.get("http://localhost:8000/api/v1/routines/")
        routines = response.json()

        print("=== 전체 루틴 목록 ===")
        for routine in routines:
            print(f'ID: {routine["id"]}')
            print(f'제목: {routine["title"]}')
            print(f'활성화: {routine["is_active"]}')
            print(f'스텝 개수: {len(routine.get("steps", []))}')

            if routine.get("steps"):
                print("스텝 목록:")
                for i, step in enumerate(routine["steps"]):
                    print(
                        f'  {i+1}. {step.get("title", "제목없음")} ({step.get("type", "타입없음")})'
                    )
            else:
                print("스텝 없음")
            print("---")

        active_routines = [r for r in routines if r["is_active"]]
        print(f"\n📊 요약:")
        print(f"총 루틴 개수: {len(routines)}개")
        print(f"활성화된 루틴: {len(active_routines)}개")

        if active_routines:
            print("\n✅ 활성화된 루틴들:")
            for routine in active_routines:
                print(f'- {routine["title"]} ({len(routine.get("steps", []))}개 스텝)')
        else:
            print("\n❌ 활성화된 루틴이 없습니다!")

    except Exception as e:
        print(f"오류 발생: {e}")


if __name__ == "__main__":
    debug_routines()
