#!/bin/bash
# 🚀 버전 관리 및 릴리스 스크립트
# Changesets을 사용한 버전 업데이트 및 릴리스

set -e

echo "🚀 Routine Quest 릴리스 프로세스를 시작합니다..."

# 📁 현재 위치 확인
if [ ! -f "README.md" ]; then
    echo "❌ 프로젝트 루트에서 실행해주세요."
    exit 1
fi

# 릴리스 모드 선택
MODE=${1:-"prepare"}

case $MODE in
    "changeset")
        echo "📝 새로운 changeset을 생성합니다..."
        pnpm changeset
        echo "✅ Changeset 생성 완료!"
        echo "💡 변경사항을 커밋하고 PR을 생성하세요."
        ;;
        
    "version")
        echo "🏷️ 버전을 업데이트합니다..."
        
        # 미해결 changeset이 있는지 확인
        if [ ! "$(ls -A .changeset/*.md 2>/dev/null | grep -v README)" ]; then
            echo "❌ 적용할 changeset이 없습니다."
            echo "💡 'pnpm changeset' 명령어로 changeset을 먼저 생성하세요."
            exit 1
        fi
        
        # 버전 업데이트
        pnpm changeset version
        
        echo "✅ 버전 업데이트 완료!"
        echo "💡 변경된 package.json과 CHANGELOG.md를 확인하고 커밋하세요."
        ;;
        
    "publish")
        echo "📦 패키지를 배포합니다..."
        
        # 빌드 먼저 실행
        echo "🏗️ 배포 전 빌드..."
        pnpm turbo build
        
        # 배포 실행 (실제 배포는 CI/CD에서 수행)
        echo "📤 배포 준비 완료!"
        echo "💡 실제 배포는 CI/CD 파이프라인에서 자동으로 수행됩니다."
        ;;
        
    "status")
        echo "📊 현재 changeset 상태를 확인합니다..."
        pnpm changeset status
        ;;
        
    "prepare"|*)
        echo "🔄 릴리스 준비 프로세스..."
        
        # 1. 코드 품질 검사
        echo "🔍 코드 품질 검사..."
        ./scripts/lint.sh check
        
        # 2. 테스트 실행
        echo "🧪 전체 테스트 실행..."
        ./scripts/test.sh
        
        # 3. 빌드 테스트
        echo "🏗️ 빌드 테스트..."
        pnpm turbo build
        
        echo "✅ 릴리스 준비 완료!"
        echo ""
        echo "다음 단계:"
        echo "1. ./scripts/release.sh changeset  # 변경사항 기록"
        echo "2. ./scripts/release.sh version    # 버전 업데이트"
        echo "3. git commit && git push         # 변경사항 커밋"
        echo "4. Create Pull Request            # PR 생성"
        ;;
esac

echo ""
echo "📚 릴리스 가이드:"
echo "  • changeset: 새로운 변경사항 기록"
echo "  • version:   버전 업데이트 적용"
echo "  • publish:   배포 준비"
echo "  • status:    현재 상태 확인"
echo "  • prepare:   릴리스 전 품질 검사"