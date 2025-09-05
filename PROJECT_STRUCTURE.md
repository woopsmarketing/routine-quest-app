# 🏗️ Routine Quest App - 프로젝트 구조 상세 분석

> **"다음 1스텝"만 보여주는 순서 기반 퀘스트형 루틴 앱**  
> Flutter + FastAPI + AI 마이크로서비스 아키텍처

---

## 📋 프로젝트 개요

### 🎯 핵심 컨셉
- **Clean Architecture** 기반의 모노레포 구조
- **Flutter** (클라이언트) + **FastAPI** (백엔드) + **AI 서비스** (마이크로서비스)
- **PNPM 워크스페이스** + **Turborepo**로 빌드 최적화
- **Docker** 컨테이너화로 개발/배포 환경 통일

### 🛠️ 기술 스택
- **Frontend**: Flutter 3.16+ (iOS/Android/Web)
- **Backend**: FastAPI + SQLAlchemy + PostgreSQL
- **AI Service**: FastAPI + LangChain (OpenAI/Anthropic)
- **Infrastructure**: Docker + Turborepo + PNPM

---

## 🌳 루트 디렉토리 구조

```
routine-quest-app/
├── 📱 client/              # Flutter 클라이언트 앱
├── 🚀 api/                 # FastAPI 백엔드 서버
├── 🤖 ai/                  # AI 마이크로서비스
├── 🔗 shared/              # 공통 타입 및 유틸리티
├── 🐳 docker/              # Docker 설정 파일
├── 📚 docs/                # 프로젝트 문서
├── 🛠️ scripts/             # 개발/배포 스크립트
├── 📦 node_modules/        # Node.js 의존성 (자동 생성)
├── 📄 package.json         # 루트 패키지 설정
├── 📄 pnpm-workspace.yaml  # PNPM 워크스페이스 설정
├── 📄 turbo.json           # Turborepo 빌드 설정
└── 📄 requirements.txt     # Python 의존성 통합
```

---

## 📱 client/ - Flutter 클라이언트 앱

### 📂 디렉토리 구조
```
client/
├── 📁 lib/                    # Flutter 소스 코드
│   ├── 📁 core/               # 핵심 설정 및 공통 기능
│   │   ├── 📁 api/            # API 클라이언트
│   │   ├── 📁 config/         # 앱 설정 (테마, 환경변수)
│   │   ├── 📁 router/         # 라우팅 설정
│   │   └── 📄 app.dart        # 앱 메인 위젯
│   ├── 📁 features/           # 기능별 모듈 (Clean Architecture)
│   │   ├── 📁 auth/           # 인증 기능
│   │   ├── 📁 dashboard/      # 대시보드
│   │   ├── 📁 onboarding/     # 온보딩
│   │   ├── 📁 profile/        # 사용자 프로필
│   │   ├── 📁 routine/        # 루틴 관리
│   │   └── 📁 today/          # 오늘의 루틴 (핵심 기능)
│   ├── 📁 shared/             # 공유 컴포넌트 및 서비스
│   │   ├── 📁 presentation/   # 공통 UI 위젯
│   │   ├── 📁 services/       # 공통 서비스
│   │   └── 📁 widgets/        # 재사용 가능한 위젯
│   └── 📄 main.dart           # 앱 진입점
├── 📁 test/                   # 테스트 코드
├── 📁 web/                    # 웹 빌드 설정
├── 📁 build/                  # 빌드 결과물 (자동 생성)
├── 📄 pubspec.yaml            # Flutter 의존성 설정
├── 📄 analysis_options.yaml   # Dart 린터 설정
└── 📄 README.md               # 클라이언트 앱 문서
```

### 🎯 주요 기능별 구조

#### 📁 features/today/ - 핵심 기능 (오늘의 루틴)
```
today/
├── 📁 data/                   # 데이터 레이어
│   ├── 📁 providers/          # Riverpod 상태 관리
│   │   ├── routine_provider.dart      # 루틴 데이터 프로바이더
│   │   └── routine_state_provider.dart # 루틴 상태 프로바이더
│   └── 📄 dummy_data.dart     # 개발용 더미 데이터
├── 📁 domain/                 # 도메인 레이어
│   └── 📁 models/
│       └── step.dart          # 스텝 모델 정의
└── 📁 presentation/           # 프레젠테이션 레이어
    ├── 📁 pages/
    │   └── today_page.dart    # 메인 페이지 (783줄)
    └── 📁 widgets/            # UI 컴포넌트들
        ├── completion_summary.dart      # 완료 요약
        ├── next_step_card.dart          # 다음 스텝 카드
        ├── progress_header.dart         # 진행률 헤더
        ├── routine_completion_widget.dart # 루틴 완료 위젯
        └── step_timer_widget.dart       # 스텝 타이머
```

#### 📁 core/ - 핵심 설정
```
core/
├── 📁 api/
│   └── api_client.dart        # HTTP 클라이언트 설정
├── 📁 config/
│   └── theme.dart             # 앱 테마 설정
├── 📁 router/
│   └── app_router.dart        # GoRouter 라우팅 설정
└── 📄 app.dart                # 앱 메인 위젯
```

### 📦 의존성 (pubspec.yaml)
```yaml
dependencies:
  flutter: sdk: flutter
  cupertino_icons: ^1.0.2
  
  # 상태 관리
  flutter_riverpod: ^2.4.0
  
  # 라우팅
  go_router: ^12.0.0
  
  # 로컬 저장소
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # HTTP 클라이언트
  http: ^1.1.0
  
  # UI 라이브러리
  flutter_animate: ^4.3.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  intl: ^0.20.2
  table_calendar: ^3.2.0
```

---

## 🚀 api/ - FastAPI 백엔드 서버

### 📂 디렉토리 구조
```
api/
├── 📁 app/                    # FastAPI 애플리케이션
│   ├── 📁 api/                # API 라우터
│   │   └── 📁 api_v1/         # API v1 버전
│   │       ├── 📄 api.py      # 메인 API 라우터
│   │       └── 📁 endpoints/  # 엔드포인트별 라우터
│   │           └── routines.py # 루틴 관련 엔드포인트
│   ├── 📁 core/               # 핵심 설정
│   │   ├── config.py          # 환경 설정
│   │   └── database.py        # 데이터베이스 연결
│   ├── 📁 models/             # SQLAlchemy 모델
│   │   ├── __init__.py        # 모델 초기화
│   │   ├── routine.py         # 루틴 모델
│   │   └── user.py            # 사용자 모델
│   ├── 📁 services/           # 비즈니스 로직 서비스
│   └── 📄 main.py             # FastAPI 앱 진입점
├── 📁 venv/                   # Python 가상환경 (자동 생성)
├── 📄 requirements.txt        # Python 의존성
├── 📄 package.json            # Node.js 설정 (Turborepo용)
├── 📄 Dockerfile              # Docker 이미지 설정
├── 📄 routine_quest.db        # SQLite 데이터베이스 (개발용)
└── 📄 test_*.py               # 테스트 스크립트들
```

### 🎯 주요 파일 설명

#### 📄 main.py - FastAPI 메인 애플리케이션
- **역할**: FastAPI 앱의 진입점, 미들웨어 설정, 라우터 등록
- **주요 기능**:
  - CORS 설정 (클라이언트 앱 접근 허용)
  - Sentry 에러 모니터링
  - UTF-8 인코딩 미들웨어
  - 글로벌 예외 핸들러
  - 헬스체크 엔드포인트 (`/health`)

#### 📁 models/ - 데이터베이스 모델
- **routine.py**: 루틴 관련 데이터 모델
- **user.py**: 사용자 관련 데이터 모델
- **SQLAlchemy ORM** 사용으로 데이터베이스 추상화

#### 📁 core/ - 핵심 설정
- **config.py**: 환경변수, 데이터베이스 URL, CORS 설정 등
- **database.py**: SQLAlchemy 엔진 및 세션 관리

### 📦 의존성 (requirements.txt)
```python
# 웹 프레임워크
fastapi==0.104.1
uvicorn[standard]==0.24.0

# 데이터베이스
sqlalchemy==2.0.23
alembic==1.13.1

# 데이터 검증
pydantic==2.5.0
pydantic-settings==2.1.0

# 인증 및 보안
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4

# 모니터링
sentry-sdk[fastapi]==1.38.0

# 비동기 처리
celery==5.3.4
redis==5.0.1

# 개발 도구
pytest==7.4.3
httpx==0.25.2
```

---

## 🤖 ai/ - AI 마이크로서비스

### 📂 디렉토리 구조
```
ai/
├── 📁 app/                    # AI 서비스 애플리케이션
│   ├── 📁 core/               # 핵심 설정
│   ├── 📁 services/           # AI 서비스 로직
│   └── 📄 main.py             # AI 서비스 진입점
├── 📁 venv/                   # Python 가상환경 (자동 생성)
├── 📄 requirements.txt        # AI 서비스 의존성
├── 📄 package.json            # Node.js 설정 (Turborepo용)
└── 📄 Dockerfile              # AI 서비스 Docker 설정
```

### 🎯 주요 기능

#### 📄 main.py - AI 서비스 메인
- **역할**: AI 코치 마이크로서비스의 진입점
- **주요 엔드포인트**:
  - `POST /coach/tip`: 개인화된 루틴 팁 생성 (200-300자)
  - `POST /coach/batch-generate`: 배치 팁 생성 (Celery 작업용)
  - `GET /coach/usage/{user_id}`: 사용자별 이용 현황
  - `GET /health`: AI 서비스 헬스체크

#### 🎯 PRD 요구사항 구현
- **짧은 팁**: 200-300자 제한
- **월 n회 제한**: 구독 크레딧 시스템
- **캐싱**: Redis를 통한 응답 속도 개선
- **배치 생성**: 대량 사용자용 미리 생성

---

## 🔗 shared/ - 공통 타입 및 유틸리티

### 📂 디렉토리 구조
```
shared/
└── 📄 package.json            # 공통 패키지 설정
```

### 🎯 역할
- **TypeScript 타입 정의**: 클라이언트-서버 간 공통 타입
- **유틸리티 함수**: 공통으로 사용되는 헬퍼 함수
- **상수 정의**: 앱 전체에서 사용되는 상수들
- **API 스키마**: OpenAPI 스키마 공유

---

## 🐳 docker/ - Docker 설정

### 📂 디렉토리 구조
```
docker/
└── 📄 docker-compose.yml      # 멀티 서비스 Docker Compose 설정
```

### 🎯 역할
- **개발 환경 통일**: 모든 서비스를 Docker로 실행
- **서비스 간 통신**: 네트워크 설정으로 서비스 연결
- **데이터베이스**: PostgreSQL 컨테이너
- **Redis**: 캐싱 및 세션 저장소

---

## 📚 docs/ - 프로젝트 문서

### 📂 디렉토리 구조
```
docs/
├── 📄 AUTO_START_IMPLEMENTATION.md  # 자동 시작 구현 가이드
├── 📄 DEVELOPMENT-SETUP.md          # 개발 환경 설정
├── 📄 GITHUB-SETUP-GUIDE.md         # GitHub 설정 가이드
├── 📄 project-structure.md          # 프로젝트 구조 설명
└── 📄 VIBECODING-GUIDE.md           # 바이브코딩 가이드
```

---

## 🛠️ scripts/ - 개발/배포 스크립트

### 📂 디렉토리 구조
```
scripts/
├── 📄 build.sh                # 전체 빌드 스크립트
├── 📄 dev.sh                  # 개발 서버 실행
├── 📄 test.sh                 # 테스트 실행
├── 📄 lint.sh                 # 코드 품질 검사
├── 📄 setup.sh                # 환경 설정
├── 📄 release.sh              # 릴리스 배포
├── 📄 cursor-upload.sh        # Cursor AI 업로드
├── 📄 cursor-complete.sh      # Cursor AI 작업 완료
├── 📄 claude-upload.sh        # Claude AI 업로드
├── 📄 claude-complete.sh      # Claude AI 작업 완료
├── 📄 vibecoding-start.sh     # 바이브코딩 시작
├── 📄 vibecoding-sync.sh      # 바이브코딩 동기화
└── 📄 vibecoding-end.sh       # 바이브코딩 종료
```

---

## 📦 루트 설정 파일들

### 📄 package.json - 루트 패키지 설정
```json
{
  "name": "routine-quest-app",
  "description": "Routine Quest App - 다음 1스텝만 보여주는 순서 기반 퀘스트형 루틴 앱",
  "packageManager": "pnpm@8.15.0",
  "scripts": {
    "build": "echo 'Build completed'",
    "dev": "echo 'Dev mode - use individual service commands'",
    "test": "echo 'Tests - use individual service commands'",
    "lint": "echo 'Lint - use individual service commands'",
    "docker:up": "docker-compose -f docker/docker-compose.yml up -d",
    "docker:down": "docker-compose -f docker/docker-compose.yml down"
  }
}
```

### 📄 pnpm-workspace.yaml - PNPM 워크스페이스 설정
- **모노레포 관리**: client, api, ai, shared 패키지 통합 관리
- **의존성 공유**: 공통 라이브러리 버전 통일
- **빌드 최적화**: 워크스페이스 간 의존성 최적화

### 📄 turbo.json - Turborepo 빌드 설정
- **병렬 빌드**: 여러 패키지를 동시에 빌드
- **캐싱**: 빌드 결과 캐싱으로 속도 향상
- **태스크 파이프라인**: build, dev, test, lint 태스크 정의

---

## 🔄 개발 워크플로우

### 🚀 빠른 시작
```bash
# 전체 환경 설정
./scripts/setup.sh

# 개발 서버 실행 (모든 서비스)
pnpm dev

# 특정 서비스만 실행
pnpm dev --filter=@routine-quest/client   # Flutter 웹
pnpm dev --filter=@routine-quest/api      # 백엔드 API
```

### 🏗️ 빌드 및 테스트
```bash
# 전체 빌드
pnpm build

# 전체 테스트
pnpm test

# 코드 품질 검사
pnpm lint

# Docker 환경 실행
pnpm docker:up
```

### 🎵 바이브코딩 세션
```bash
# 바이브코딩 시작
./scripts/vibecoding-start.sh

# 작업 완료 후 업로드
./scripts/cursor-upload.sh

# 최종 완료 및 PR 생성
./scripts/cursor-complete.sh
```

---

## 🎯 아키텍처 특징

### 🏛️ Clean Architecture
- **의존성 역전**: 외부 프레임워크에 의존하지 않는 비즈니스 로직
- **레이어 분리**: Presentation → Domain → Data 레이어 분리
- **테스트 가능성**: 각 레이어별 독립적 테스트 가능

### 🔄 마이크로서비스 아키텍처
- **서비스 분리**: API 서버와 AI 서비스 독립 실행
- **확장성**: 각 서비스별 독립적 스케일링
- **장애 격리**: 한 서비스 장애가 전체에 영향 없음

### 📱 크로스 플랫폼
- **Flutter**: iOS, Android, Web 동시 지원
- **반응형 디자인**: 다양한 화면 크기 대응
- **PWA 지원**: 웹 앱을 네이티브 앱처럼 사용

---

## 🔧 개발 도구 및 설정

### 📝 코드 품질
- **ESLint**: JavaScript/TypeScript 린팅
- **Pylint**: Python 코드 품질 검사
- **Flutter Lint**: Dart 코드 스타일 검사
- **Prettier**: 코드 포맷팅 자동화

### 🧪 테스트
- **Flutter Test**: 위젯 테스트, 단위 테스트
- **Pytest**: Python 백엔드 테스트
- **Integration Test**: API 통합 테스트

### 🐳 컨테이너화
- **Docker**: 개발/배포 환경 통일
- **Docker Compose**: 멀티 서비스 오케스트레이션
- **Multi-stage Build**: 최적화된 이미지 생성

---

## 📊 프로젝트 현황

### ✅ 완료된 기능
- [x] 프로젝트 구조 설정 (모노레포)
- [x] Flutter 클라이언트 기본 구조
- [x] FastAPI 백엔드 기본 구조
- [x] AI 마이크로서비스 기본 구조
- [x] Docker 환경 설정
- [x] 개발 스크립트 및 자동화

### 🚧 진행 중인 기능
- [ ] 루틴 CRUD API 구현
- [ ] 사용자 인증 시스템
- [ ] AI 코치 팁 생성 로직
- [ ] Flutter UI 컴포넌트 완성

### 📋 다음 단계
- [ ] 데이터베이스 마이그레이션
- [ ] API 엔드포인트 완성
- [ ] Flutter 앱 UI/UX 완성
- [ ] 통합 테스트 작성
- [ ] 프로덕션 배포 설정

---

## 🎵 바이브코딩 가이드

### 💻 Cursor AI 역할
- **Phase 1**: 대량 UI/UX 컴포넌트 구현
- **Phase 2**: CRUD 기능 반복 구현
- **Phase 3**: API 엔드포인트 표준 패턴 적용
- **Phase 4**: 테스트 코드 자동 생성

### 🧠 Claude Code 인계 시점
- 복잡한 아키텍처 설계 필요
- 성능 최적화 및 리팩토링
- 보안 검토 및 취약점 분석
- 데이터 분석 및 알고리즘 최적화

---

**🎵 Happy Coding with Routine Quest App! 효율적인 바이브코딩을 위해 이 구조를 활용하세요.**
