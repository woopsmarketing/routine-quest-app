#!/bin/bash
# 🏗️ 전체 프로젝트 빌드 스크립트
# 모든 서비스와 클라이언트를 프로덕션용으로 빌드

set -e

echo "🏗️ Routine Quest 전체 프로젝트 빌드를 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 🧹 빌드 전 클린업
echo "🧹 이전 빌드 결과물 클린업..."
pnpm turbo clean

# 🏗️ Turborepo를 사용하여 모든 패키지 빌드
echo "🏗️ Turborepo를 통해 모든 패키지를 빌드합니다..."
pnpm turbo build

# 📊 빌드 결과 리포트
echo ""
echo "✅ 빌드가 완료되었습니다!"
echo ""
echo "📦 빌드 결과물:"
echo "  • Shared 패키지: shared/dist/"
echo "  • Flutter 웹: client/build/web/"
echo "  • 백엔드 API: 소스코드 기반 (빌드 불필요)"
echo "  • AI 서비스: 소스코드 기반 (빌드 불필요)"
echo ""
echo "🚢 배포 준비 완료!"