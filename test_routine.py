#!/usr/bin/env python3
# 루틴 생성 테스트 스크립트

import requests
import json


def test_routine_creation():
    """루틴 생성 테스트"""

    # 테스트 데이터
    data = {
        "title": "모닝 루틴",
        "description": "아침에 하는 건강한 루틴",
        "icon": "🌅",
        "color": "#6366F1",
        "is_public": False,
        "steps": [
            {
                "title": "물 마시기",
                "description": "따뜻한 물 한 잔 마시기",
                "order": 1,
                "type": "action",
                "difficulty": "easy",
                "t_ref_sec": 60,
                "is_optional": False,
                "xp_reward": 10,
            }
        ],
    }

    # API 호출
    try:
        response = requests.post("http://localhost:8000/api/v1/routines/", json=data)
        print(f"Status Code: {response.status_code}")

        if response.status_code == 201:
            print("✅ 루틴 생성 성공!")
            print(f"Response: {response.json()}")
        else:
            print("❌ 루틴 생성 실패")
            print(f"Error: {response.text}")

    except Exception as e:
        print(f"❌ 요청 실패: {e}")


def test_get_routines():
    """루틴 목록 조회 테스트"""
    try:
        response = requests.get("http://localhost:8000/api/v1/routines/")
        print(f"\n--- 루틴 목록 조회 ---")
        print(f"Status Code: {response.status_code}")

        if response.status_code == 200:
            print("✅ 루틴 목록 조회 성공!")
            routines = response.json()
            print(f"루틴 개수: {len(routines)}")
            for routine in routines:
                print(f"- {routine.get('title', 'No title')}")
        else:
            print("❌ 루틴 목록 조회 실패")
            print(f"Error: {response.text}")

    except Exception as e:
        print(f"❌ 요청 실패: {e}")


if __name__ == "__main__":
    print("🧪 루틴 API 테스트 시작")
    print("=" * 40)

    # 1. 루틴 생성 테스트
    test_routine_creation()

    # 2. 루틴 목록 조회 테스트
    test_get_routines()

    print("=" * 40)
    print("🧪 테스트 완료")
