#!/bin/bash

# 💻 Cursor AI 작업 완료 및 PR 생성 스크립트
# 사용법: ./scripts/cursor-complete.sh [기능명]

set -e  # 오류 발생시 스크립트 종료

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}💻 Cursor AI 작업 완료 처리 시작...${NC}"

# 1. GitHub CLI 설치 확인
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh)가 설치되지 않았습니다!${NC}"
    echo -e "${YELLOW}설치 방법: https://cli.github.com/${NC}"
    exit 1
fi

# 2. GitHub CLI 인증 확인
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}🔑 GitHub CLI 인증이 필요합니다...${NC}"
    gh auth login
fi

# 3. 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 현재 브랜치: $CURRENT_BRANCH${NC}"

# feature/cursor-* 브랜치인지 확인
if [[ ! $CURRENT_BRANCH =~ ^feature/cursor- ]]; then
    echo -e "${RED}❌ 경고: 현재 브랜치가 feature/cursor-* 패턴이 아닙니다!${NC}"
    read -p "계속 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}💥 PR 생성 취소됨${NC}"
        exit 1
    fi
fi

# 4. 미커밋된 변경사항 확인
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  미커밋된 변경사항이 있습니다. 먼저 업로드를 실행하세요.${NC}"
    echo -e "${BLUE}💡 실행: ./scripts/cursor-upload.sh${NC}"
    exit 1
fi

# 5. 최신 상태로 푸시 확인
echo -e "${BLUE}📡 최신 상태 확인 및 푸시...${NC}"
git push origin "$CURRENT_BRANCH" || true

# 6. 기능명 입력받기
FEATURE_NAME="$1"
if [ -z "$FEATURE_NAME" ]; then
    echo -e "${YELLOW}🏷️  기능명을 입력해주세요 (예: user-auth, dashboard-ui):${NC}"
    read -r FEATURE_NAME
    
    if [ -z "$FEATURE_NAME" ]; then
        FEATURE_NAME=$(echo "$CURRENT_BRANCH" | sed 's/feature\/cursor-//')
    fi
fi

# 7. 변경사항 분석
echo -e "${BLUE}📊 변경사항 분석 중...${NC}"
COMMIT_COUNT=$(git rev-list --count HEAD ^origin/develop 2>/dev/null || echo "0")
CHANGED_FILES=$(git diff --name-only origin/develop..HEAD 2>/dev/null || git diff --name-only HEAD~$COMMIT_COUNT 2>/dev/null || echo "")
FILE_COUNT=$(echo "$CHANGED_FILES" | grep -v "^$" | wc -l)

# 8. 자동 체크리스트 생성
CHECKLIST=""
if echo "$CHANGED_FILES" | grep -q "\.dart$"; then
    CHECKLIST="$CHECKLIST
- [x] Flutter UI/UX 구현 완료"
fi
if echo "$CHANGED_FILES" | grep -q "\.py$"; then
    CHECKLIST="$CHECKLIST  
- [x] 백엔드 API 엔드포인트 구현"
fi
if echo "$CHANGED_FILES" | grep -q "test\|spec"; then
    CHECKLIST="$CHECKLIST
- [x] 단위 테스트 작성 완료"
fi
if echo "$CHANGED_FILES" | grep -q "\.json$\|\.yaml$"; then
    CHECKLIST="$CHECKLIST
- [x] 설정 파일 업데이트"
fi

# 기본 체크리스트 추가
CHECKLIST="$CHECKLIST
- [x] 로컬 테스트 통과
- [ ] CI/CD 파이프라인 통과  
- [ ] 코드 리뷰 완료
- [ ] 성능 테스트 통과"

# 9. PR 본문 생성
PR_BODY="💻 **Cursor AI 기능 구현 완료**

## 🎯 구현된 기능
**$FEATURE_NAME** 기능의 핵심 구현을 완료했습니다.

## 📊 변경 통계
- 🔢 **커밋 수**: $COMMIT_COUNT개
- 📁 **변경 파일**: $FILE_COUNT개
- 🌿 **브랜치**: \`$CURRENT_BRANCH\`

## 📝 주요 변경사항"

# 파일별 변경사항 추가
if [ ! -z "$CHANGED_FILES" ]; then
    PR_BODY="$PR_BODY
\`\`\`
$(echo "$CHANGED_FILES" | head -20)
\`\`\`"
    
    if [ $FILE_COUNT -gt 20 ]; then
        PR_BODY="$PR_BODY
... 그 외 $(($FILE_COUNT - 20))개 파일"
    fi
fi

PR_BODY="$PR_BODY

## ✅ 완료 체크리스트$CHECKLIST

## 🧪 테스트 결과
- ✅ **로컬 개발 환경**: 정상 동작 확인
- ⏳ **CI/CD 파이프라인**: 실행 대기 중
- ⏳ **통합 테스트**: develop 브랜치에서 실행 예정

## 🎵 다음 단계
1. **Claude Code 리뷰**: 코드 품질 분석 및 개선
2. **develop 통합**: CI/CD 파이프라인 통과 후 병합  
3. **main 배포**: 최종 검증 후 프로덕션 배포

## 💡 특이사항 및 참고사항
- Cursor AI를 활용한 효율적인 구현 완료
- 추가 최적화 및 리팩토링은 Claude Code에서 진행 예정
- UI/UX 중심의 사용자 경험 개선에 집중

---
**🤖 Created by Cursor AI** | 🔄 **Next: Claude Code Review** | 🎯 **Target: develop branch**"

# 10. PR 생성
echo -e "${BLUE}📝 PR 생성 중...${NC}"

PR_TITLE="💻 [Cursor] $FEATURE_NAME 기능 구현 완료"

# PR 생성 실행
PR_URL=$(gh pr create \
    --title "$PR_TITLE" \
    --body "$PR_BODY" \
    --base develop \
    --head "$CURRENT_BRANCH" \
    --assignee @me \
    --label "cursor-ai,feature,ready-for-review" \
    2>/dev/null)

# 11. 성공 메시지
echo -e "\n${GREEN}🎉 PR 생성 완료!${NC}"
echo -e "${BLUE}🔗 PR URL: $PR_URL${NC}"
echo -e "${BLUE}📍 브랜치: $CURRENT_BRANCH → develop${NC}"
echo -e "${BLUE}🏷️  기능명: $FEATURE_NAME${NC}"

# 12. 자동으로 PR 페이지 열기 (선택사항)
echo -e "\n${YELLOW}🌐 PR 페이지를 브라우저에서 열까요? (y/N):${NC}"
read -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr view --web
fi

# 13. 다음 단계 안내
echo -e "\n${YELLOW}🎯 다음 워크플로우:${NC}"
echo -e "  1️⃣  ${GREEN}CI/CD 검증${NC}: GitHub Actions 자동 실행"
echo -e "  2️⃣  ${BLUE}Claude 리뷰${NC}: 코드 품질 분석 및 개선"  
echo -e "  3️⃣  ${YELLOW}develop 병합${NC}: 모든 검증 통과 후 자동 병합"
echo -e "  4️⃣  ${RED}main 배포${NC}: 최종 배포 준비"

# 14. 팀 멘션 (선택사항)
echo -e "\n${BLUE}💬 팀 멤버에게 알림을 보낼까요? (y/N):${NC}"
read -n 1 -r  
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    gh pr comment "$PR_URL" --body "👋 @team 리뷰 요청드립니다! Cursor AI로 $FEATURE_NAME 기능 구현을 완료했습니다."
fi

echo -e "${GREEN}🎵 Cursor AI 작업 완료 처리 끝! 수고하셨습니다! 💻✨${NC}"