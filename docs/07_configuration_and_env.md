# Configuration & Environment

The application uses `pydantic-settings` to manage configuration. All settings are defined in `app/config.py` and loaded from a `.env` file.

## 1. Core Configuration (`app/config.py`)

| Variable | Description | Default |
| :--- | :--- | :--- |
| `APP_NAME` | Name of the API service. | "MahaVistaar AI API" |
| `ENVIRONMENT` | environment mode (`development`, `production`). | "production" |
| `DEBUG` | Enable debug logs and tracebacks. | `False` |
| `API_PREFIX` | Base prefix for all routes. | `/api` |

## 2. Environment Variables (`.env`)
Create a `.env` file in the root directory based on the following template via `app/config.py`.

### Security & Auth
```ini
SECRET_KEY=your-super-secret-key-change-me
JWT_PUBLIC_KEY_PATH=jwt_public_key.pem
JWT_PRIVATE_KEY_PATH=jwt_private_key.pem
ALLOWED_ORIGINS=*
```

### Database & Infrastructure
```ini
REDIS_HOST=localhost
REDIS_PORT=6379
MARQO_ENDPOINT_URL=http://localhost:8882
```

### External Services (LLM & Tools)
```ini
# LLM Provider (openai, azure, etc)
LLM_PROVIDER=openai
LLM_MODEL_NAME=gpt-4o

# API Keys
OPENAI_API_KEY=sk-...
BHASHINI_API_KEY=...
SARVAM_API_KEY=...
GEMINI_API_KEY=...
MAPBOX_API_TOKEN=...
```

## 3. Common Misconfigurations
1.  **Missing API Keys**: If `OPENAI_API_KEY` or `BHASHINI_API_KEY` are missing, the agent will fail at runtime when trying to initialize or translate.
2.  **Redis Connection**: Ensure Redis is running (`docker compose up -d redis`) before starting the app.
3.  **Marqo Index**: If `MARQO_INDEX_NAME` is not set or the index doesn't exist, document search will return empty results or errors.

## 4. Key Management Warning
> [!WARNING]
> Never commit `.env` files to version control. They contain sensitive keys. The repository uses `.gitignore` to prevent this, but be careful when deploying manually.
