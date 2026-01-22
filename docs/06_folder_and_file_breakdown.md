# Folder & File Breakdown

## 1. Root Directory
-   `main.py`: **Entry Point**. Initializes the FastAPI app, loads configuration, and mounts routers.
-   `README.md`: General project documentation, setup instructions, and Docker commands.
-   `Dockerfile` / `docker-compose.yml`: Containerization and orchestration configs.
-   `requirements.txt`: Python dependencies.
-   `supervisord.conf`: Process manager configuration (likely for running app + workers).

## 2. `agents/` (The Brain)
Contains all logic related to the AI agents.

-   **`__init__.py`**: Exports key agent components.
-   **`agrinet.py`**: **Core File**. Defines the main `agrinet_agent` using PydanticAI. Configures the model, tools, and system prompts.
-   **`moderation.py`**: Defines the `moderation_agent`. A lighter, faster agent used to check input safety before calling the main agent.
-   **`deps.py`**: Defines `FarmerContext`. This class holds per-request state (User Query, Location, Farmer ID) and is injected into the agent.
-   **`models.py`**: Pydantic models for Agent inputs/outputs (e.g., `ModerationResult`).
-   **`suggestions.py`**: Logic for generating follow-up questions (suggestions) for the user.
-   **`translation.py` (Legacy/Helper)**: Likely contains helper functions for dedicated agent-side translation if needed (though `app/helpers` usually handles this).

### `agents/tools/`
Contains the individual "skills" the agent can use.
-   **`__init__.py`**: Registry of all available tools.
-   **`weather.py`**: Tools for current (`weather_forecast`) and past (`weather_historical`) weather.
-   **`mandi.py`**: Tools for fetching market prices (`mandi_prices`).
-   **`search.py`**: Interface for Marqo/Vector search (`search_documents`).
-   **`schemes.py` / `mahadbt.py`**: Tools for government scheme information and application status.
-   **`agri_services.py`**: Tools for finding local agricultural centers (KVKs).

## 3. `app/` (The Body)
Contains the web application logic, API endpoints, and business orchestration.

-   **`config.py`**: Application settings. Loads variables from `.env`.
-   **`utils.py`**: General utility functions for the app layer.

### `app/routers/` (API Interface)
-   **`chat.py`**: **Main Endpoint**. logical flow for `/chat`. Handles the request lifecycle (Auth -> Service -> Response).
-   **`transcribe.py`**: Endpoints for Speech-to-Text (ASR).
-   **`tts.py`**: Endpoints for Text-to-Speech.
-   **`auth/`**: Authentication logic (likely JWT verification).
-   **`health.py`**: Health check endpoint.

### `app/services/` (Orchestration)
-   **`chat.py`**: **Critical Logic**. Contains `stream_chat_messages`. It stitches everything together: History + Moderation + Agent Run + Streaming.

### `app/models/`
-   **`requests.py`**: Pydantic models validating incoming API JSON bodies (e.g., `ChatRequest`).

## 4. `helpers/` (Utilities)
Shared helper functions used by both `agents` and `app`.

-   **`utils.py`**: Generic helpers (Logger setup, Date formatting).
-   **`telemetry.py`**: Functions to structure and send telemetry events to the observability platform.
-   **`transcription.py` / `translation.py`**: Wrappers for external AI services (Bhashini, Sarvam).

## 5. `assets/`
-   **`prompts/`**: (Implied) Directory containing text files or templates for System Prompts.
