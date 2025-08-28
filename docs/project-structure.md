# 📁 프로젝트 구조 가이드

루틴 퀘스트 앱의 모노레포 구조와 각 파일의 역할을 설명합니다.

## 🏗️ 전체 구조 개요

```
routine-quest-app/
├── 📱 client/              # Flutter 클라이언트 (iOS/Android/Web)
├── 🚀 api/                 # 메인 백엔드 API (FastAPI)
├── 🤖 ai/                  # AI 마이크로서비스 (FastAPI)
├── 🤝 shared/              # 공통 설정 및 유틸리티
├── 📖 docs/                # 프로젝트 문서
├── 🐳 docker/              # Docker 관련 설정
├── ⚙️ .github/             # GitHub Actions CI/CD
├── 🛠️ scripts/             # 개발/배포 스크립트
└── 📄 README.md            # 프로젝트 소개
```

## 📱 Flutter 클라이언트 구조

```
client/
├── lib/
│   ├── core/                    # 앱 코어 (테마, 라우팅, 설정)
│   │   ├── app.dart            # 메인 앱 위젯
│   │   ├── config/
│   │   │   ├── theme.dart      # Material3 테마 설정
│   │   │   └── firebase_options.dart  # Firebase 설정
│   │   └── router/
│   │       └── app_router.dart # go_router 기반 네비게이션
│   │
│   ├── features/               # 기능별 모듈 (Clean Architecture)
│   │   ├── auth/              # 인증 (Firebase Auth)
│   │   ├── onboarding/        # 온보딩 플로우
│   │   ├── today/             # 투데이 화면 (핵심 기능)
│   │   │   ├── data/          # 데이터 레이어
│   │   │   ├── domain/        # 도메인 레이어
│   │   │   └── presentation/  # UI 레이어
│   │   │       ├── pages/
│   │   │       │   └── today_page.dart      # 메인 투데이 화면
│   │   │       └── widgets/
│   │   │           └── next_step_card.dart  # 다음 스텝 카드
│   │   ├── routine/           # 루틴 관리
│   │   └── profile/           # 프로필/설정
│   │
│   ├── shared/                # 공통 컴포넌트 및 유틸리티
│   │   ├── data/              # 공통 데이터 클래스
│   │   ├── presentation/      # 공통 UI 컴포넌트
│   │   └── utils/             # 유틸리티 함수들
│   │
│   └── main.dart              # 앱 진입점
│
├── assets/                    # 리소스 파일들
│   ├── images/               # 이미지
│   ├── icons/                # 아이콘
│   ├── animations/           # 애니메이션
│   ├── sounds/               # 사운드
│   └── fonts/                # 폰트 (Pretendard)
│
└── pubspec.yaml              # Flutter 의존성 및 설정
```

## 🚀 백엔드 API 구조

```
api/
├── app/
│   ├── core/                    # 코어 설정
│   │   ├── config.py           # 환경설정 (Pydantic Settings)
│   │   ├── database.py         # 데이터베이스 연결
│   │   ├── auth.py             # 인증 미들웨어
│   │   └── celery.py           # Celery 설정
│   │
│   ├── models/                 # SQLAlchemy 모델들
│   │   ├── __init__.py         # 모든 모델 임포트
│   │   ├── user.py             # 사용자 모델
│   │   ├── routine.py          # 루틴/스텝 모델
│   │   ├── session.py          # 세션/체크인 모델
│   │   ├── reward.py           # 보상/시즌패스 모델
│   │   ├── guild.py            # 길드 모델
│   │   ├── subscription.py     # 구독 모델
│   │   └── stats.py            # 통계 모델
│   │
│   ├── api/                    # API 라우터들
│   │   ├── api_v1/
│   │   │   ├── api.py          # 메인 라우터
│   │   │   └── endpoints/
│   │   │       ├── auth.py     # 인증 API
│   │   │       ├── routines.py # 루틴 CRUD API
│   │   │       ├── sessions.py # 세션 실행 API
│   │   │       ├── rewards.py  # 보상 API
│   │   │       └── users.py    # 사용자 API
│   │   └── deps.py             # 의존성 주입
│   │
│   ├── services/               # 비즈니스 로직
│   │   ├── user_service.py     # 사용자 서비스
│   │   ├── routine_service.py  # 루틴 서비스
│   │   ├── session_service.py  # 세션 실행 서비스
│   │   ├── reward_service.py   # 보상 서비스
│   │   └── push_service.py     # 푸시 알림 서비스
│   │
│   └── main.py                 # FastAPI 앱 진입점
│
├── alembic/                    # 데이터베이스 마이그레이션
├── tests/                      # 테스트 코드
├── requirements.txt            # Python 의존성
└── Dockerfile                  # Docker 이미지 설정
```

## 🤖 AI 마이크로서비스 구조

```
ai/
├── app/
│   ├── core/
│   │   ├── config.py           # AI 서비스 설정
│   │   └── auth.py             # 토큰 검증
│   │
│   ├── services/
│   │   ├── coach_service.py    # AI 코치 메인 서비스
│   │   ├── llm_client.py       # LLM API 클라이언트들
│   │   ├── prompt_templates.py # 프롬프트 템플릿
│   │   └── cache_service.py    # Redis 캐싱
│   │
│   └── main.py                 # AI 서비스 진입점
│
├── requirements.txt            # AI 특화 의존성
└── Dockerfile                  # AI 서비스 Docker 설정
```

## 🐳 Docker 및 인프라

```
docker/
├── docker-compose.yml          # 개발 환경 전체 스택
├── docker-compose.prod.yml     # 프로덕션 환경
└── init.sql                    # 초기 DB 설정
```

## ⚙️ CI/CD 및 자동화

```
.github/
└── workflows/
    ├── ci-cd.yml               # 메인 CI/CD 파이프라인
    ├── flutter-test.yml        # Flutter 전용 테스트
    └── security-scan.yml       # 보안 스캔
```

## 🛠️ 개발 스크립트

```
scripts/
├── setup.sh                   # 초기 개발환경 설정
├── dev.sh                     # 개발 서버 실행
├── test.sh                    # 전체 테스트 실행
├── build.sh                   # 프로덕션 빌드
└── deploy.sh                  # 배포 스크립트
```

## 📖 문서

```
docs/
├── project-structure.md       # 이 파일
├── api.md                     # API 명세서
├── client.md                  # 클라이언트 개발 가이드
├── deployment.md              # 배포 가이드
└── contributing.md            # 기여 가이드
```

## 🔑 주요 설정 파일들

- **`.env`**: 환경변수 (API 키, DB 연결 정보 등)
- **`pubspec.yaml`**: Flutter 의존성 및 설정
- **`requirements.txt`**: Python 의존성
- **`docker-compose.yml`**: 개발 환경 컨테이너 설정
- **`ci-cd.yml`**: GitHub Actions 워크플로우

## 🚀 개발 시작하기

1. **초기 설정**: `./scripts/setup.sh`
2. **개발 서버 실행**: `./scripts/dev.sh`
3. **Docker로 실행**: `cd docker && docker-compose up`

각 서비스의 상세한 개발 가이드는 해당 폴더의 README 파일을 참고하세요.
