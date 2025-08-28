# 🚀 다른 PC에서 개발환경 설정 가이드

새로운 컴퓨터에서 Routine Quest App 개발을 시작하기 위한 완전한 설정 가이드입니다.

## 📋 설정 체크리스트

### ✅ **필수 사전 설치**

- [ ] **Node.js** (v18+) - [nodejs.org](https://nodejs.org)
- [ ] **Python** (3.11+) - [python.org](https://python.org)
- [ ] **Flutter SDK** (3.16.0+) - [flutter.dev](https://flutter.dev)
- [ ] **Git** - [git-scm.com](https://git-scm.com)
- [ ] **GitHub CLI** - [cli.github.com](https://cli.github.com)
- [ ] **PNPM** - `npm install -g pnpm`
- [ ] **Docker Desktop** (선택) - [docker.com](https://docker.com)

---

## 🔽 **1단계: 저장소 복제**

```bash
# 저장소 클론
git clone https://github.com/woopsmarketing/routine-quest-app.git
cd routine-quest-app

# 모든 브랜치 확인
git branch -a

# 개발용 브랜치들 생성 (필요시)
git checkout -b feature/cursor-setup origin/feature/cursor-setup
git checkout -b feature/claude-setup origin/feature/claude-setup
```

---

## ⚙️ **2단계: 환경 변수 설정**

### **환경 변수 파일 생성 (수동 필요)**

#### **🔐 루트 디렉토리 `.env`**

```bash
# 🌍 글로벌 환경 설정
NODE_ENV=development
DEBUG=true

# 🔑 API 키들 (실제 값으로 변경 필요)
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# 🗄️ 데이터베이스
DATABASE_URL=postgresql://user:password@localhost:5432/routine_quest_dev
REDIS_URL=redis://localhost:6379

# 🔒 JWT 시크릿 (랜덤 생성 권장)
JWT_SECRET_KEY=your_super_secret_jwt_key_here

# 📱 Firebase 설정
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_WEB_API_KEY=your_firebase_web_api_key
```

#### **🐍 API 서비스 `api/.env`**

```bash
# FastAPI 설정
APP_NAME=Routine Quest API
APP_VERSION=1.0.0
DEBUG=true
SECRET_KEY=your_super_secret_fastapi_key

# 데이터베이스
DATABASE_URL=postgresql://user:password@localhost:5432/routine_quest_dev
TEST_DATABASE_URL=postgresql://user:password@localhost:5432/routine_quest_test

# Redis 캐시
REDIS_URL=redis://localhost:6379/0

# AI 서비스
AI_SERVICE_URL=http://localhost:8001
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key

# 파일 업로드
UPLOAD_MAX_SIZE=10485760  # 10MB
UPLOAD_PATH=/tmp/uploads
```

#### **🤖 AI 서비스 `ai/.env`**

```bash
# AI 서비스 설정
SERVICE_NAME=Routine Quest AI
DEBUG=true

# LLM API 키
OPENAI_API_KEY=your_openai_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key

# 캐시 설정
REDIS_URL=redis://localhost:6379/1
CACHE_TTL=3600

# 요청 제한
RATE_LIMIT_PER_MINUTE=60
MAX_TOKENS_PER_REQUEST=4000
```

---

## 📦 **3단계: 의존성 설치**

```bash
# 🌍 모노레포 전체 의존성 설치
pnpm install

# 🐍 Python 가상환경 생성 및 설정
cd api
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt

# 🤖 AI 서비스 의존성
cd ../ai
pip install -r requirements.txt

# 📱 Flutter 의존성
cd ../client
flutter pub get

# 루트로 복귀
cd ..
```

---

## 🗄️ **4단계: 데이터베이스 설정**

### **PostgreSQL + Redis (Docker 사용)**

```bash
# Docker로 개발용 DB 실행
cd docker
docker-compose up -d

# 또는 수동 실행
docker run -d --name postgres-dev \
  -e POSTGRES_USER=routine_quest \
  -e POSTGRES_PASSWORD=dev_password \
  -e POSTGRES_DB=routine_quest_dev \
  -p 5432:5432 postgres:15

docker run -d --name redis-dev \
  -p 6379:6379 redis:7-alpine
```

### **데이터베이스 마이그레이션**

```bash
cd api
alembic upgrade head
```

---

## 🔥 **5단계: Firebase 설정**

### **Firebase 프로젝트 설정**

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 새 프로젝트 생성 또는 기존 프로젝트 선택
3. **Authentication** 활성화 (Google, 이메일/비밀번호)
4. **Firestore Database** 생성
5. **Web 앱** 추가

### **설정 파일 생성**

```bash
# Flutter Firebase 설정
cd client
firebase login
firebase init
# 또는 기존 설정을 firebase-config.json에 추가

# Web 설정
flutterfire configure
```

---

## 🛠️ **6단계: 개발 도구 설정**

### **GitHub CLI 인증**

```bash
gh auth login
```

### **바이브코딩 스크립트 권한 설정**

```bash
# Linux/Mac
chmod +x scripts/*.sh

# Windows (Git Bash)
find scripts -name "*.sh" -exec chmod +x {} \;
```

### **VS Code 확장 프로그램 (권장)**

- **Flutter** - Dart/Flutter 지원
- **Python** - Python 언어 지원
- **Pylance** - Python 언어 서버
- **ESLint** - JavaScript/TypeScript 린터
- **GitLens** - Git 향상 도구
- **Thunder Client** - API 테스트
- **Docker** - Docker 지원

---

## 🚀 **7단계: 개발 서버 실행**

### **전체 스택 실행 (권장)**

```bash
# 모든 서비스 한 번에 실행
pnpm dev

# 개별 서비스 접속 확인
# - Frontend: http://localhost:3000
# - API: http://localhost:8000/docs
# - AI Service: http://localhost:8001
```

### **개별 서비스 실행**

```bash
# 백엔드 API만
pnpm dev --filter=@routine-quest/api

# 프론트엔드만
pnpm dev --filter=@routine-quest/client

# AI 서비스만
cd ai && python -m uvicorn app.main:app --reload --port 8001
```

---

## ✅ **8단계: 설치 검증**

### **헬스체크 스크립트 실행**

```bash
# 전체 환경 검사
./scripts/dev.sh --check

# 또는 수동 확인
curl http://localhost:8000/health     # API 서버
curl http://localhost:8001/health     # AI 서비스
flutter doctor                        # Flutter 환경
```

### **테스트 실행**

```bash
# 전체 테스트
pnpm test

# 개별 테스트
cd api && pytest                      # Python 테스트
cd client && flutter test             # Flutter 테스트
```

---

## 🎯 **바이브코딩 환경 확인**

### **자동화 스크립트 테스트**

```bash
# Cursor AI 스크립트
./scripts/cursor-upload.sh --test

# Claude Code 스크립트
./scripts/claude-upload.sh --test

# CI/CD 워크플로우 확인
git push origin feature/cursor-setup  # Actions 실행 확인
```

---

## 🔧 **문제 해결**

### **일반적인 문제**

#### **PNPM 설치 실패**

```bash
npm install -g pnpm@latest
pnpm --version
```

#### **Flutter Doctor 오류**

```bash
flutter doctor --verbose
flutter clean && flutter pub get
```

#### **Python 가상환경 문제**

```bash
python -m venv .venv --clear
# Windows
.venv\Scripts\activate && pip install -r requirements.txt
# Linux/Mac
source .venv/bin/activate && pip install -r requirements.txt
```

#### **데이터베이스 연결 오류**

```bash
# Docker 컨테이너 상태 확인
docker ps -a

# 포트 충돌 확인
netstat -an | grep 5432  # PostgreSQL
netstat -an | grep 6379  # Redis
```

#### **Firebase 설정 오류**

```bash
# Firebase CLI 재설치
npm install -g firebase-tools@latest
firebase login --reauth
```

---

## 📁 **중요한 로컬 전용 파일들**

### **⚠️ Git에 커밋하면 안 되는 파일들**

```
.env                     # 환경 변수
.env.local              # 로컬 환경 변수
api/.venv/              # Python 가상환경
node_modules/           # NPM 패키지들
client/build/           # Flutter 빌드 결과
.vscode/settings.json   # 개인 VS Code 설정
firebase-config.json    # Firebase 실제 설정
*.key                   # 개인 키 파일
```

### **✅ 개발팀과 공유되는 파일들**

```
.cursorrules           # Cursor AI 설정
CLAUDE.md             # Claude Code 규칙
scripts/              # 자동화 스크립트들
.github/workflows/    # CI/CD 파이프라인
docker-compose.yml    # 개발용 Docker 설정
```

---

## 🎵 **바이브코딩 시작하기**

환경 설정이 완료되면 바이브코딩을 시작할 수 있습니다:

```bash
# 1. 브랜치 전환
git checkout feature/cursor-setup    # Cursor AI 사용 시
git checkout feature/claude-setup    # Claude Code 사용 시

# 2. 개발 시작
# ... 코딩 작업 ...

# 3. 자동 업로드
"업로드해줘"                          # AI에게 명령

# 4. 작업 완료
"작업 완료" 또는 "검토 완료"           # PR 자동 생성
```

---

## 📞 **추가 도움이 필요한 경우**

- 📚 **문서**: `docs/` 폴더의 상세 가이드 참조
- 🐛 **버그 리포트**: GitHub Issues 활용
- 💬 **질문**: GitHub Discussions 또는 팀 채널

---

**🎉 설정 완료! 이제 다른 PC에서도 동일한 개발환경에서 바이브코딩을 시작할 수 있습니다!**
