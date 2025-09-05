# 🔍 스텝 추가 API 테스트 스크립트
import requests
import json


def test_add_step():
    """스텝 추가 API 테스트"""
    # 테스트용 스텝 데이터
    step_data = {
        "title": "물마시기",
        "description": "수분충전",
        "type": "action",
        "difficulty": "easy",
        "t_ref_sec": 180,
        "is_optional": False,
        "xp_reward": 10,
    }

    try:
        print("📋 스텝 추가 테스트 시작...")
        print(f"요청 데이터: {json.dumps(step_data, indent=2, ensure_ascii=False)}")

        response = requests.post(
            "http://localhost:8000/api/v1/routines/1/steps",
            headers={"Content-Type": "application/json"},
            json=step_data,
        )

        print(f"\n📊 응답 결과:")
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        print(f"Response Body: {response.text}")

        if response.status_code == 422:
            print("\n❌ 422 Validation Error - 상세 정보:")
            try:
                error_detail = response.json()
                print(json.dumps(error_detail, indent=2, ensure_ascii=False))
            except:
                print("JSON 파싱 실패")

    except Exception as e:
        print(f"❌ 요청 실패: {e}")


def test_get_routines():
    """루틴 목록 확인"""
    try:
        print("\n📋 루틴 목록 확인...")
        response = requests.get("http://localhost:8000/api/v1/routines/")
        print(f"Status Code: {response.status_code}")
        if response.status_code == 200:
            routines = response.json()
            print(f"루틴 개수: {len(routines)}")
            for routine in routines:
                print(f"- ID: {routine['id']}, 제목: {routine['title']}")
        else:
            print(f"Error: {response.text}")
    except Exception as e:
        print(f"❌ 루틴 목록 조회 실패: {e}")


if __name__ == "__main__":
    test_get_routines()
    test_add_step()
