# Tools & Integrations

The agent interacts with the outside world through a set of defined **Tools**. Each tool is a Python function decorated with `@model` (implicitly handled by PydanticAI) that performs a specific action.

## 1. Tool Registry
All tools are registered in `agents/tools/__init__.py`.

| Tool Name | Purpose | Key Inputs | External Source |
| :--- | :--- | :--- | :--- |
| `weather_forecast` | Fetch 5-day weather forecast. | `location` (str) | OpenWeatherMap / IMD (via Adapter) |
| `weather_historical` | Fetch past weather data. | `location`, `date` | Weather API |
| `mandi_prices` | Get real-time market prices for crops. | `crop`, `district`, `state` | Agmarknet API |
| `search_documents` | Semantic search for agricultural queries. | `query_text` | Marqo (Vector DB) |
| `search_videos` | Find relevant advice videos. | `keywords` | YouTube / Internal Video DB |
| `get_scheme_info` | Get details of a specific scheme. | `scheme_name` | Database / Marqo |
| `get_scheme_status` | Check application status for a farmer. | `applicant_id` | MahaDBT Portal |
| `fetch_agristack_data` | Get land/crop details for a farmer. | `farmer_id` (from Context) | AgriStack API |
| `contact_agricultural_staff` | Find contact info for local officers. | `taluka`, `district` | Internal Staff DB |
| `agri_services` | Locate nearby services (KVK, Soil Labs). | `service_type`, `location` | KVK Database |

## 2. External Integrations

### 2.1 Marqo (Vector Database)
-   **Usage**: Used for RAG (Retrieval Augmented Generation).
-   **Content**: Indexes government schemes (GRs), best practice documents, and crop manuals.
-   **Flow**: Agent calls `search_documents` -> Marqo finds relevant chunks -> Agent summarizes them.

### 2.2 Redis (Cache & Broker)
-   **Usage**:
    -   Caching API responses (e.g., repeating the same Mandi price query).
    -   Storing conversation history.
    -   Message broker for background tasks (if using Celery/Arq, though current code uses FastAPI `BackgroundTasks`).

### 2.3 Bhashini / Sarvam AI
-   **Usage**: Speech-to-Text (ASR) and Text-to-Speech (TTS).
-   **Integration Point**: `app/routers/transcribe.py` and `app/routers/tts.py`.
-   **Flow**: Audio -> Bhashini -> Text -> Agent -> Text -> Bhashini -> Audio.

### 2.4 ONDC / Beckn (Planned/Partial)
-   **Usage**: Integration with the Open Network for Digital Commerce.
-   **Status**: Some folder structures hint at this (`agri_services`), likely for connecting farmers to buyers or service providers.

## 3. Tool Failure Handling
If a tool fails (e.g., API timeout), the function raises an exception. PydanticAI catches this and:
1.  feeds the error message back to the LLM.
2.  The LLM can attempt to fix the arguments or retry.
3.  If it fails 3 times (configured `retries=3`), the agent apologizes to the user.
