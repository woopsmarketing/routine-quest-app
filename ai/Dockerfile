# 🤖 AI 마이크로서비스 Docker 이미지  
# AI 코치 기능을 위한 분리된 FastAPI 서비스

FROM python:3.11-slim

# 🏷️ 메타데이터
LABEL maintainer="Routine Quest Team"
LABEL description="AI microservice for Routine Quest coach features"

# 📁 작업 디렉토리 설정
WORKDIR /app

# 🔧 시스템 패키지 (AI 라이브러리용)
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# 📦 Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 📋 애플리케이션 코드 복사
COPY . .

# 👤 비루트 사용자 생성
RUN useradd --create-home --shell /bin/bash ai \
    && chown -R ai:ai /app
USER ai

# 🌐 포트 노출
EXPOSE 8001

# 🏥 헬스체크
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8001/health || exit 1

# 🚀 실행 명령
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001"]