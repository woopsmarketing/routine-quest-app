#!/bin/bash
# 🔍 전체 프로젝트 린트 및 포맷팅 스크립트
# 모든 서비스의 코드 품질 검사 및 자동 수정

set -e

echo "🔍 Routine Quest 코드 품질 검사를 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 🐍 Python 가상환경 활성화
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
    source venv/Scripts/activate
else
    source venv/bin/activate
fi

# 작업 모드 선택
MODE=${1:-"check"}

case $MODE in
    "fix")
        echo "🔧 코드를 자동으로 수정합니다..."
        
        # TypeScript/JavaScript 포맷팅
        echo "📝 TypeScript/JavaScript 포맷팅..."
        pnpm format
        
        # Turborepo를 통한 각 패키지의 자동 수정
        echo "🔧 각 패키지의 린트 자동 수정..."
        pnpm turbo lint:fix
        
        echo "✅ 코드 자동 수정이 완료되었습니다!"
        ;;
        
    "check"|*)
        echo "🔍 코드 품질을 검사합니다..."
        
        # 포맷팅 검사
        echo "📝 코드 포맷팅 검사..."
        pnpm format:check
        
        # Turborepo를 통한 각 패키지의 린트 검사
        echo "🔍 각 패키지의 린트 검사..."
        pnpm turbo lint
        
        # 타입 체크
        echo "🔍 타입 검사..."
        pnpm turbo type-check
        
        echo "✅ 코드 품질 검사가 완료되었습니다!"
        ;;
esac

echo ""
echo "📊 검사 결과:"
echo "  • TypeScript: ESLint + Prettier"
echo "  • Python: Ruff + Black + MyPy"  
echo "  • Dart/Flutter: dart analyze + dart format"
echo ""
echo "💡 수정하려면: ./scripts/lint.sh fix"