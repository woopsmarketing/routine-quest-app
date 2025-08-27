#!/bin/bash

# 🎵 Vibecoding Session Start Script
# Cursor와 Claude Code 바이브코딩 세션을 시작하는 스크립트

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 이모지 정의
MUSIC="🎵"
ROCKET="🚀"
GEAR="⚙️"
CHECK="✅"
WARN="⚠️"
INFO="💡"

echo -e "${PURPLE}${MUSIC} ===============================================${NC}"
echo -e "${PURPLE}${MUSIC}     Vibecoding Session Starter               ${NC}"
echo -e "${PURPLE}${MUSIC} ===============================================${NC}"
echo ""

# 1. 현재 상태 확인
echo -e "${BLUE}${INFO} 현재 Git 상태 확인...${NC}"
git status --porcelain | head -10
echo ""

# 2. 개발 도구 선택
echo -e "${YELLOW}${GEAR} 사용할 개발 도구를 선택하세요:${NC}"
echo "1) Cursor 전용 (프론트엔드)"
echo "2) Claude Code 전용 (백엔드)"  
echo "3) 협업 모드 (둘 다)"
read -p "선택 (1-3): " tool_choice

case $tool_choice in
    1)
        SESSION_TYPE="cursor"
        BRANCH_PREFIX="feature/cursor"
        echo -e "${GREEN}${CHECK} Cursor 전용 모드 선택${NC}"
        ;;
    2)
        SESSION_TYPE="claude"  
        BRANCH_PREFIX="feature/claude"
        echo -e "${GREEN}${CHECK} Claude Code 전용 모드 선택${NC}"
        ;;
    3)
        SESSION_TYPE="collab"
        BRANCH_PREFIX="feature/collab"
        echo -e "${GREEN}${CHECK} 협업 모드 선택${NC}"
        ;;
    *)
        echo -e "${RED}${WARN} 잘못된 선택입니다. 협업 모드로 설정합니다.${NC}"
        SESSION_TYPE="collab"
        BRANCH_PREFIX="feature/collab"
        ;;
esac

# 3. 기능명 입력
read -p "기능명을 입력하세요 (예: user-dashboard): " feature_name

if [ -z "$feature_name" ]; then
    echo -e "${RED}${WARN} 기능명이 필요합니다.${NC}"
    exit 1
fi

BRANCH_NAME="${BRANCH_PREFIX}-${feature_name}"

# 4. 최신 코드 동기화
echo -e "${BLUE}${INFO} 최신 코드로 동기화 중...${NC}"
git fetch origin
git checkout develop 2>/dev/null || git checkout -b develop origin/main
git pull origin develop

# 5. 새 브랜치 생성
echo -e "${BLUE}${INFO} 새 브랜치 생성: ${BRANCH_NAME}${NC}"
if git show-ref --verify --quiet refs/heads/"${BRANCH_NAME}"; then
    echo -e "${YELLOW}${WARN} 브랜치가 이미 존재합니다. 체크아웃합니다.${NC}"
    git checkout "${BRANCH_NAME}"
else
    git checkout -b "${BRANCH_NAME}"
fi

# 6. 의존성 설치 및 환경 설정
echo -e "${BLUE}${INFO} 의존성 설치 중...${NC}"
if ! pnpm install --frozen-lockfile; then
    echo -e "${RED}${WARN} PNPM 설치 실패. 계속 진행합니다.${NC}"
fi

# 7. 개발 서버 시작 여부 확인
read -p "개발 서버를 시작하시겠습니까? (y/n): " start_dev
if [[ $start_dev =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}${INFO} 개발 서버 시작 중...${NC}"
    
    # 백그라운드에서 개발 서버 실행
    if [[ "$SESSION_TYPE" == "cursor" ]]; then
        echo -e "${INFO} 프론트엔드 개발 서버만 시작합니다.${NC}"
        pnpm dev --filter=@routine-quest/client &
    elif [[ "$SESSION_TYPE" == "claude" ]]; then
        echo -e "${INFO} 백엔드 개발 서버만 시작합니다.${NC}"
        pnpm dev --filter=@routine-quest/api --filter=@routine-quest/ai &
    else
        echo -e "${INFO} 전체 개발 스택을 시작합니다.${NC}"
        pnpm dev &
    fi
    
    echo -e "${GREEN}${CHECK} 개발 서버가 백그라운드에서 시작되었습니다.${NC}"
    sleep 3
fi

# 8. 바이브코딩 설정 파일 생성
VIBE_CONFIG=".vibecoding-session.json"
cat > "${VIBE_CONFIG}" << EOF
{
  "session_type": "${SESSION_TYPE}",
  "branch_name": "${BRANCH_NAME}",
  "feature_name": "${feature_name}",
  "started_at": "$(date -Iseconds)",
  "participants": {
    "cursor": $([ "$SESSION_TYPE" = "cursor" ] || [ "$SESSION_TYPE" = "collab" ] && echo "true" || echo "false"),
    "claude": $([ "$SESSION_TYPE" = "claude" ] || [ "$SESSION_TYPE" = "collab" ] && echo "true" || echo "false")
  },
  "sync_interval": 30,
  "sprint_count": 0,
  "urls": {
    "frontend": "http://localhost:3000",
    "backend": "http://localhost:8000",
    "ai": "http://localhost:8001"
  }
}
EOF

# 9. 바이브코딩 팁 표시
echo ""
echo -e "${PURPLE}${MUSIC} ===============================================${NC}"
echo -e "${GREEN}${CHECK} 바이브코딩 세션이 시작되었습니다!${NC}"
echo -e "${PURPLE}${MUSIC} ===============================================${NC}"
echo ""
echo -e "${CYAN}${INFO} 세션 정보:${NC}"
echo -e "  • 세션 타입: ${SESSION_TYPE}"
echo -e "  • 브랜치: ${BRANCH_NAME}"
echo -e "  • 기능: ${feature_name}"
echo ""
echo -e "${CYAN}${INFO} 다음 단계:${NC}"

case $SESSION_TYPE in
    "cursor")
        echo -e "  1. Cursor에서 UI 컴포넌트 작업 시작"
        echo -e "  2. 30분마다 './scripts/vibecoding-sync.sh' 실행"
        echo -e "  3. Claude 팀원과 실시간 소통"
        ;;
    "claude")
        echo -e "  1. Claude Code에서 API/로직 작업 시작"
        echo -e "  2. 30분마다 './scripts/vibecoding-sync.sh' 실행"  
        echo -e "  3. Cursor 팀원과 실시간 소통"
        ;;
    "collab")
        echo -e "  1. 각자 도구에서 작업 시작"
        echo -e "  2. 30분마다 './scripts/vibecoding-sync.sh' 실행"
        echo -e "  3. Discord/Zoom에서 실시간 소통"
        ;;
esac

echo ""
echo -e "${CYAN}${INFO} 유용한 명령어:${NC}"
echo -e "  • 동기화: ${GREEN}./scripts/vibecoding-sync.sh${NC}"
echo -e "  • 세션 종료: ${GREEN}./scripts/vibecoding-end.sh${NC}"
echo -e "  • 상태 확인: ${GREEN}git status${NC}"
echo -e "  • 개발 서버: ${GREEN}pnpm dev${NC}"
echo ""
echo -e "${YELLOW}${WARN} 주의사항:${NC}"
echo -e "  • 30분마다 반드시 동기화하세요"
echo -e "  • 충돌 발생 시 즉시 팀원에게 알리세요"  
echo -e "  • main 브랜치에 직접 푸시하지 마세요"
echo ""
echo -e "${GREEN}Happy Vibecoding! ${MUSIC}${NC}"

# 10. 타이머 설정 (선택적)
read -p "30분 타이머를 설정하시겠습니까? (y/n): " set_timer
if [[ $set_timer =~ ^[Yy]$ ]]; then
    echo -e "${INFO} 30분 후 알림이 울립니다...${NC}"
    (sleep 1800 && echo -e "\n${YELLOW}⏰ 30분 경과! 동기화 시간입니다: ./scripts/vibecoding-sync.sh${NC}" && \
     osascript -e 'display notification "바이브코딩 동기화 시간입니다!" with title "Vibecoding Timer"' 2>/dev/null || \
     notify-send "Vibecoding Timer" "동기화 시간입니다!" 2>/dev/null || \
     echo -e "\a") &
fi