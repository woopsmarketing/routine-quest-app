#!/bin/bash
# Flutter 프로덕션 모드 실행 스크립트
echo "🚀 Flutter 프로덕션 모드 실행 중..."
cd client
flutter run -d chrome --web-port 3000 --release
