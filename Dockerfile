# ---------- base ----------
FROM python:3.10-slim AS base

LABEL org.opencontainers.image.title="MH-OAN API" \
    org.opencontainers.image.source="https://github.com/OpenAgriNet/mh-oan-api" \
    org.opencontainers.image.description="MahaVistaar AI API – Agricultural Voice Assistant"

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    gcc \
    python3-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# ---------- dependencies ----------
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ---------- build args → env vars ----------
ARG LLM_PROVIDER
ARG LLM_MODEL_NAME
ARG GEMINI_API_KEY
ARG MAPBOX_API_TOKEN
ARG ENVIRONMENT
ARG LOGFIRE_TOKEN
ARG LANGFUSE_SECRET_KEY
ARG LANGFUSE_PUBLIC_KEY
ARG LANGFUSE_BASE_URL

ENV LLM_PROVIDER=${LLM_PROVIDER} \
    LLM_MODEL_NAME=${LLM_MODEL_NAME} \
    GEMINI_API_KEY=${GEMINI_API_KEY} \
    MAPBOX_API_TOKEN=${MAPBOX_API_TOKEN} \
    ENVIRONMENT=${ENVIRONMENT} \
    LOGFIRE_TOKEN=${LOGFIRE_TOKEN} \
    LANGFUSE_SECRET_KEY=${LANGFUSE_SECRET_KEY} \
    LANGFUSE_PUBLIC_KEY=${LANGFUSE_PUBLIC_KEY} \
    LANGFUSE_BASE_URL=${LANGFUSE_BASE_URL}

# ---------- application ----------
COPY . .

# Create logs directory for supervisord
RUN mkdir -p /app/logs

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose FastAPI port
EXPOSE 8000

# Health check using the liveness endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:8000/health/live || exit 1

# Start supervisor (manages uvicorn workers)
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
