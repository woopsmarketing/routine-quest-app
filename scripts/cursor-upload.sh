#!/bin/bash

# 🤖 Cursor AI 업로드 자동화 스크립트
# 사용법: ./scripts/cursor-upload.sh [커밋 메시지 추가 내용]

set -e  # 오류 발생시 스크립트 종료

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 Cursor AI 자동 업로드 시작...${NC}"

# 1. 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 현재 브랜치: $CURRENT_BRANCH${NC}"

# 2. feature/cursor-* 브랜치인지 확인
if [[ ! $CURRENT_BRANCH =~ ^feature/cursor- ]]; then
    echo -e "${RED}❌ 경고: 현재 브랜치가 feature/cursor-* 패턴이 아닙니다!${NC}"
    echo -e "${YELLOW}   현재: $CURRENT_BRANCH${NC}"
    echo -e "${YELLOW}   예상: feature/cursor-setup, feature/cursor-auth 등${NC}"
    
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}💥 업로드 취소됨${NC}"
        exit 1
    fi
fi

# 3. 변경 사항 확인
echo -e "${BLUE}📋 변경 사항 확인 중...${NC}"
git status --porcelain > /tmp/git_changes.txt

if [ ! -s /tmp/git_changes.txt ]; then
    echo -e "${YELLOW}⚠️  변경 사항이 없습니다.${NC}"
    exit 0
fi

# 변경된 파일 출력
echo -e "${GREEN}📝 변경된 파일들:${NC}"
while IFS= read -r line; do
    echo "  $line"
done < /tmp/git_changes.txt

# 4. 변경 사항 요약 생성
CHANGED_FILES=$(git diff --name-only --cached HEAD 2>/dev/null || git diff --name-only HEAD 2>/dev/null || echo "새 파일들")
FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l)

# 주요 변경사항 자동 감지
SUMMARY=""
if echo "$CHANGED_FILES" | grep -q "\.dart$"; then
    SUMMARY="$SUMMARY\n- Flutter/Dart 코드 구현"
fi
if echo "$CHANGED_FILES" | grep -q "\.py$"; then
    SUMMARY="$SUMMARY\n- Python/FastAPI 백엔드 구현"
fi
if echo "$CHANGED_FILES" | grep -q "\.ts$\|\.js$"; then
    SUMMARY="$SUMMARY\n- TypeScript/JavaScript 구현"
fi
if echo "$CHANGED_FILES" | grep -q "test\|spec"; then
    SUMMARY="$SUMMARY\n- 테스트 코드 작성"
fi
if echo "$CHANGED_FILES" | grep -q "\.json$\|\.yaml$\|\.yml$"; then
    SUMMARY="$SUMMARY\n- 설정 파일 업데이트"
fi

# 5. Git add
echo -e "${BLUE}📦 변경사항을 스테이징 중...${NC}"
git add .

# 6. 커밋 메시지 생성
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
ADDITIONAL_MESSAGE="$1"

COMMIT_MESSAGE="feat: cursor 작업 완료 - $TIMESTAMP

💻 Cursor AI 작업 내역:$SUMMARY
- 총 $FILE_COUNT개 파일 변경
- UI/UX 구현 및 기능 개발"

if [ ! -z "$ADDITIONAL_MESSAGE" ]; then
    COMMIT_MESSAGE="$COMMIT_MESSAGE
- $ADDITIONAL_MESSAGE"
fi

# 7. 커밋 실행
echo -e "${BLUE}💾 커밋 생성 중...${NC}"
git commit -m "$COMMIT_MESSAGE"

# 8. 푸시 실행
echo -e "${BLUE}🚀 원격 저장소에 푸시 중...${NC}"

# 첫 푸시인지 확인
if git ls-remote --heads origin "$CURRENT_BRANCH" | grep -q "$CURRENT_BRANCH"; then
    git push origin "$CURRENT_BRANCH"
else
    echo -e "${YELLOW}📡 새 브랜치를 원격에 생성하고 푸시 중...${NC}"
    git push -u origin "$CURRENT_BRANCH"
fi

# 9. 완료 메시지
echo -e "${GREEN}✅ Cursor AI 업로드 완료!${NC}"
echo -e "${BLUE}📍 브랜치: $CURRENT_BRANCH${NC}"
echo -e "${BLUE}💾 커밋 해시: $(git rev-parse --short HEAD)${NC}"
echo -e "${BLUE}🔗 GitHub: https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\([^/]*\/[^.]*\).*/\1/')/tree/$CURRENT_BRANCH${NC}"

# 10. 다음 단계 안내  
echo -e "\n${YELLOW}🎯 다음 단계:${NC}"
echo -e "  1️⃣  ${GREEN}작업 계속${NC}: 더 개발하고 다시 '업로드해줘'"
echo -e "  2️⃣  ${BLUE}작업 완료${NC}: ./scripts/cursor-complete.sh 실행으로 PR 생성"
echo -e "  3️⃣  ${YELLOW}Claude 인계${NC}: 'Claude 리뷰해줘'로 코드 품질 개선"

# 임시 파일 정리
rm -f /tmp/git_changes.txt

echo -e "${GREEN}🎵 Cursor AI 업로드 완료! Happy Coding! 💻${NC}"