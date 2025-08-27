#!/bin/bash

# 🔄 Vibecoding Sync Script
# 30분마다 실행되는 바이브코딩 동기화 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 이모지 정의
SYNC="🔄"
CHECK="✅"
WARN="⚠️"
INFO="💡"
ROCKET="🚀"

echo -e "${PURPLE}${SYNC} ===============================================${NC}"
echo -e "${PURPLE}${SYNC}        Vibecoding Sync (30분 체크포인트)      ${NC}"
echo -e "${PURPLE}${SYNC} ===============================================${NC}"
echo ""

# 1. 세션 설정 로드
VIBE_CONFIG=".vibecoding-session.json"
if [ ! -f "$VIBE_CONFIG" ]; then
    echo -e "${RED}${WARN} 바이브코딩 세션이 시작되지 않았습니다.${NC}"
    echo -e "${INFO} './scripts/vibecoding-start.sh'를 먼저 실행하세요.${NC}"
    exit 1
fi

# JSON 파싱 (jq가 없는 경우를 위한 간단한 방법)
SESSION_TYPE=$(grep -o '"session_type": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
BRANCH_NAME=$(grep -o '"branch_name": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
FEATURE_NAME=$(grep -o '"feature_name": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)

echo -e "${BLUE}${INFO} 세션 정보: ${SESSION_TYPE} - ${FEATURE_NAME}${NC}"
echo -e "${BLUE}${INFO} 현재 브랜치: ${BRANCH_NAME}${NC}"
echo ""

# 2. 현재 상태 확인
echo -e "${CYAN}${INFO} Git 상태 확인...${NC}"
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
    echo -e "${YELLOW}${WARN} 예상 브랜치: $BRANCH_NAME, 현재 브랜치: $CURRENT_BRANCH${NC}"
    read -p "올바른 브랜치로 전환하시겠습니까? (y/n): " switch_branch
    if [[ $switch_branch =~ ^[Yy]$ ]]; then
        git checkout "$BRANCH_NAME"
    fi
fi

# 3. 변경사항 확인
CHANGED_FILES=$(git status --porcelain)
if [ -z "$CHANGED_FILES" ]; then
    echo -e "${YELLOW}${WARN} 변경된 파일이 없습니다.${NC}"
    echo -e "${INFO} 작업을 진행한 후 다시 동기화하세요.${NC}"
    exit 0
fi

echo -e "${GREEN}변경된 파일들:${NC}"
git status --short
echo ""

# 4. 품질 검사 (빠른 버전)
echo -e "${CYAN}${INFO} 빠른 품질 검사 중...${NC}"

# 린트 체크 (변경된 파일만)
echo -e "${INFO} 린트 검사...${NC}"
if command -v pnpm >/dev/null 2>&1; then
    # 변경된 파일만 체크
    CHANGED_JS_TS=$(echo "$CHANGED_FILES" | grep -E '\.(js|ts|tsx|jsx)$' | cut -c4- || true)
    if [ ! -z "$CHANGED_JS_TS" ]; then
        echo "변경된 JS/TS 파일 린트 체크..."
        pnpm lint --fix 2>/dev/null || echo -e "${YELLOW}${WARN} 린트 경고가 있습니다.${NC}"
    fi
    
    CHANGED_PY=$(echo "$CHANGED_FILES" | grep -E '\.py$' | cut -c4- || true)  
    if [ ! -z "$CHANGED_PY" ]; then
        echo "변경된 Python 파일 린트 체크..."
        ruff check --fix $CHANGED_PY 2>/dev/null || echo -e "${YELLOW}${WARN} Python 린트 경고가 있습니다.${NC}"
    fi
else
    echo -e "${YELLOW}${WARN} PNPM이 없습니다. 린트 검사를 건너뜁니다.${NC}"
fi

# 5. 커밋 준비
echo ""
echo -e "${CYAN}${INFO} 변경사항을 커밋합니다...${NC}"

# 진행 상태 확인
echo ""
echo -e "${CYAN}${INFO} 현재 기능 개발 상태를 선택하세요:${NC}"
echo "1) 🚧 개발 진행 중 (work in progress)"
echo "2) 🔍 리뷰 준비됨 (ready for review)"  
echo "3) ✅ 기능 완성 (feature complete)"
read -p "선택 (1-3): " progress_status

case $progress_status in
    1)
        PROGRESS_STATUS="wip"
        COMMIT_PREFIX="wip"
        echo -e "${YELLOW}개발 진행 중으로 설정${NC}"
        ;;
    2)
        PROGRESS_STATUS="ready"
        COMMIT_PREFIX="feat"
        echo -e "${BLUE}리뷰 준비됨으로 설정${NC}"
        ;;
    3)
        PROGRESS_STATUS="complete"
        COMMIT_PREFIX="feat"
        echo -e "${GREEN}기능 완성으로 설정${NC}"
        ;;
    *)
        PROGRESS_STATUS="wip"
        COMMIT_PREFIX="wip"
        echo -e "${YELLOW}기본값: 개발 진행 중${NC}"
        ;;
esac

# 커밋 메시지 생성 (진행 상태별)
if [ "$PROGRESS_STATUS" = "complete" ]; then
    COMMIT_MSG="$COMMIT_PREFIX($FEATURE_NAME): 기능 완성 - complete

✅ 기능 구현 완료
- 바이브코딩 세션: $SESSION_TYPE
- 테스트 및 검증 완료
- develop 브랜치로 PR 준비"
elif [ "$PROGRESS_STATUS" = "ready" ]; then
    COMMIT_MSG="$COMMIT_PREFIX($FEATURE_NAME): 리뷰 준비 완료

🔍 코드 리뷰 요청
- 바이브코딩 세션: $SESSION_TYPE
- 주요 기능 구현 완료"
else
    COMMIT_MSG="$COMMIT_PREFIX($FEATURE_NAME): 진행 상황 업데이트

🚧 개발 진행 중
- 바이브코딩 세션: $SESSION_TYPE
- 작업 내용: [간단히 설명]"
fi

# 사용자 확인
echo -e "${YELLOW}커밋 메시지:${NC}"
echo "$COMMIT_MSG"
echo ""
read -p "이 메시지로 커밋하시겠습니까? (y/n/c): " commit_choice

case $commit_choice in
    y|Y)
        git add -A
        git commit -m "$COMMIT_MSG"
        echo -e "${GREEN}${CHECK} 커밋 완료${NC}"
        ;;
    c|C)
        echo "커스텀 커밋 메시지를 입력하세요:"
        read -p "제목: " custom_title
        read -p "설명 (선택): " custom_desc
        
        if [ ! -z "$custom_desc" ]; then
            CUSTOM_MSG="$custom_title

$custom_desc

바이브코딩 세션: $SESSION_TYPE (스프린트 $SPRINT_COUNT)"
        else
            CUSTOM_MSG="$custom_title

바이브코딩 세션: $SESSION_TYPE (스프린트 $SPRINT_COUNT)"
        fi
        
        git add -A
        git commit -m "$CUSTOM_MSG"
        echo -e "${GREEN}${CHECK} 커스텀 커밋 완료${NC}"
        ;;
    *)
        echo -e "${YELLOW}${WARN} 커밋을 건너뜁니다.${NC}"
        exit 0
        ;;
esac

# 6. 원격 브랜치로 푸시
echo -e "${CYAN}${INFO} 원격 저장소로 푸시...${NC}"
git push origin "$BRANCH_NAME" || git push --set-upstream origin "$BRANCH_NAME"
echo -e "${GREEN}${CHECK} 푸시 완료${NC}"

# 7. develop 브랜치와 동기화 확인
echo ""
echo -e "${CYAN}${INFO} develop 브랜치 동기화 확인...${NC}"
git fetch origin develop

# 충돌 확인
MERGE_BASE=$(git merge-base HEAD origin/develop)
CURRENT_COMMIT=$(git rev-parse HEAD)
DEVELOP_COMMIT=$(git rev-parse origin/develop)

if [ "$MERGE_BASE" != "$DEVELOP_COMMIT" ]; then
    echo -e "${YELLOW}${WARN} develop 브랜치에 새로운 변경사항이 있습니다.${NC}"
    
    # 충돌 체크
    if ! git merge-tree "$MERGE_BASE" HEAD origin/develop | grep -q '^conflict:'; then
        echo -e "${GREEN}${CHECK} 자동 머지가 가능합니다.${NC}"
        read -p "지금 develop을 머지하시겠습니까? (y/n): " merge_now
        if [[ $merge_now =~ ^[Yy]$ ]]; then
            git merge origin/develop --no-edit
            git push origin "$BRANCH_NAME"
            echo -e "${GREEN}${CHECK} develop 브랜치 동기화 완료${NC}"
        fi
    else
        echo -e "${RED}${WARN} 충돌이 감지되었습니다!${NC}"
        echo -e "${INFO} 팀원과 상의한 후 수동으로 해결하세요.${NC}"
        echo -e "${INFO} 명령어: git merge origin/develop${NC}"
    fi
fi

# 8. 기능 완성 시 자동 PR 안내
if [ "$PROGRESS_STATUS" = "complete" ]; then
    echo ""
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo -e "${GREEN}${CHECK} 🎉 기능 완성! GitHub Actions에서 자동 PR 생성 중...${NC}"
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo ""
    
    echo -e "${CYAN}${INFO} 다음 단계:${NC}"
    echo -e "  1. GitHub Actions에서 자동으로 develop 브랜치로 PR 생성"
    echo -e "  2. PR 리뷰 완료 후 develop에 머지"
    echo -e "  3. develop → main PR 생성 고려"
    echo ""
    echo -e "${GREEN}🎵 기능이 성공적으로 완성되었습니다!${NC}"
    
elif [ "$PROGRESS_STATUS" = "ready" ]; then
    echo ""
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo -e "${BLUE}${CHECK} 🔍 리뷰 준비 완료!${NC}"
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo ""
    
    echo -e "${CYAN}${INFO} 다음 단계:${NC}"
    echo -e "  1. 팀원에게 코드 리뷰 요청"
    echo -e "  2. 피드백 반영 후 '기능 완성' 상태로 업데이트"
    echo -e "  3. 테스트 케이스 추가 검토"
    
else
    echo ""
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo -e "${YELLOW}${CHECK} 🚧 개발 진행 상황 동기화 완료!${NC}"
    echo -e "${PURPLE}${SYNC} ===============================================${NC}"
    echo ""
    
    echo -e "${CYAN}${INFO} 개발을 계속 진행하세요:${NC}"
    echo -e "  • 다음 동기화 시점에 진행 상태 업데이트"
    echo -e "  • 기능 완성 시 'complete' 키워드로 커밋"
    echo -e "  • 팀원과 실시간 소통 유지"
fi

echo ""
echo -e "${GREEN}Happy Vibecoding! ${SYNC}${NC}"