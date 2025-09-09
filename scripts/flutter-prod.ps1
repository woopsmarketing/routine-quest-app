# Flutter 프로덕션 모드 실행 스크립트
Write-Host "🚀 Flutter 프로덕션 모드 실행 중..." -ForegroundColor Green
Set-Location client
flutter run -d chrome --web-port 3000 --release
