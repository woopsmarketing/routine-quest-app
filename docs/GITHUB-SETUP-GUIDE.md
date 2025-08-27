# 📚 GitHub 바이브코딩 환경 적용 가이드

GitHub 초보자를 위한 상세한 단계별 가이드입니다.

## 🎯 전체 과정 개요

```
1. 로컬 변경사항 → GitHub 저장소에 업로드
2. GitHub Actions 자동 실행
3. 브랜치 보호 규칙 적용  
4. PR 생성 및 머지 프로세스
```

---

## 📋 단계별 상세 가이드

### 1단계: 현재 변경사항 GitHub에 업로드

#### 1.1 Git 상태 확인
```bash
# 현재 어떤 브랜치에 있는지 확인
git branch

# 변경된 파일들 확인
git status
```

#### 1.2 변경사항 스테이징 및 커밋
```bash
# 모든 변경사항을 스테이징 영역에 추가
git add .

# 커밋 메시지와 함께 커밋 생성
git commit -m "feat: 바이브코딩 환경 설정 완료

- GitHub Actions 워크플로우 추가
- 브랜치 보호 규칙 설정
- 이슈/PR 템플릿 생성
- 자동화 스크립트 추가"
```

#### 1.3 GitHub 저장소로 푸시
```bash
# 현재 브랜치를 GitHub에 업로드
git push origin feature/claude-test

# 만약 처음 푸시하는 브랜치라면:
git push --set-upstream origin feature/claude-test
```

**🎉 이 시점에서 GitHub Actions가 자동으로 실행됩니다!**

---

### 2단계: GitHub Actions 동작 확인

#### 2.1 GitHub 웹사이트에서 확인
1. **GitHub 저장소 접속**: `https://github.com/your-username/routine-quest-app`
2. **Actions 탭 클릭**: 상단 메뉴에서 "Actions" 선택
3. **워크플로우 실행 확인**: 방금 푸시한 커밋으로 실행된 워크플로우 확인

#### 2.2 실행되는 워크플로우들
```
🎵 Vibecoding Workflow (Feature-Complete)
├── 📋 Detect Changes (변경사항 감지)
├── 🚀 Quick Quality Check (빠른 품질 검사)
├── 🎯 Feature Completion Validation (기능 완성도 검증)
├── 🚀 Auto PR to Develop (자동 PR 생성 - 조건부)
└── 📊 Session Report (세션 리포트)
```

#### 2.3 워크플로우 실행 과정
1. **변경사항 감지**: 어떤 파일들이 변경되었는지 분석
2. **품질 검사**: 린트, 타입 체크, 기본적인 컴파일 확인
3. **기능 완성도 체크**: 커밋 메시지에서 'complete', 'done' 등 키워드 검색
4. **자동 PR 생성**: 기능이 완성된 경우 develop 브랜치로 PR 자동 생성

---

### 3단계: 브랜치 보호 규칙 적용

#### ⚠️ 현재 상황
지금은 `.github/branch-protection.yml` 파일만 있는 상태입니다. 
GitHub에서 실제로 브랜치 보호를 활성화하려면 **수동 설정**이 필요합니다.

#### 3.1 GitHub 웹에서 브랜치 보호 설정
1. **저장소 설정 접근**:
   - GitHub 저장소 → "Settings" 탭
   - 좌측 메뉴에서 "Branches" 선택

2. **main 브랜치 보호 설정**:
   ```
   Branch name pattern: main
   ✅ Require a pull request before merging
   ✅ Require status checks to pass before merging
     - 🔍 Code Quality
     - 🧪 Tests  
     - 🏗️ Build
   ✅ Require branches to be up to date before merging
   ✅ Restrict pushes that create files
   ```

3. **develop 브랜치 보호 설정**:
   ```
   Branch name pattern: develop
   ✅ Require a pull request before merging
   ✅ Require status checks to pass before merging
     - 🔍 Code Quality
     - 🧪 Tests
   ```

---

### 4단계: 바이브코딩 워크플로우 테스트

#### 4.1 새 기능 브랜치 생성 테스트
```bash
# 바이브코딩 세션 시작
./scripts/vibecoding-start.sh

# 선택:
# 1) Cursor 전용 (프론트엔드)
# 2) Claude Code 전용 (백엔드)  
# 3) 협업 모드 (둘 다)

# 예시: "user-profile" 기능 입력
```

#### 4.2 개발 및 동기화 테스트
```bash
# 간단한 파일 변경 (테스트용)
echo "console.log('Hello Vibecoding!');" > test-file.js

# 진행 상황 동기화
./scripts/vibecoding-sync.sh

# 상태 선택:
# 1) 🚧 개발 진행 중
# 2) 🔍 리뷰 준비됨  
# 3) ✅ 기능 완성 ← 이걸 선택하면 자동 PR 생성!
```

#### 4.3 자동 PR 생성 확인
**기능 완성 상태로 커밋하면**:
1. GitHub Actions가 "complete" 키워드 감지
2. 자동으로 develop 브랜치로 PR 생성
3. PR 제목: "✨ [바이브코딩] user-profile 기능 완성"

---

### 5단계: PR 리뷰 및 머지 프로세스

#### 5.1 자동 생성된 PR 확인
1. **GitHub 저장소** → **Pull requests** 탭
2. **자동 생성된 PR 클릭**
3. **PR 내용 검토**:
   - 바이브코딩 세션 정보
   - 변경사항 요약
   - 체크리스트 상태

#### 5.2 코드 리뷰 진행
```
1. 팀원이 코드 리뷰 수행
2. 필요시 수정사항 요청
3. 모든 검토 완료 후 "Approve"
4. GitHub Actions 통과 확인
5. "Merge pull request" 클릭
```

#### 5.3 develop → main PR 생성
```bash
# develop 브랜치에 기능들이 누적되면
# main으로의 배포용 PR 생성

git checkout develop
git pull origin develop

# GitHub에서 수동으로 PR 생성:
# develop → main
# 제목: "🚀 Release: v1.1.0 - 새로운 기능들"
```

---

## 🔄 일상적인 바이브코딩 플로우

### 매일 사용하는 명령어 순서
```bash
# 1. 새 기능 시작
./scripts/vibecoding-start.sh

# 2. 개발 작업 (Cursor + Claude)
# ... 코딩 작업 ...

# 3. 중간 동기화 (필요시)
./scripts/vibecoding-sync.sh
# → "개발 진행 중" 선택

# 4. 기능 완성시
./scripts/vibecoding-sync.sh  
# → "기능 완성" 선택 → 자동 PR 생성!

# 5. 세션 정리
./scripts/vibecoding-end.sh
```

---

## 🎯 GitHub에서 확인해야 할 것들

### ✅ 성공적으로 설정된 경우
- **Actions 탭**: 워크플로우가 초록색으로 성공
- **Branches 설정**: main/develop 브랜치 보호 활성화
- **Pull requests**: 자동 PR이 올바르게 생성
- **Issues**: 바이브코딩 템플릿이 표시

### ⚠️ 문제가 있는 경우
- **Actions 실패**: 빨간색 X 표시 → 로그 확인 필요
- **PR 생성 안됨**: GitHub CLI (`gh`) 설치 필요
- **권한 오류**: 저장소 권한 확인 필요

---

## 🚨 문제 해결 가이드

### 문제 1: GitHub Actions 실행 안됨
**원인**: 워크플로우 파일 경로 오류
```bash
# 확인: 파일이 올바른 위치에 있는지
ls -la .github/workflows/

# 해결: 파일 권한 및 내용 확인
cat .github/workflows/vibecoding.yml
```

### 문제 2: 브랜치 보호 규칙 작동 안함
**원인**: GitHub 웹에서 수동 설정 필요
```
GitHub 저장소 → Settings → Branches → Add rule
```

### 문제 3: 자동 PR 생성 실패
**원인**: GitHub CLI 미설치 또는 권한 문제
```bash
# GitHub CLI 설치 확인
gh --version

# 로그인 상태 확인  
gh auth status

# 필요시 로그인
gh auth login
```

### 문제 4: 워크플로우 권한 오류
**원인**: GITHUB_TOKEN 권한 부족
```
GitHub 저장소 → Settings → Actions → General
→ Workflow permissions → "Read and write permissions" 선택
```

---

## 🎉 설정 완료 체크리스트

### GitHub 저장소에서 확인
- [ ] `.github/workflows/vibecoding.yml` 파일 존재
- [ ] `.github/ISSUE_TEMPLATE/` 디렉토리 및 템플릿들 존재
- [ ] `scripts/` 디렉토리 및 스크립트들 존재
- [ ] Actions 탭에서 워크플로우 실행 확인
- [ ] 브랜치 보호 규칙 활성화 (Settings → Branches)

### 로컬에서 테스트
- [ ] `./scripts/vibecoding-start.sh` 실행 가능
- [ ] `./scripts/vibecoding-sync.sh` 실행 가능  
- [ ] `git push` 후 GitHub Actions 자동 실행
- [ ] "complete" 키워드 커밋시 자동 PR 생성

---

**🎵 축하합니다! 바이브코딩 환경이 완전히 구축되었습니다!**

이제 Cursor와 Claude Code를 활용한 효율적인 협업 개발이 가능합니다. 
문제가 발생하면 이 가이드를 참조하거나 GitHub Issues를 활용하세요!