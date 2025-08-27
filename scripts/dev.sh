#!/bin/bash
# 🚀 개발 서버 실행 스크립트 (Turborepo)
# 백엔드 API, AI 서비스, Flutter 웹을 동시에 실행

set -e

echo "🎯 Routine Quest 모노레포 개발 서버를 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 📄 환경변수 로드
if [ -f ".env" ]; then
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️ .env 파일이 없습니다. setup.sh를 먼저 실행해주세요."
    exit 1
fi

# 🐍 Python 가상환경 활성화
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# 🏗️ Turborepo를 사용하여 모든 서비스 병렬 실행
echo "🏗️ Turborepo를 통해 모든 개발 서버를 병렬 실행합니다..."
echo ""
echo "📡 서비스 URL:"
echo "  • 백엔드 API: http://localhost:8000"
echo "  • API 문서: http://localhost:8000/docs"
echo "  • AI 서비스: http://localhost:8001"
echo "  • Flutter 웹: http://localhost:3000"
echo ""
echo "🛑 종료하려면 Ctrl+C를 누르세요."
echo ""

# Turborepo dev 명령어 실행 (모든 패키지의 dev 스크립트를 병렬 실행)
pnpm turbo dev --parallel

# 🏥 서비스 상태 확인 함수
check_service() {
    local url=$1
    local name=$2
    local max_attempts=30
    local attempt=1
    
    echo "⏳ $name 서비스 대기 중..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" $url | grep -q "200\|404"; then
            echo "✅ $name 서비스가 준비되었습니다!"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "❌ $name 서비스 시작에 실패했습니다."
    return 1
}

# 📊 서비스들이 준비될 때까지 대기
sleep 5
check_service "http://localhost:8000/health" "백엔드 API"
check_service "http://localhost:8001/health" "AI 서비스"
check_service "http://localhost:3000" "Flutter 웹"

# 📋 정보 출력
echo ""
echo "🎉 모든 서비스가 실행되었습니다!"
echo ""
echo "📡 서비스 URL:"
echo "  • 백엔드 API: http://localhost:8000"
echo "  • API 문서: http://localhost:8000/docs"
echo "  • AI 서비스: http://localhost:8001"
echo "  • Flutter 웹: http://localhost:3000"
echo ""
echo "🛑 종료하려면 Ctrl+C를 누르세요."

# 🔚 종료 신호 처리
cleanup() {
    echo ""
    echo "🛑 서비스들을 종료하는 중..."
    kill $API_PID $AI_PID $FLUTTER_PID 2>/dev/null || true
    wait
    echo "✅ 모든 서비스가 종료되었습니다."
    exit 0
}

trap cleanup SIGINT SIGTERM

# 🔄 무한 대기 (Ctrl+C로 종료할 때까지)
while true; do
    sleep 1
done