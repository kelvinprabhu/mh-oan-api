# New Developer Onboarding

Welcome to the team! Follow this guide to get the MahaVistaar AI API running on your local machine.

## 1. Prerequisites
-   **Docker Desktop** (Running)
-   **Python 3.10+**
-   **Git**

## 2. Initial Setup

### Step 1: Clone the Repository
```bash
git clone <repository-url>
cd mh-oan-api
```

### Step 2: Environment Configuration
Copy the example environment file (if available) or create a new one based on `07_configuration_and_env.md`.
```bash
cp .env.example .env
# Edit .env and add your API keys (OpenAI, Bhashini, etc.)
```

### Step 3: Start Infrastructure Services
We use Docker for Redis and Marqo.
```bash
docker compose up -d
```
*Wait for a few minutes for Marqo to initialize completely.*

### Step 4: Python Environment
It is recommended to use a virtual environment.
```bash
python -m venv venv
# Windows:
.\venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

## 3. Running the Application
Start the FastAPI server using Uvicorn with hot-reload enabled.
```bash
uvicorn main:app --reload --port 8000
```
Visit **http://localhost:8000/docs** to see the Swagger UI.

## 4. Testing the Agent
1.  Open Swagger UI.
2.  Authenticate (if required, or disable auth in `config.py` for dev).
3.  Go to the `/chat` endpoint.
4.  Send a basic query:
    ```json
    {
      "query": "What is the weather in Pune?",
      "source_lang": "en",
      "target_lang": "en"
    }
    ```
5.  You should see a streamed response.

## 5. Debugging
-   **Logs**: Check your terminal for logs. We use structured logging.
-   **Tool Failures**: If the agent says "I cannot fetch data", check the server logs to see the actual Python exception from the tool.
-   **Marqo**: If search fails, ensure Marqo container is running on port 8882.
