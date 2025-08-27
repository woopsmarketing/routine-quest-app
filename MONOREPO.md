# 🏗️ Monorepo Setup Guide

Routine Quest App이 **Turborepo + PNPM 워크스페이스** 기반 모노레포로 업그레이드되었습니다!

## 🎯 모노레포 혜택

### ✅ 개발 효율성
- **병렬 실행**: 모든 작업이 최적화된 병렬 처리
- **증분 빌드**: 변경된 패키지만 다시 빌드
- **원격 캐시**: 팀 전체가 빌드 캐시 공유
- **통합 개발**: 하나의 명령어로 전체 스택 실행

### ✅ 코드 품질
- **일관된 코드 스타일**: 전체 프로젝트 통일된 린트/포맷팅
- **공유 설정**: TypeScript, ESLint, Prettier 등 중앙 관리
- **자동 Git 훅**: 커밋 전 자동 품질 검사
- **Conventional Commits**: 표준화된 커밋 메시지

### ✅ 배포 자동화
- **의존성 기반 빌드**: 변경사항에 따른 선택적 배포
- **통합 CI/CD**: GitHub Actions로 완전 자동화
- **버전 관리**: Changesets으로 체계적인 릴리스

## 📦 워크스페이스 구조

```
routine-quest-app/
├── 📱 client/          # Flutter (iOS/Android/Web)
├── 🚀 api/             # FastAPI 백엔드
├── 🤖 ai/              # AI 마이크로서비스
├── 🔧 shared/          # 공유 타입/유틸리티 (TypeScript)
├── 🐳 docker/          # Docker 컨테이너 설정
├── 📝 scripts/         # 개발/배포 자동화 스크립트
├── 🏗️ .github/        # CI/CD 워크플로우
├── 🔧 .husky/          # Git 훅
└── 📋 .changeset/      # 버전 관리
```

## 🚀 빠른 시작

### 1️⃣ 초기 설정

```bash
# 전체 환경 설정 (한 번만 실행)
./scripts/setup.sh

# 또는 개별 설치
pnpm install                    # Node.js 의존성
python -m venv venv && source venv/bin/activate
pip install -r api/requirements.txt
pip install -r ai/requirements.txt
cd client && flutter pub get   # Flutter 의존성
```

### 2️⃣ 개발 서버 실행

```bash
# 🏗️ Turborepo로 모든 서비스 병렬 실행
pnpm dev

# 또는 기존 방식
./scripts/dev.sh

# 개별 서비스 실행
pnpm dev --filter=@routine-quest/api     # 백엔드만
pnpm dev --filter=@routine-quest/client  # 프론트엔드만
```

### 3️⃣ 주요 명령어

```bash
# 🏗️ 빌드
pnpm build                      # 전체 빌드
pnpm build --filter=shared      # 특정 패키지만

# 🧪 테스트
pnpm test                       # 전체 테스트
pnpm test:coverage              # 커버리지 포함
./scripts/test.sh unit          # 유닛 테스트만

# 🔍 코드 품질
pnpm lint                       # 린트 검사
pnpm lint:fix                   # 자동 수정
./scripts/lint.sh fix           # 전체 프로젝트 포맷팅

# 🧹 정리
pnpm clean                      # 빌드 결과물 삭제
turbo prune --scope=api         # 특정 패키지 정리
```

## 🔄 워크플로우 가이드

### 📝 커밋 프로세스

```bash
# 1. 코드 작성 후
git add .

# 2. 커밋 (Conventional Commits 형식 필수)
git commit -m "feat(api): add user authentication endpoint"

# 3. Pre-commit 훅이 자동으로 실행
#    - 코드 포맷팅 검사
#    - 린트 검사  
#    - 타입 검사

# 4. 푸시
git push origin feature-branch
```

#### 커밋 메시지 형식
```
type(scope): description

타입: feat, fix, docs, style, refactor, test, chore, ci, build, perf
스코프: api, ai, client, shared, docker, scripts (선택적)

예시:
feat(api): add user authentication endpoint
fix(client): resolve navigation bug  
docs: update README with monorepo setup
chore(ci): update GitHub Actions workflow
```

### 🏷️ 릴리스 프로세스

```bash
# 1. 변경사항 기록
pnpm changeset
# - 변경 타입 선택 (major/minor/patch)
# - 변경 내용 설명 작성

# 2. 릴리스 준비
./scripts/release.sh prepare
# - 코드 품질 검사
# - 전체 테스트 실행
# - 빌드 테스트

# 3. 버전 업데이트
pnpm changeset version
# - package.json 버전 업데이트
# - CHANGELOG.md 생성/업데이트

# 4. 커밋 및 푸시
git add . && git commit -m "chore: release v1.2.0"
git push origin main

# 5. GitHub Actions가 자동으로 릴리스 생성
```

### 🔧 개발 패턴

#### 새로운 패키지 추가
```bash
# 1. 패키지 디렉토리 생성
mkdir packages/new-package

# 2. package.json 생성
cat > packages/new-package/package.json << EOF
{
  "name": "@routine-quest/new-package",
  "version": "1.0.0",
  "private": true
}
EOF

# 3. pnpm-workspace.yaml에 추가
echo "  - 'packages/new-package'" >> pnpm-workspace.yaml

# 4. turbo.json에 빌드 설정 추가
```

#### 패키지 간 의존성 추가
```bash
# shared 패키지를 api에 추가
pnpm --filter=@routine-quest/api add @routine-quest/shared

# 외부 패키지 추가
pnpm --filter=@routine-quest/client add lodash
pnpm --filter=@routine-quest/api add fastapi
```

## 🔧 도구별 상세 설정

### Turborepo
- **파일**: `turbo.json`
- **캐시**: `.turbo/` (로컬), 원격 캐시 지원
- **병렬성**: CPU 코어 수에 따라 자동 조정
- **의존성**: 패키지 간 의존성 기반 실행 순서

### PNPM 워크스페이스
- **파일**: `pnpm-workspace.yaml`, `package.json`
- **호이스팅**: 공통 의존성 루트로 끌어올림
- **링크**: 로컬 패키지 간 심볼릭 링크
- **효율성**: npm/yarn 대비 3배 빠른 설치

### Git 훅 (Husky)
- **Pre-commit**: 코드 품질 자동 검사
- **Commit-msg**: Conventional Commits 형식 검증
- **설정**: `.husky/` 디렉토리

### CI/CD (GitHub Actions)
- **PR 검사**: 린트, 테스트, 빌드 검증
- **릴리스**: main 브랜치 푸시 시 자동 릴리스
- **Docker**: 변경사항 기반 컨테이너 빌드

## 📊 성능 비교

| 항목 | 기존 방식 | 모노레포 |
|------|----------|----------|
| 개발 서버 시작 | 3개 터미널 필요 | 1개 명령어 |
| 전체 빌드 시간 | ~5분 | ~2분 (캐시 활용) |
| 테스트 실행 | 순차 실행 | 병렬 실행 |
| 의존성 설치 | 3번 실행 | 1번 실행 |
| 코드 품질 검사 | 수동 | 자동 (Git 훅) |

## 🔍 문제 해결

### 일반적인 문제

```bash
# 캐시 문제
pnpm turbo clean && pnpm install

# 특정 패키지 재설치
pnpm --filter=@routine-quest/api install

# Python 환경 재설정
rm -rf venv && python -m venv venv
source venv/bin/activate && pip install -r api/requirements.txt

# Flutter 캐시 정리
cd client && flutter clean && flutter pub get
```

### 성능 최적화

```bash
# 선택적 필터링 (변경된 패키지만)
pnpm turbo test --filter="...[HEAD^1]"

# 병렬성 조정
pnpm turbo build --concurrency=4

# 원격 캐시 활용 (설정 필요)
export TURBO_TOKEN=your-token
export TURBO_TEAM=your-team
```

## 🚀 다음 단계

1. **팀 온보딩**: 팀원들에게 새로운 워크플로우 공유
2. **원격 캐시**: Vercel/커스텀 캐시 서버 설정
3. **배포 자동화**: Kubernetes/Docker 배포 파이프라인 구축
4. **모니터링**: 빌드 시간, 테스트 커버리지 추적

---

**🎉 축하합니다! Routine Quest App이 최신 모노레포로 업그레이드되었습니다.**

더 자세한 정보는 각 패키지의 README.md를 참고하거나, [Turborepo 공식 문서](https://turbo.build/repo/docs)를 확인하세요.