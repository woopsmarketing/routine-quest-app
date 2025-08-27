#!/bin/bash
# 🛠️ 루틴 퀘스트 모노레포 환경 셋업 스크립트
# 전체 프로젝트를 처음 설정할 때 실행하는 스크립트

set -e

echo "🎯 Routine Quest 모노레포 환경 설정을 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 📦 Node.js 및 PNPM 설치 확인
echo "📦 Node.js 및 PNPM 환경 확인 중..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js가 설치되어 있지 않습니다. Node.js 18+ 를 설치해주세요."
    exit 1
fi

if ! command -v pnpm &> /dev/null; then
    echo "📦 PNPM 설치 중..."
    npm install -g pnpm
fi

echo "✅ Node.js $(node --version) 및 PNPM $(pnpm --version) 확인됨"

# 🏗️ Monorepo 의존성 설치
echo "🏗️ 모노레포 의존성 설치 중..."
pnpm install

# 🐍 Python 가상환경 생성 및 활성화 (백엔드용)
echo "📦 Python 가상환경 설정 중..."
if [ ! -d "venv" ]; then
    python -m venv venv
fi

# OS별 가상환경 활성화
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# 🚀 백엔드 API 의존성 설치
echo "🔧 백엔드 API 의존성 설치 중..."
cd api
pip install -r requirements.txt
cd ..

# 🤖 AI 서비스 의존성 설치 
echo "🧠 AI 서비스 의존성 설치 중..."
cd ai
pip install -r requirements.txt
cd ..

# 📱 Flutter 설정
echo "📱 Flutter 설정 중..."
cd client

# Flutter 의존성 설치
flutter pub get

# 코드 생성 (Riverpod, JSON 등)
flutter packages pub run build_runner build

cd ..

# 🔄 Shared 패키지 빌드
echo "🔄 공유 패키지 빌드 중..."
cd shared
pnpm run build
cd ..

# 🐳 Docker 환경 확인
echo "🐳 Docker 환경 확인 중..."
if command -v docker &> /dev/null; then
    echo "✅ Docker가 설치되어 있습니다."
    if command -v docker-compose &> /dev/null; then
        echo "✅ Docker Compose가 설치되어 있습니다."
    else
        echo "⚠️ Docker Compose가 필요합니다."
    fi
else
    echo "⚠️ Docker가 설치되어 있지 않습니다."
fi

# 📄 환경변수 파일 생성
echo "📄 환경변수 파일 설정 중..."
if [ ! -f ".env" ]; then
    cat > .env << EOF
# 🔧 개발 환경 설정
ENVIRONMENT=development

# 🗄️ 데이터베이스
POSTGRES_SERVER=localhost
POSTGRES_USER=routine_user
POSTGRES_PASSWORD=routine_password
POSTGRES_DB=routine_quest

# 🔄 Redis
REDIS_URL=redis://localhost:6379

# 🔐 보안
SECRET_KEY=dev-secret-key-change-in-production

# 🔥 Firebase (실제 값으로 변경 필요)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email

# 🤖 AI 서비스 API 키들 (실제 값으로 변경 필요)
OPENAI_API_KEY=your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key

# 📊 모니터링
SENTRY_DSN=your-sentry-dsn
EOF
    echo "✅ .env 파일이 생성되었습니다. 실제 API 키들을 설정해주세요."
else
    echo "✅ .env 파일이 이미 존재합니다."
fi

# 🎉 완료 메시지
echo ""
echo "🎉 설정이 완료되었습니다!"
echo ""
echo "다음 단계:"
echo "1. .env 파일에서 실제 API 키들을 설정하세요"
echo "2. 개발 서버 실행: ./scripts/dev.sh"
echo "3. 또는 Docker로 실행: cd docker && docker-compose up"
echo ""