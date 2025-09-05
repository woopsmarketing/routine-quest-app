# 🎯 다중 스텝 루틴 생성 스크립트
import requests
import json


def create_multi_step_routine():
    """여러 스텝이 있는 테스트 루틴 생성"""

    routine_data = {
        "title": "완전한 아침 루틴",
        "description": "건강한 하루를 시작하는 완벽한 아침 루틴",
        "icon": "🌅",
        "color": "blue",
        "steps": [
            {
                "title": "물 한 잔 마시기",
                "description": "미지근한 물 200ml를 천천히 마셔보세요. 몸이 깨어나는 것을 느낄 수 있어요.",
                "type": "action",
                "t_ref_sec": 120,
                "order": 1,
            },
            {
                "title": "창문 열고 심호흡",
                "description": "창문을 열고 신선한 공기를 마시며 깊게 5번 심호흡해보세요.",
                "type": "action",
                "t_ref_sec": 180,
                "order": 2,
            },
            {
                "title": "간단한 스트레칭",
                "description": "목, 어깨, 허리를 가볍게 풀어주며 몸을 깨워보세요.",
                "type": "timer",
                "t_ref_sec": 300,
                "order": 3,
            },
            {
                "title": "오늘의 목표 3가지 적기",
                "description": "오늘 꼭 해야 할 중요한 일 3가지를 메모장에 적어보세요.",
                "type": "action",
                "t_ref_sec": 240,
                "order": 4,
            },
            {
                "title": "감사 인사하기",
                "description": "오늘도 건강하게 하루를 시작할 수 있음에 감사 인사를 해보세요.",
                "type": "check",
                "t_ref_sec": 60,
                "order": 5,
            },
        ],
    }

    try:
        response = requests.post(
            "http://localhost:8000/api/v1/routines/",
            json=routine_data,
            headers={"Content-Type": "application/json; charset=utf-8"},
        )

        if response.status_code == 200:
            result = response.json()
            print(f"✅ 성공! 루틴 생성됨:")
            print(f"ID: {result['id']}")
            print(f"제목: {result['title']}")
            print(f"스텝 개수: {len(result['steps'])}개")
            print("\n스텝 목록:")
            for i, step in enumerate(result["steps"], 1):
                print(f"{i}. {step['title']} ({step['t_ref_sec']}초)")
        else:
            print(f"❌ 오류: {response.status_code}")
            print(response.text)

    except Exception as e:
        print(f"오류 발생: {e}")


if __name__ == "__main__":
    create_multi_step_routine()
