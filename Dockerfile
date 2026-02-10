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