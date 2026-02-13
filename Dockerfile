# =========================
# Stage 1: Builder
# =========================
FROM python:3.10-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    python3-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt


# =========================
# Stage 2: Runtime
# =========================
FROM python:3.10-slim

LABEL org.opencontainers.image.title="MH-OAN API" \
    org.opencontainers.image.source="https://github.com/OpenAgriNet/mh-oan-api" \
    org.opencontainers.image.description="MahaVistaar AI API – Agricultural Voice Assistant"

WORKDIR /app

# Install only runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    curl \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /install /usr/local

# Copy application
COPY . .

# Create logs directory
RUN mkdir -p /app/logs

# Copy supervisor configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set production-safe Python env
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Build Arguments
ARG LLM_PROVIDER
ARG LLM_MODEL_NAME
ARG GEMINI_API_KEY
ARG MAPBOX_API_TOKEN
ARG ENVIRONMENT
ARG LOGFIRE_TOKEN

# Set Environment Variables from Build Args
ENV LLM_PROVIDER=${LLM_PROVIDER} \
    LLM_MODEL_NAME=${LLM_MODEL_NAME} \
    GEMINI_API_KEY=${GEMINI_API_KEY} \
    MAPBOX_API_TOKEN=${MAPBOX_API_TOKEN} \
    ENVIRONMENT=${ENVIRONMENT} \
    LOGFIRE_TOKEN=${LOGFIRE_TOKEN}

EXPOSE 8000

# Make entrypoint executable
RUN chmod +x /app/scripts/entrypoint.sh

ENTRYPOINT ["/app/scripts/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
