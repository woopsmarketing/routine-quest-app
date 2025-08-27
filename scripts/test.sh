#!/bin/bash
# 🧪 전체 프로젝트 테스트 실행 스크립트
# 모든 서비스의 테스트를 순차적/병렬로 실행

set -e

echo "🧪 Routine Quest 전체 테스트 실행을 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 🐍 Python 가상환경 활성화 (백엔드 테스트용)
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# 🧪 Turborepo를 사용하여 모든 테스트 실행
echo "🧪 모든 패키지의 테스트를 실행합니다..."

# 테스트 실행 모드 선택 (인자로 전달 가능)
TEST_MODE=${1:-"all"}

case $TEST_MODE in
    "unit")
        echo "🔬 유닛 테스트만 실행합니다..."
        pnpm turbo test:unit
        ;;
    "integration") 
        echo "🔗 통합 테스트만 실행합니다..."
        pnpm turbo test:integration
        ;;
    "coverage")
        echo "📊 커버리지 포함 전체 테스트를 실행합니다..."
        pnpm turbo test:coverage
        ;;
    "all"|*)
        echo "🔄 전체 테스트를 실행합니다..."
        pnpm turbo test
        ;;
esac

# 📊 테스트 결과 리포트
echo ""
echo "✅ 테스트가 완료되었습니다!"
echo ""
echo "📊 테스트 결과:"
echo "  • Flutter: client/coverage/"
echo "  • 백엔드 API: api/coverage/"
echo "  • AI 서비스: ai/coverage/"
echo "  • Shared: shared/coverage/"
echo ""

# 커버리지 리포트 통합 (선택적)
if [ "$TEST_MODE" = "coverage" ]; then
    echo "📈 전체 커버리지 리포트를 생성 중..."
    echo "  각 서비스별 커버리지는 위 경로에서 확인하세요."
fi