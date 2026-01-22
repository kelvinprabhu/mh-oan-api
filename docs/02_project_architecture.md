# Project Architecture

## 1. High-Level Architecture
The system follows a **Service-Oriented Architecture (SOA)** with a clean separation between the API Layer (Interface), Service Layer (Orchestration), and Agent Layer (Intelligence).

```mermaid
graph TD
    Client[Client App / WhatsApp] -->|HTTP/REST| API[API Gateway (FastAPI)]
    API -->|Auth & Validation| Router[Routers]
    Router -->|Business Logic| Service[Service Layer]
    
    subgraph "Service Layer"
        Service -->|Check Safety| ModAgent[Moderation Agent]
        Service -->|Planning| MainAgent[AgriNet Agent]
        Service -->|Async Tasks| Background[Background Tasks]
    end
    
    subgraph "Agent Layer (PydanticAI)"
        MainAgent -->|Decide| Planner[Planner]
        Planner -->|Execute| Tools[Tool Registry]
    end
    
    subgraph "External Integration"
        Tools -->|API| Weather[Weather Service]
        Tools -->|API| Mandi[Mandi Prices]
        Tools -->|Vector Search| Marqo[Marqo DB]
        Tools -->|Query| Redis[Redis Cache]
    end
    
    Service -->|Response| API
    API -->|JSON/Stream| Client
```

## 2. Core Components

### 2.1 API Layer (`app/routers/`)
-   **Role**: Entry point for all external requests.
-   **Responsibilities**:
    -   Request validation (Pydantic models).
    -   Authentication (JWT via `app/auth/`).
    -   Route dispatching (e.g., `/chat`, `/transcribe`).
    -   Streaming response handling.

### 2.2 Service Layer (`app/services/`)
-   **Role**: Orchestrates the business logic.
-   **Responsibilities**:
    -   Manages the "Conversation Loop".
    -   Context injection (`FarmerContext`).
    -   Calls the Moderation Agent first to filter unsafe inputs.
    -   Invokes the Main Agent (`agrinet_agent`) for valid requests.
    -   Handles history management (loading/saving to database).

### 2.3 Agent Layer (`agents/`)
-   **Role**: The "Brain" of the application.
-   **Components**:
    -   **`agrinet.py`**: The primary agent. It is initialized with `PydanticAI` and has access to all tools.
    -   **`moderation.py`**: A specialized, lighter agent solely for checking input safety.
    -   **`deps.py`**: Defines the `FarmerContext`, carrying session-specific data (Location, Language, Farmer ID) into the agent's execution scope.

### 2.4 Data Layer
-   **Redis**: Used for high-speed caching of API responses (e.g., repeating weather queries) and managing task queues.
-   **Marqo**: Vector database used for RAG (Retrieval-Augmented Generation). It stores government schemes and agricultural documents, allowing the agent to "search_documents".

## 3. Data Flow Example: "Weather in Pune"

1.  **Request**: User sends "What is the weather in Pune?" (Marathi audio or text).
2.  **API**: `chat_endpoint` receives the request, validates the JWT, and extracts user info.
3.  **Service**:
    -   Initializes `FarmerContext` with user's location/ID.
    -   Calls `moderation_agent`: Returns "Safe".
    -    Calls `agrinet_agent` with history and current query.
4.  **Agent**:
    -   Analyzes query: "Need weather for Pune".
    -   Selects Tool: `weather_forecast(location='Pune')`.
5.  **Tool**:
    -   Calls external Weather API.
    -   Returns JSON: `{ "temp": 32, "condition": "Sunny" }`.
6.  **Agent**:
    -   Synthesizes response: "The weather in Pune is sunny with 32°C."
7.  **Service**:
    -   Triggers background tasks (Telemetry, Suggestions).
    -   Streams text back to the client.

## 4. Key Design Patterns
-   **Dependency Injection**: Heavily used in FastAPI (`Depends`) and PydanticAI (`RunContext`) to keep components testable and decoupled.
-   **Asynchronous Processing**: All I/O operations (DB, networked API calls) are `async/await` to handle high concurrency.
-   **Tool Abstraction**: Tools are defined as standalone functions, making them easy to swap or update without changing the agent's core logic.
