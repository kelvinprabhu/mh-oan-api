# Tech Debt & Improvements

During the documentation process, several areas were identified that could benefit from refactoring or improvement.

## 1. Technical Debt

### Missing Tests
-   **Critical**: There is no dedicated `tests/` directory at the root level.
-   **Risk**: Changes to tools or agent logic are hard to verify without manual testing.
-   **Remedy**: Introduce `pytest`. Create unit tests for each tool in `agents/tools/` and integration tests for the `chat` endpoint.

### Duplicate Translation Logic
-   **Issue**: Translation utilities appear in both `agents/translation.py` and `helpers/translation.py`.
-   **Risk**: Inconsistent behavior if one is updated and the other isn't.
-   **Remedy**: Consolidate all translation logic into `helpers/translation.py` and remove the file in `agents/`.

### Hardcoded Configuration
-   **Issue**: Some files compute paths (e.g., `base_dir`) relative to `__file__`, which can be brittle if files are moved.
-   **Remedy**: Use a robust config loader (like `dynaconf` or stricter `pydantic-settings` usage) and absolute paths where possible.

### Production Readiness
-   **Issue**: `supervisord.conf` exists, but there is no clear production deployment guide beyond basic Docker.
-   **Remedy**: Create a `DEPLOYMENT.md` covering Nginx setup, SSL, and scaling strategies.

## 2. Architectural Improvements

### Enhanced Telemetry
-   Current telemetry seems to be a simple HTTP post.
-   **Suggestion**: Integrate with OpenTelemetry (OTEL) for full tracing across services, especially useful for debugging latency in the "Speech -> Agent -> Speech" pipeline.

### Tool Robustness
-   **Issue**: Tools like `mandi_prices` likely fail if the external Agmarknet API changes its HTML structure (if scraping) or API schema.
-   **Suggestion**: Implement a "Circuit Breaker" pattern. If a tool fails repeatedly, temporarily disable it and warn the user instead of letting the agent retry fruitlessly.

### Agent Memory
-   **Issue**: Redis is used for history, but it's unclear if there's a long-term memory strategy (e.g., remembering a farmer's crop preference across sessions).
-   **Suggestion**: Implement a persistent "UserProfile" store in Postgres/SQL to personalize the experience significantly.
