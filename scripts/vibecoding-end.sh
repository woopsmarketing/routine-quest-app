#!/bin/bash

# 🏁 Vibecoding Session End Script
# 바이브코딩 세션을 종료하고 정리하는 스크립트

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
FLAG="🏁"
PARTY="🎉"
CHECK="✅"
WARN="⚠️"  
INFO="💡"
CLOCK="⏰"

echo -e "${PURPLE}${FLAG} ===============================================${NC}"
echo -e "${PURPLE}${FLAG}       Vibecoding Session 종료              ${NC}"
echo -e "${PURPLE}${FLAG} ===============================================${NC}"
echo ""

# 1. 세션 설정 로드
VIBE_CONFIG=".vibecoding-session.json"
if [ ! -f "$VIBE_CONFIG" ]; then
    echo -e "${RED}${WARN} 바이브코딩 세션 파일을 찾을 수 없습니다.${NC}"
    echo -e "${YELLOW}${INFO} 수동으로 정리를 진행합니다.${NC}"
    SESSION_TYPE="unknown"
    BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    FEATURE_NAME="unknown"
else
    SESSION_TYPE=$(grep -o '"session_type": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
    BRANCH_NAME=$(grep -o '"branch_name": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
    FEATURE_NAME=$(grep -o '"feature_name": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
    STARTED_AT=$(grep -o '"started_at": "[^"]*' "$VIBE_CONFIG" | cut -d'"' -f4)
fi

echo -e "${BLUE}${INFO} 세션 정보:${NC}"
echo -e "  • 세션 타입: ${SESSION_TYPE}"
echo -e "  • 브랜치: ${BRANCH_NAME}"
echo -e "  • 기능: ${FEATURE_NAME}"
if [ ! -z "$STARTED_AT" ]; then
    echo -e "  • 시작 시간: $STARTED_AT"
fi
echo ""

# 2. 현재 상태 확인
echo -e "${CYAN}${INFO} 현재 작업 상태 확인...${NC}"
CHANGED_FILES=$(git status --porcelain)

if [ ! -z "$CHANGED_FILES" ]; then
    echo -e "${YELLOW}${WARN} 아직 커밋되지 않은 변경사항이 있습니다:${NC}"
    git status --short
    echo ""
    
    read -p "마지막 변경사항을 커밋하시겠습니까? (y/n): " final_commit
    if [[ $final_commit =~ ^[Yy]$ ]]; then
        echo -e "${CYAN}${INFO} 최종 커밋 생성 중...${NC}"
        
        # 스프린트 카운트 로드
        SPRINT_COUNT_FILE=".sprint-count"
        if [ -f "$SPRINT_COUNT_FILE" ]; then
            FINAL_SPRINT=$(($(cat "$SPRINT_COUNT_FILE") + 1))
        else
            FINAL_SPRINT=1
        fi
        
        FINAL_COMMIT_MSG="feat($FEATURE_NAME): 바이브코딩 세션 완료

- 세션 타입: $SESSION_TYPE
- 총 스프린트: $FINAL_SPRINT
- 세션 종료 커밋

바이브코딩 세션이 성공적으로 완료되었습니다! 🎉"

        git add -A
        git commit -m "$FINAL_COMMIT_MSG"
        git push origin "$BRANCH_NAME"
        echo -e "${GREEN}${CHECK} 최종 커밋 및 푸시 완료${NC}"
    fi
fi

# 3. 세션 통계 생성
echo ""
echo -e "${PURPLE}${FLAG} ===============================================${NC}"
echo -e "${PURPLE}${FLAG}            세션 통계 및 회고                    ${NC}"
echo -e "${PURPLE}${FLAG} ===============================================${NC}"

# 총 커밋 수 확인
if git show-ref --verify --quiet refs/heads/develop; then
    TOTAL_COMMITS=$(git rev-list --count HEAD ^develop)
else
    TOTAL_COMMITS=$(git rev-list --count HEAD)
fi

# 변경된 파일 수 확인
CHANGED_FILES_COUNT=$(git diff --name-only develop...HEAD 2>/dev/null | wc -l || echo "0")

# 추가/삭제된 라인 수
DIFF_STATS=$(git diff --shortstat develop...HEAD 2>/dev/null || echo "0 files changed")

echo -e "${CYAN}${INFO} 📊 세션 통계:${NC}"
echo -e "  • 총 커밋 수: $TOTAL_COMMITS"
echo -e "  • 변경된 파일 수: $CHANGED_FILES_COUNT"  
echo -e "  • 변경 통계: $DIFF_STATS"

if [ -f "$SPRINT_COUNT_FILE" ]; then
    TOTAL_SPRINTS=$(cat "$SPRINT_COUNT_FILE")
    TOTAL_TIME=$((TOTAL_SPRINTS * 30))
    echo -e "  • 총 스프린트: $TOTAL_SPRINTS"
    echo -e "  • 총 작업 시간: ${TOTAL_TIME}분 ($(echo "scale=1; $TOTAL_TIME/60" | bc 2>/dev/null || echo "${TOTAL_TIME}/60")시간)"
fi

if [ ! -z "$STARTED_AT" ]; then
    # 세션 지속 시간 계산 (macOS/Linux 호환)
    if command -v gdate >/dev/null 2>&1; then
        END_TIME=$(gdate -Iseconds)
        DURATION_SEC=$(($(gdate -d "$END_TIME" +%s) - $(gdate -d "$STARTED_AT" +%s)))
    elif date --version >/dev/null 2>&1; then
        END_TIME=$(date -Iseconds)  
        DURATION_SEC=$(($(date -d "$END_TIME" +%s) - $(date -d "$STARTED_AT" +%s)))
    else
        END_TIME=$(date +"%Y-%m-%dT%H:%M:%S")
        DURATION_SEC="계산 불가"
    fi
    
    if [ "$DURATION_SEC" != "계산 불가" ]; then
        DURATION_MIN=$((DURATION_SEC / 60))
        echo -e "  • 실제 세션 시간: ${DURATION_MIN}분"
    fi
fi

echo ""

# 4. PR 생성 옵션
read -p "develop 브랜치로 PR을 생성하시겠습니까? (y/n): " create_pr

if [[ $create_pr =~ ^[Yy]$ ]]; then
    echo -e "${CYAN}${INFO} PR 생성 중...${NC}"
    
    # PR 제목과 본문 생성
    PR_TITLE="🎵 [바이브코딩] $FEATURE_NAME 구현"
    
    PR_BODY="# 🎵 바이브코딩 세션 결과

## 🎯 세션 정보
- **세션 타입**: $SESSION_TYPE
- **기능명**: $FEATURE_NAME
- **브랜치**: $BRANCH_NAME"

if [ ! -z "$STARTED_AT" ]; then
    PR_BODY="$PR_BODY
- **세션 시작**: $STARTED_AT"
fi

if [ -f "$SPRINT_COUNT_FILE" ]; then
    PR_BODY="$PR_BODY
- **총 스프린트**: $(cat "$SPRINT_COUNT_FILE")개 (30분 단위)"
fi

PR_BODY="$PR_BODY

## 📊 통계
- **커밋 수**: $TOTAL_COMMITS
- **변경 파일**: $CHANGED_FILES_COUNT개
- **변경 통계**: $DIFF_STATS

## ✅ 체크리스트
- [x] 바이브코딩 세션 완료
- [ ] 코드 리뷰 완료
- [ ] 테스트 통과 확인
- [ ] 문서 업데이트

## 🔄 다음 단계
- [ ] 코드 리뷰 수행
- [ ] develop → main PR 생성 고려
- [ ] 후속 기능 계획

> 🎵 이 PR은 Cursor와 Claude Code의 바이브코딩 협업으로 개발되었습니다!"

    # GitHub CLI 사용 (있는 경우)
    if command -v gh >/dev/null 2>&1; then
        if gh pr create --title "$PR_TITLE" --body "$PR_BODY" --base develop --head "$BRANCH_NAME" --label "vibecoding,feature"; then
            echo -e "${GREEN}${CHECK} PR이 성공적으로 생성되었습니다!${NC}"
            gh pr view --web
        else
            echo -e "${YELLOW}${WARN} PR 생성 실패. 수동으로 생성해주세요.${NC}"
        fi
    else
        echo -e "${YELLOW}${WARN} GitHub CLI가 없습니다. 수동으로 PR을 생성해주세요.${NC}"
        echo ""
        echo -e "${CYAN}PR 정보:${NC}"
        echo -e "제목: $PR_TITLE"
        echo -e "브랜치: $BRANCH_NAME → develop"
    fi
fi

# 5. 정리 작업
echo ""
echo -e "${CYAN}${INFO} 정리 작업 수행 중...${NC}"

# 개발 서버 종료
echo -e "${INFO} 실행 중인 개발 서버 종료...${NC}"
pkill -f "pnpm dev" 2>/dev/null || true
pkill -f "npm run dev" 2>/dev/null || true

# 임시 파일 정리
if [ -f "$VIBE_CONFIG" ]; then
    rm -f "$VIBE_CONFIG"
    echo -e "${CHECK} 세션 설정 파일 정리 완료${NC}"
fi

if [ -f "$SPRINT_COUNT_FILE" ]; then
    rm -f "$SPRINT_COUNT_FILE"  
    echo -e "${CHECK} 스프린트 카운터 정리 완료${NC}"
fi

# 6. develop 브랜치로 전환 옵션
read -p "develop 브랜치로 전환하시겠습니까? (y/n): " switch_develop

if [[ $switch_develop =~ ^[Yy]$ ]]; then
    git checkout develop
    git pull origin develop
    echo -e "${GREEN}${CHECK} develop 브랜치로 전환 완료${NC}"
fi

# 7. 브랜치 삭제 옵션 (PR이 머지된 후에 사용)
echo ""
read -p "작업 브랜치를 삭제하시겠습니까? (PR 머지 후 권장) (y/n): " delete_branch

if [[ $delete_branch =~ ^[Yy]$ ]]; then
    if [ "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH_NAME" ]; then
        git checkout develop
    fi
    git branch -d "$BRANCH_NAME" 2>/dev/null || git branch -D "$BRANCH_NAME"
    git push origin --delete "$BRANCH_NAME" 2>/dev/null || true
    echo -e "${GREEN}${CHECK} 브랜치 삭제 완료${NC}"
fi

# 8. 최종 메시지
echo ""
echo -e "${PURPLE}${FLAG} ===============================================${NC}"
echo -e "${GREEN}${PARTY} 바이브코딩 세션이 성공적으로 종료되었습니다! ${PARTY}${NC}"
echo -e "${PURPLE}${FLAG} ===============================================${NC}"
echo ""

echo -e "${CYAN}${INFO} 세션 요약:${NC}"
echo -e "  • 기능: ${FEATURE_NAME}"
echo -e "  • 세션 타입: ${SESSION_TYPE}"
if [ -f "$SPRINT_COUNT_FILE" ]; then
    echo -e "  • 스프린트: $(cat "$SPRINT_COUNT_FILE")개"
fi
echo -e "  • 커밋: $TOTAL_COMMITS개"
echo ""

echo -e "${YELLOW}${INFO} 다음 할 일:${NC}"
echo -e "  1. PR 리뷰 받기"
echo -e "  2. 테스트 실행 및 검증"  
echo -e "  3. 바이브코딩 회고 작성"
echo -e "  4. 다음 기능 계획 수립"
echo ""

echo -e "${GREEN}수고하셨습니다! 다음 바이브코딩도 기대됩니다! 🎵✨${NC}"