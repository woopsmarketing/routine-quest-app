# CLAUDE.md

이 문서는 Claude Code(claude.ai/code)가 이 저장소에서 작업할 때 필요한 프로젝트 컨텍스트와 개발
가이드라인을 제공합니다.

## 🚫 GitHub MCP 사용 규칙(강제)

**기본값: GitHub MCP 절대 금지**

오직 아래 트리거 문구가 있을 때만 1회 호출 허용(그 외 자동/추론 호출 금지).

### 허용 트리거(정확 매칭, 한국어/영어)

- "PR 생성" | "/pr" | "create PR"
- "코드 리뷰 요청" | "/review" | "request code review"
- "MERGE 준비" | "/merge-prepare" | "prepare merge"

### 호출 전 필수 선행 작업

1. 현재 브랜치가 main이 아닌지 확인
2. 변경 요약(파일/라인, 위험도)
3. 로컬 lint/test/build 실행 및 결과 보고

### 금지 사항

- 위 트리거 없이 GitHub MCP 호출 시도
- main에 직접 쓰기/병합 시도
- 대규모 파일 전체 리라이트 후 즉시 PR 시도

### 실행 시퀀스(예: PR 생성)

1. 브랜치/변경/테스트 요약 출력
2. PR 메타(제목/본문/리뷰어/라벨) 나에게 확인 요청
3. GitHub MCP로 PR 생성
4. PR URL과 CI 상태 폴링 후 보고

**실패/의문 시 즉시 중단하고 질의**

---

## 🤖 바이브코딩 자동화 규칙 (Claude Code)

### 트리거 명령어 자동화

사용자가 다음 명령어를 입력하면 자동으로 해당 Git 작업 수행:

#### **"업로드해줘"** 트리거

```bash
# 자동 실행 명령어
git add .
git commit -m "feat: claude 작업 완료 - [현재시간]

🧠 Claude Code 작업 내역:
- [주요 변경사항 자동 요약]"
git push origin feature/claude-setup
```

#### **"검토 완료"** 트리거

```bash
# 위 업로드 명령어 + PR 생성
gh pr create --title "✨ Claude 작업 완료: [기능명]" \
  --body "🧠 Claude Code 분석 및 개선 완료

## 📋 작업 내역
- [변경사항 자동 요약]
- 코드 품질 개선
- 성능 최적화
- 보안 검토 완료

## 🎯 다음 단계
- [ ] CI/CD 파이프라인 검증
- [ ] develop 브랜치 통합 테스트
- [ ] main 브랜치 배포 준비" \
  --base develop \
  --head feature/claude-setup
```

#### **브랜치 전략**

- **현재 브랜치**: `feature/claude-setup` (Claude Code 전용)
- **타깃 브랜치**: `develop` (통합 테스트용)
- **최종 목표**: `main` (프로덕션 배포)

### 워크플로우 단계별 역할

#### **Phase 1: 분석 및 설계 (Claude Code 담당)**

```
사용자: "XXX 기능 분석하고 설계해줘"
→ 아키텍처 분석, DB 설계, API 명세 작성
→ "업로드해줘" → feature/claude-setup에 자동 커밋
```

#### **Phase 2: 코드 리뷰 및 개선 (Claude Code 담당)**

```
사용자: "Cursor 작업 결과 리뷰하고 개선해줘"
→ 코드 품질 분석, 리팩토링, 성능 최적화
→ "검토 완료" → develop 브랜치로 PR 자동 생성
```

#### **Phase 3: 최종 검증 (Claude Code 담당)**

```
사용자: "develop 브랜치 최종 검토해줘"
→ 통합 테스트 결과 분석, 배포 준비 상태 확인
→ "배포 준비" → main 브랜치로 PR 생성 (수동 확인 필요)
```

---

## 🎯 프로젝트 개요

**Routine Quest App** - "다음 1스텝"만 보여주는 순서 기반 퀘스트형 루틴 앱

### 핵심 컨셉

- **문제점**: 기존 체크리스트형 습관 앱은 선택지가 많아 의사결정 피로 발생
- **해결책**: 화면에 "다음 1개 스텝"만 표시하여 실행 장벽을 최소화
- **목표**: 재방문 빈도와 30일 잔존율(D30) 향상

### 타깃 사용자

- **개인**: 생산성·건강 루틴을 꾸준히 만들고 싶은 학생·프리랜서·직장인
- **팀**: 소규모 스터디/팀 단위 공동 목표 달성
- **페르소나**:
  - A) 루틴 초보 (습관 실패 경험 多) → 최소 설정·성공 경험 필요
  - B) 일/학습 루틴러 → 데이터/통계·연속성 강조
  - C) 소규모 팀/스터디 → 주간 목표와 가벼운 공동 집중

### 수익화 모델

- **무료**: 루틴 1개·5스텝, 히스토리 3일, 체인 완료 후 전면광고 1회
- **Basic**: 광고 제거, 무제한 루틴/스텝, 스트릭 보호, AI 월 3회
- **Pro**: 길드/도전장, 시즌 풀보상, 고급 통계, AI 월 15회
- **Team**: 팀 보드/리포트 (좌석 과금)

## 🏗️ 기술 아키텍처

### 모노레포 구조 (Turborepo + PNPM)

```
routine-quest-app/
├── client/        # Flutter (iOS/Android/Web) - Clean Architecture
├── api/           # FastAPI 백엔드 - SQLAlchemy + PostgreSQL
├── ai/            # FastAPI 기반 AI 마이크로서비스
├── shared/        # 공용 TypeScript 유틸리티/타입
├── docker/        # 로컬 개발용 Docker Compose 스택
├── scripts/       # 개발/배포 자동화 스크립트
├── .github/       # CI/CD GitHub Actions 워크플로우
├── .husky/        # Git 훅 (코드 품질 자동 검사)
├── .changeset/    # 버전 관리 및 릴리스 자동화
├── package.json   # 모노레포 루트 설정 (PNPM 워크스페이스)
├── turbo.json     # Turborepo 태스크 오케스트레이션
└── pyproject.toml # Python 프로젝트 통합 설정
```

**✨ 모노레포 장점:**

- **병렬 실행**: Turborepo가 모든 작업을 최적화하여 병렬 처리
- **증분 빌드**: 변경된 패키지만 다시 빌드하여 시간 단축
- **원격 캐시**: 팀 전체가 빌드 결과 공유
- **통합 개발**: 하나의 명령어로 전체 스택 실행
- **코드 품질**: Git 훅으로 커밋 전 자동 검사

### 핵심 기술 스택

#### **Flutter 클라이언트** (`client/`)

- **상태관리**: Riverpod + 코드 생성 (`flutter_riverpod`, `riverpod_annotation`)
- **라우팅**: GoRouter (`go_router`)
- **로컬 DB**: Isar (`isar`, `isar_flutter_libs`)
- **네트워킹**: Dio + Retrofit (`dio`, `retrofit`)
- **Firebase**: Auth, Analytics, Crashlytics, Messaging, Remote Config
- **UI/UX**: Flutter Animate, SVG, Cached Network Image
- **폰트**: Pretendard (한국어 가독성)

#### **백엔드 API** (`api/`)

- **프레임워크**: FastAPI (async/await)
- **데이터베이스**: PostgreSQL + SQLAlchemy 2.0 ORM
- **마이그레이션**: Alembic
- **캐시/큐**: Redis + Celery (배치/스케줄)
- **인증**: JWT (`python-jose`), 비밀번호 해시 (`bcrypt`)
- **Firebase**: Admin SDK (클라이언트 검증)
- **모니터링**: Sentry 통합

#### **AI 마이크로서비스** (`ai/`)

- **LLM 클라이언트**: OpenAI, Anthropic (Claude)
- **프레임워크**: LangChain (프롬프트/체인 관리)
- **캐싱**: Redis (응답 캐싱)
- **처리**: NumPy, Pandas (데이터 분석/스코어링)

## 🔧 필수 개발 명령어

### 🚀 빠른 시작 (모노레포)

```bash
# 1) 전체 환경 초기 설정 (한 번만 실행)
./scripts/setup.sh

# 2) 개발 서버 실행 (Turborepo 병렬 실행)
pnpm dev
# 또는
./scripts/dev.sh

# 3) 서비스 URL 확인
# • 백엔드 API: http://localhost:8000 (/docs)
# • AI 서비스: http://localhost:8001
# • Flutter 웹: http://localhost:3000
```

### 🏗️ 빌드 및 테스트

```bash
# 전체 프로젝트 빌드
pnpm build
./scripts/build.sh

# 전체 테스트 실행
pnpm test
./scripts/test.sh

# 코드 품질 검사
pnpm lint                    # 린트 검사
pnpm lint:fix                # 자동 수정
./scripts/lint.sh fix        # 전체 포맷팅
```

### ⚡ 개발 효율성 명령어

```bash
# 특정 패키지만 실행
pnpm dev --filter=@routine-quest/api      # 백엔드만
pnpm dev --filter=@routine-quest/client   # 프론트엔드만
pnpm build --filter=shared                # Shared 패키지만

# 변경사항 기반 실행 (Git 기반)
pnpm turbo test --filter="...[HEAD^1]"    # 변경된 패키지만 테스트

# 캐시 관리
pnpm clean                                 # 빌드 결과물 정리
turbo prune --scope=api                    # 특정 패키지 정리
```

### 🏷️ 버전 관리 및 릴리스

```bash
# 변경사항 기록 (Changesets)
pnpm changeset

# 릴리스 준비 (품질 검사 + 빌드)
./scripts/release.sh prepare

# 버전 업데이트
pnpm changeset version

# 릴리스 상태 확인
pnpm changeset status
```

### 데이터베이스 마이그레이션

```bash
# 마이그레이션 파일 생성
cd api && alembic revision --autogenerate -m "설명"

# 마이그레이션 적용
cd api && alembic upgrade head
```

## 🎮 핵심 기능 명세

### 1. 퀘스트 체인 (다음 1스텝 UI)

- **구현**: Flutter 위젯 `NextStepCard` + 로컬 캐시
- **로직**: 완료/스킵 이벤트 → 서버 기록 → XP/콤보 계산
- **위치**: `client/lib/features/today/presentation/widgets/next_step_card.dart`

### 2. 퍼스널 부스트 타임 (PBT)

- **기능**: 설정 시각 ±30분에 XP +10% 보너스
- **구현**: 백엔드 스케줄러 → PBT 푸시 예약 → 클라이언트 부스트 표시
- **목적**: FOMO 생성으로 재방문 유도

### 3. 스트릭 링 + 보호권

- **기능**: 연속일수별 프로필 링 색/광택 변화, 주1회 자동 보호권
- **구현**: `streak_counter` + `weekly_grace_token` 로직
- **DB**: `users.streak`, `users.grace_tokens`

### 4. 시즌 패스 (4~8주, 확정 보상)

- **기능**: 일/주 목표 달성 시 코스메틱 확정 지급
- **구현**: 시즌 테이블/규칙 엔진 + 보상 수령 API
- **UI**: 클라이언트 진행 트랙 위젯

### 5. 길드 주간 게이지 (3~10인)

- **기능**: 팀 평균 완료율 60%↑ 시 다음 주 XP +5% 버프
- **구현**: 주간 집계 배치 → 게이지 퍼센트 → 읽기 전용 위젯

### 6. AI 코치 카드

- **기능**: 200~300자 짧은 개인화 팁 (월 n회 제한)
- **구현**: 규칙/통계 → LLM 문장화 → Redis 캐싱
- **비용 통제**: 토큰 상한 + 구독 크레딧 차감

## 🗃️ 핵심 데이터 모델

```sql
-- 사용자
users(id, tier, tz, pbt_time, streak, grace_tokens, created_at)

-- 루틴 관리
routines(id, user_id, title, is_public, version, last_changed_at)
steps(id, routine_id, "order", title, difficulty, t_ref_sec, type)

-- 실행 기록
sessions(id, user_id, routine_id, started_at, finished_at)
checkins(id, session_id, step_id, t_spent_sec, status)

-- 게이미피케이션
rewards(id, user_id, type, payload, earned_at)
subscriptions(user_id, store, product, purchase_token, status, renews_at)

-- 소셜
guilds(id, name)
guild_members(guild_id, user_id, role)

-- 집계
stats_daily(user_id, date, steps_done, chain_done, streak)
```

## 🌐 핵심 API 엔드포인트

```python
# 인증
POST /auth/verify                # Firebase ID 토큰 검증

# 루틴 관리
GET|POST|PUT|DELETE /routines/*  # CRUD + 변경 한도/쿨다운 검증

# 세션 실행
POST /session/start              # 세션 시작
POST /session/step/complete      # 스텝 완료/스킵, XP/콤보 계산
GET  /session/next-step         # 다음 스텝 조회

# 게이미피케이션
GET /season/progress            # 시즌 진행도
POST /season/claim              # 보상 수령
GET /guild/gauge                # 길드 주간 게이지

# AI 코치
POST /ai/coach                  # 한 줄 팁 생성 (크레딧 차감)

# 구독/결제
POST /iap/verify                # 영수증 검증
POST /iap/apple/notify          # Apple 서버 알림
POST /iap/google/notify         # Google 서버 알림

# 푸시 알림
POST /push/schedule             # PBT 푸시 예약
```

## 📱 개발용 서비스 URL

- **백엔드 API**: http://localhost:8000 (`/docs`에서 API 문서 확인)
- **AI 서비스**: http://localhost:8001
- **Flutter 웹**: http://localhost:3000
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## 🎨 아키텍처 패턴

### Flutter 클린 아키텍처

```
features/
├── auth/
├── today/           # 핵심 기능
│   ├── data/       # 리포지토리, 데이터소스
│   ├── domain/     # 엔티티, 유스케이스
│   └── presentation/ # 페이지, 위젯, 상태
├── routine/
└── profile/
```

### 백엔드 계층 분리

```
api/app/
├── models/         # SQLAlchemy 모델
├── api/endpoints/  # FastAPI 라우터
├── services/       # 비즈니스 로직
└── core/          # 설정, 인증, DB
```

## ⚙️ 중요 설정 파일

- **`.env`** - API 키, DB 자격증명, 서비스 URL (⚠️ 커밋 금지)
- **`client/pubspec.yaml`** - Flutter 의존성/에셋 설정
- **`api/requirements.txt`** - 백엔드 Python 의존성
- **`ai/requirements.txt`** - AI 서비스 의존성
- **`docker/docker-compose.yml`** - PostgreSQL/Redis 포함 로컬 스택
- **`client/lib/core/config/firebase_options.dart`** - Firebase 설정

## 🧪 테스트 전략

- **Flutter**: 위젯/통합 테스트 (`client/test/`)
- **백엔드**: async 지원 Pytest (`api/tests/`)
- **AI**: LLM 통합/프롬프트 회귀 테스트 (`ai/tests/`)

## 📋 Claude Code 작업 지침

### 🔍 맥락 파악 우선

- 작업 전 이 파일과 `docker/`, `scripts/`, 각 서비스의 설정 파일을 먼저 확인
- PRD.txt의 기능 명세와 기술 아키텍처 이해

### ⚡ 원자적 변경

- 하나의 PR은 하나의 목적
- 작은 단위로 커밋/PR 생성
- 기능별로 독립적인 변경사항 유지

### 🧪 테스트 동반

- 기능 추가/수정 시 해당 레이어의 테스트를 반드시 추가/갱신
- Flutter: 위젯 테스트, Backend: Pytest 비동기 테스트

### 🔄 마이그레이션 안전성

- Alembic 자동생성 시 파괴적 변경(DROP/데이터 손실) 여부 점검
- 위험한 변경사항은 PR에 명시하고 대안 제시

### 🔐 환경변수 엄수

- 키/시크릿은 `.env`로 주입, 코드/Git에 절대 노출 금지
- Firebase, OpenAI, Anthropic 등 모든 API 키는 환경변수 처리

### 🔗 API 계약 준수

- `api`와 `client` 간 DTO/스키마 변경 시 상호 의존 모듈 동시 업데이트
- 호환성 레이어 제공으로 점진적 마이그레이션 지원

### ⚡ 성능 기본값

- N+1 쿼리 방지 (SQLAlchemy 옵션/프리페치)
- 캐시 가능한 경로는 Redis로 보호
- Flutter: `const` 위젯, Selector 최적화

### 📊 관측성

- 예외에 Sentry 태그 (서비스/엔드포인트/사용자 식별자 해시) 포함
- 구조화된 로깅으로 디버깅 용이성 확보

### 📖 문서화

- 새 모델/엔드포인트/플로우 추가 시 이 파일 또는 해당 서비스 README에 3~5줄 요약 추가
- API 변경사항은 `/docs` 자동 문서화 확인

### 🔄 로컬 재현성

- PR 설명에 로컬 재현 방법 (명령어/URL/테스트 케이스) 명시
- `./scripts/dev.sh`로 전체 스택 실행 가능 상태 유지

## 🚀 Claude용 빠른 시작 프롬프트 예시

### 프론트엔드 작업

```
"client/에 '오늘의 다음 1스텝' 카드 위젯을 추가해줘.
Riverpod 상태와 GoRouter 연동, 더미 API를 사용하는 리포지토리 구현,
위젯 테스트 1개 포함."
```

### 백엔드 작업

```
"api/에 /routines/{id}/next-step 엔드포인트를 추가.
사용자 세션/권한 체크, 서비스 계층에서 비즈니스 로직 처리,
Pytest 3개 작성."
```

### AI 코칭 작업

```
"ai/에 루틴 이행 로그를 기반으로 다음 스텝 제안 체인을 LangChain으로 구성.
Redis 캐시 키 전략 포함, 프롬프트/테스트 케이스 추가."
```

## 🛠️ 문제 해결 체크리스트

- **의존성 오류**: 각 서비스 루트에서 재설치 (`pip install -r requirements.txt`, `flutter pub get`)
- **마이그레이션 충돌**: `alembic downgrade -1` 후 스키마 정리 → 재생성
- **포트 충돌**: dev 스크립트/Compose 포트 변경
- **Firebase 설정 누락**: `firebase_options.dart`/`.env` 키 확인
- **코드 생성 이슈**: Flutter에서 `build_runner clean` → `build_runner build`

---

_이 가이드는 Routine Quest App의 "다음 1스텝" 철학을 구현하면서 높은 코드 품질과 사용자 경험을
동시에 달성하기 위한 개발 원칙을 담고 있습니다._
