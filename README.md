# 🎯 Routine Quest App

> 순서 기반 퀘스트형 루틴 앱 - "다음 1스텝"만 보여주는 혁신적인 습관 관리 앱

## 📋 프로젝트 개요

기존 체크리스트형 습관 앱과 달리, 사용자는 '다음 1개 스텝'만 보며 루틴을 순서대로 수행합니다.
의사결정 피로를 줄이고, 짧고 확정적인 보상과 팀 기반 사회적 약속으로 재방문 빈도와 30일 잔존율을 끌어올립니다.

## 🏗️ 모노레포 구조

```
routine-quest-app/
├── client/                 # Flutter 클라이언트 (iOS/Android/Web)
├── api/                    # 메인 백엔드 API (FastAPI)
├── ai/                     # AI 마이크로서비스 (FastAPI)
├── shared/                 # 공통 설정 및 유틸리티
├── docs/                   # 프로젝트 문서
├── docker/                 # Docker 관련 설정
├── .github/                # GitHub Actions CI/CD
└── scripts/                # 개발/배포 스크립트
```

## 🚀 시작하기

### 전체 개발 환경 설정
```bash
# 전체 프로젝트 설정
./scripts/setup.sh

# 개발 서버 실행
./scripts/dev.sh
```

### 개별 서비스 실행
```bash
# Flutter 클라이언트
cd client && flutter run

# 백엔드 API
cd api && uvicorn app.main:app --reload

# AI 마이크로서비스
cd ai && uvicorn app.main:app --reload --port 8001
```

## 📖 문서

- [API 문서](./docs/api.md)
- [클라이언트 개발 가이드](./docs/client.md)
- [배포 가이드](./docs/deployment.md)
- [기여 가이드](./docs/contributing.md)

## 📄 라이선스

MIT License

---

*마지막 업데이트: 2025년 8월 27일 - CI/CD 파이프라인 테스트*