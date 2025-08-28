# 🎵 Cursor-Claude 바이브코딩 가이드

Routine Quest App에서 Cursor와 Claude Code를 함께 활용한 효율적인 페어 프로그래밍 가이드입니다.

## 🎯 바이브코딩이란?

**바이브코딩**은 서로 다른 AI 도구들을 활용해 실시간으로 협업하는 새로운 개발 방식입니다.

- **Cursor**: 코드 자동완성, 리팩토링, UI 구현에 특화
- **Claude Code**: 아키텍처 설계, 복잡한 로직, 문서화에 특화

## 🌳 브랜치 전략

### 메인 브랜치 구조

```
main (🚨 production)
├── develop (🔄 integration)
├── feature/cursor-* (💻 Cursor 작업용)
├── feature/claude-* (🧠 Claude 작업용)
├── feature/collab-* (🤝 협업용)
└── hotfix/* (⚡ 긴급 수정)
```

### 브랜치 명명 규칙

- **Cursor 전용**: `feature/cursor-{기능명}`
  - 예: `feature/cursor-ui-animations`
  - 예: `feature/cursor-auth-forms`

- **Claude 전용**: `feature/claude-{기능명}`
  - 예: `feature/claude-api-endpoints`
  - 예: `feature/claude-business-logic`

- **협업 브랜치**: `feature/collab-{기능명}`
  - 예: `feature/collab-user-dashboard`
  - 예: `feature/collab-payment-flow`

## 🚀 바이브코딩 세션 플로우

### 1단계: 세션 준비 (5분)

```bash
# 1. 최신 코드 동기화
git checkout develop
git pull origin develop

# 2. 작업 브랜치 생성
git checkout -b feature/cursor-routine-ui    # Cursor 사용자
git checkout -b feature/claude-routine-api   # Claude 사용자

# 3. 작업 환경 실행
./scripts/dev.sh
```

### 2단계: 역할 분담

| 도구       | 주특기             | 담당 영역                      |
| ---------- | ------------------ | ------------------------------ |
| **Cursor** | 🎨 UI/UX, 인터랙션 | Frontend, 컴포넌트, 애니메이션 |
| **Claude** | 🧠 로직, 아키텍처  | Backend, API, 비즈니스 로직    |
| **협업**   | 🤝 통합, 테스트    | E2E 흐름, 통합 테스트          |

### 3단계: 30분 스프린트 사이클

```
⏰ 0-25분: 집중 코딩
⏰ 25-30분: 동기화 & 리뷰
```

#### 동기화 스크립트

```bash
# 자동 동기화 스크립트 (매 30분)
./scripts/vibecoding-sync.sh
```

### 4단계: 통합 및 배포

```bash
# 1. develop으로 통합
git checkout develop
git merge feature/cursor-routine-ui
git merge feature/claude-routine-api

# 2. 통합 테스트
pnpm test

# 3. 최종 PR 생성
gh pr create --base main --head develop
```

## 🛠️ 도구별 최적화 팁

### Cursor 최적화

- **코드 자동완성**: Tab으로 수락, 부분 수락 활용
- **리팩토링**: Cmd+K로 코드 변환 요청
- **UI 생성**: 자연어로 컴포넌트 설명 후 생성
- **실시간 미리보기**: Hot reload로 즉시 결과 확인

### Claude Code 최적화

- **아키텍처 설계**: 복잡한 비즈니스 로직 구조 설계
- **API 설계**: RESTful API 엔드포인트 자동 생성
- **테스트 작성**: 단위/통합 테스트 자동 생성
- **문서화**: API 문서, README 자동 업데이트

## 📋 바이브코딩 체크리스트

### 세션 시작 전

- [ ] Discord/Zoom 음성 채널 연결
- [ ] 작업 브랜치 생성
- [ ] 개발 서버 실행 확인
- [ ] 이슈/태스크 할당 확인

### 30분 스프린트 중

- [ ] 변경사항 실시간 공유
- [ ] 충돌 발생 시 즉시 해결
- [ ] 코드 품질 체크 (lint/test)
- [ ] 동기화 타이밍 준수

### 세션 종료 후

- [ ] 변경사항 develop로 동기화
- [ ] 코드 리뷰 요청
- [ ] 다음 세션 계획 수립
- [ ] 브랜치 정리 (필요시)

## 🔄 동기화 전략

### 자동 동기화 (추천)

GitHub Actions가 30분마다 자동으로:

1. 변경사항 감지
2. 품질 검사 실행
3. develop 브랜치로 PR 생성
4. 충돌 시 알림 발송

### 수동 동기화

```bash
# 빠른 동기화
git add -A
git commit -m "sync: 30분 스프린트 완료"
git push origin feature/cursor-routine-ui

# develop으로 즉시 통합
gh pr create --base develop --head feature/cursor-routine-ui --title "sync: routine UI 업데이트"
```

## 🚨 충돌 해결 전략

### 1단계: 충돌 감지

```bash
git fetch origin develop
git merge origin/develop
# 충돌 발생 시 →
```

### 2단계: 실시간 해결

1. **Discord에서 음성으로 상의**
2. **VS Code Live Share로 함께 해결**
3. **우선순위 결정**: UI vs 로직
4. **테스트로 검증**

### 3단계: 예방

- 파일 분리: UI와 로직을 다른 파일로
- 인터페이스 먼저: API 계약 우선 정의
- 소규모 커밋: 충돌 범위 최소화

## 📊 성과 측정

### 바이브코딩 메트릭

- **동기화 빈도**: 30분 준수율
- **충돌 해결 시간**: 평균 5분 이하
- **코드 품질**: 린트/테스트 통과율
- **기능 완성도**: 스프린트당 완료 기능 수

### 개선 지표

- 커밋 빈도 증가 📈
- 코드 리뷰 시간 단축 ⏰
- 버그 발생률 감소 🐛
- 개발 만족도 향상 😊

## 🎮 실전 시나리오 예제

### 시나리오 1: 사용자 대시보드 구축

```
Cursor 담당:
- 📱 React 컴포넌트 생성
- 🎨 CSS 애니메이션
- 📊 차트 위젯

Claude 담당:
- 🚀 FastAPI 엔드포인트
- 💾 데이터베이스 쿼리
- 🧪 API 테스트

협업 지점:
- 🔗 API 인터페이스 정의
- 🔄 실시간 데이터 연동
- ✅ E2E 테스트
```

### 시나리오 2: 결제 시스템 통합

```
30분 스프린트 계획:
├── 0-10분: 결제 UI 폼 (Cursor)
├── 0-15분: 결제 API 엔드포인트 (Claude)
├── 15-25분: 프론트-백엔드 연동 (협업)
└── 25-30분: 테스트 & 동기화
```

## 🔧 트러블슈팅

### 자주 발생하는 문제들

**Q: GitHub Actions가 너무 자주 실행돼요**

```yaml
# .github/workflows/vibecoding.yml 수정
# push 이벤트를 특정 파일만으로 제한
on:
  push:
    paths:
      - 'client/**'
      - 'api/**'
```

**Q: 동기화할 때 테스트가 계속 실패해요**

```bash
# 로컬에서 빠른 테스트 실행
pnpm test:quick

# 특정 영역만 테스트
pnpm test client/  # 프론트엔드만
pnpm test api/     # 백엔드만
```

**Q: 브랜치가 너무 많아져요**

```bash
# 브랜치 자동 정리 (머지 후)
git branch --merged develop | grep -v develop | xargs -n 1 git branch -d
```

## 🚀 고급 팁

### VS Code 확장 프로그램

- **GitLens**: 코드 변경 이력 추적
- **Live Share**: 실시간 코드 공유
- **Error Lens**: 에러 실시간 표시
- **Auto Rename Tag**: HTML 태그 자동 수정

### Discord 봇 활용

```javascript
// 바이브코딩 세션 알림 봇 예제
bot.on('message', msg => {
  if (msg.content === '!vibestart') {
    msg.channel.send('🎵 바이브코딩 세션 시작! 30분 집중 타이머 가동 ⏰');
    setTimeout(
      () => {
        msg.channel.send('⏰ 동기화 시간! 변경사항 푸시하세요 🔄');
      },
      25 * 60 * 1000
    ); // 25분 후
  }
});
```

### 생산성 단축키

```bash
# 빠른 브랜치 전환
alias gcb='git checkout -b'
alias gcd='git checkout develop'

# 바이브코딩 전용 명령어
alias vibe-start='./scripts/vibecoding-start.sh'
alias vibe-sync='./scripts/vibecoding-sync.sh'
alias vibe-end='./scripts/vibecoding-end.sh'
```

---

> 🎵 **바이브코딩의 핵심**: 도구의 특성을 살려 시너지를 만들어내는 것!  
> 각자의 강점을 극대화하면서도 하나의 팀으로 움직이는 새로운 개발 경험을 만들어보세요.

**Happy Vibecoding! 🚀✨**
