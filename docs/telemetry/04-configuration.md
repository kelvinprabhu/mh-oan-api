# Telemetry Configuration

All telemetry-related configuration is managed centrally in `app/config.py` using `pydantic-settings`. These values are typically loaded from environment variables (`.env`).

## Settings Reference

| Config Key | Environment Variable | Default Value | Description |
| :--- | :--- | :--- | :--- |
| `telemetry_api_url` | `TELEMETRY_API_URL` | `https://vistaar.kenpath.ai/...` | The endpoint where custom telemetry JSON payloads are sent. |
| `logfire_token` | `LOGFIRE_TOKEN` | `None` | Authentication token for Logfire. If missing, Logfire traces may not be sent. |
| `log_level` | `LOG_LEVEL` | `"INFO"` | Standard Python logging level (`DEBUG`, `INFO`, `WARNING`, `ERROR`). |
| `environment` | `ENVIRONMENT` | `"production"` | Affects logging verbosity and debug flags. |

## Environment Variables

To configure telemetry, update your `.env` file:

```bash
# .env

# Custom Telemetry Endpoint
TELEMETRY_API_URL=https://your-custom-endpoint.com/v3/telemetry

# Logfire (for LLM Tracing)
LOGFIRE_TOKEN=your_logfire_write_token_here

# General Logging
LOG_LEVEL=DEBUG
ENVIRONMENT=development
```

## Local vs. Production Behavior

### Local / Development
*   **Logging**: Set `LOG_LEVEL=DEBUG` to see detailed logs in the console.
*   **Telemetry**: You can point `TELEMETRY_API_URL` to a local mock server (e.g., Postman Echo or a simple valid server) to verify payloads without polluting production data.
*   **Logfire**: Can be disabled by omitting the token or setting `instrument=False` in agents during dev if strictly necessary, though keeping it on is recommended for debugging.

### Production
*   **Logging**: typically `INFO` or `WARNING`.
*   **Telemetry**: Must point to the live Vistaar / EkStep telemetry ingestion endpoint.
*   **Impact**: Telemetry is sent in background tasks to minimize latency for the end user.
