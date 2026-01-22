# Agentic Workflow

## 1. Runtime Flow Overview

The following steps describe the typical lifecycle of a user user request (`stream_chat_messages` in `app/services/chat.py`).

### Step 1: Request Entry & Context Initialization
1.  **User Input**: A user sends a request (Audio or Text).
2.  **Authentication**: API validates the JWT token and extracts `user_id`.
3.  **Context Creation**: The `FarmerContext` is initialized.
    -   `farmer_id` is fetched from `user_info`.
    -   `target_lang` is determined (default: Marathi 'mr').

### Step 2: Moderation Layer (The Guardrail)
Before the main agent sees the message, the **Moderation Agent** runs:
1.  **Input**: The raw user query.
2.  **Analysis**: Checks for hate speech, self-harm, political sensitivity, or non-agricultural topics.
3.  **Decision**:
    -   **Pass**: If category is `valid_agricultural` -> Proceed to Step 3.
    -   **Fail**: If harmful/irrelevant -> Return a standard refusal message immediately. The Main Agent is **skipped**.

### Step 3: Main Agent Execution (The Loop)
If moderation passes, the **Vistaar Agent** takes over.

1.  **History Injection**: The last 3 turns of conversation history are formatted and passed to the agent.
2.  **Reasoning**: The LLM analyzes the `system_prompt` + `history` + `current_query`.
    -   *Example Thought*: "User wants onion prices in Nashik. I need the `mandi_prices` tool."
3.  **Tool Call**: The agent generates a structured tool call: `mandi_prices(crop="onion", district="nashik")`.
4.  **Tool Execution**: The PydanticAI runtime executes the Python function.
    -   The function might hit an external API (e.g., Agmarknet).
    -   Result: `{"avg_price": 2500, "unit": "INR/Quintal"}`.
5.  **Observation**: The tool result is fed back to the LLM.
6.  **Synthesis**: The LLM sees the result and formulates the final answer in English.

### Step 4: Streaming & Post-Processing
1.  **Streaming**: The response is streamed token-by-token to the client to reduce perceived latency.
2.  **History Update**: The full interaction (User Query + Agent Response) is saved to the conversation history (Redis/DB).
3.  **Background Tasks**:
    -   **Telemetry**: Log the interaction for analytics.
    -   **Suggestions**: Generate 3 follow-up questions (e.g., "What about tomato prices?") to keep the user engaged.

## 2. Decision Logic

| Scenario | Agent Behavior |
| :--- | :--- |
| **Simple Greeting** ("Namaskar") | Replies directly without tools. |
| **Data Query** ("Weather in Mumbai") | Calls `weather_forecast` -> Synthesizes answer. |
| **Complex Query** ("Schemes for small farmers") | Calls `search_documents` (Marqo) -> Ranks results -> Summarizes top schemes. |
| **Missing Info** ("Price of onions") | Asks clarifying question: "Which district are you asking about?" (Loop continues). |
| **Tool Failure** | Retries the tool call (up to 3 times) or gracefully accepts the error and informs the user. |

## 3. Failure Handling
-   **Validation Errors**: If the LLM generates invalid arguments for a tool, PydanticAI catches it, feeds the error back to the LLM, and asks it to try again.
-   **API Errors**: If an external API (e.g., Weather) is down, the tool returns a specific error string. The agent uses this to apologize to the user: "I cannot access weather data right now."
