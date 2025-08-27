# 🐍 백엔드 API Docker 이미지
# FastAPI 기반 루틴 퀘스트 메인 API 서버

FROM python:3.11-slim

# 🏷️ 메타데이터
LABEL maintainer="Routine Quest Team"
LABEL description="FastAPI backend for Routine Quest app"

# 📁 작업 디렉토리 설정
WORKDIR /app

# 🔧 시스템 패키지 업데이트 및 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# 📦 Python 의존성 설치 (레이어 캐싱 최적화)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 📋 애플리케이션 코드 복사
COPY . .

# 👤 비루트 사용자 생성 (보안)
RUN useradd --create-home --shell /bin/bash app \
    && chown -R app:app /app
USER app

# 🌐 포트 노출
EXPOSE 8000

# 🏥 헬스체크
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# 🚀 실행 명령
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]