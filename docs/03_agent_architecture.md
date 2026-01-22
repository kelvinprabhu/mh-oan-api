# Agent Architecture

## 1. Core Framework
The agent is built using **PydanticAI**, a Python framework that emphasizes type safety, validation, and structured responses. This ensures that tool inputs and outputs are strictly validated against Pydantic models, reducing runtime errors.

## 2. Agent Types
The system utilizes a **Multi-Agent** approach (specifically, a dual-agent pattern) to handle requests efficiently and safely.

### 2.1 Moderation Agent (`agents/moderation.py`)
-   **Type**: Reactive / Classifier.
-   **Purpose**: Acts as a "Guardrail". It analyzes every user input *before* it reaches the main agent.
-   **Responsibility**:
    -   Classifies input into categories (e.g., `valid_agricultural`, `harmful`, `off-topic`).
    -   Does NOT have access to external tools.
    -   Fast execution (limited context).
-   **Output**: A structured `ModerationResult` object containing the category and a flagged boolean.

### 2.2 Main Agent - "Vistaar Agent" (`agents/agrinet.py`)
-   **Type**: Planner-Executor / ReAct.
-   **Purpose**: The core problem solver.
-   **Responsibility**:
    -   Understands complex agricultural queries.
    -   Decides which tools to call (e.g., `weather_forecast`, `mandi_prices`).
    -   Synthesizes information from multiple sources.
    -   Maintains conversation history.
-   **Configuration**:
    -   `retries`: 3 (Automatic retry on tool failures or validation errors).
    -   `max_tokens`: 8192 (Context window limit).
    -   `system_prompt`: Dynamic, injected with current date and context.

## 3. Dependency Injection & Context (`agents/deps.py`)
State is passed to the agent via the `FarmerContext` dependency class. This avoids global variables and ensures every request is isolated.

### `FarmerContext` properties:
-   `query`: The original user question.
-   `lang_code`: Target language (e.g., 'mr' for Marathi).
-   `moderation_str`: Result from the moderation agent (used to steer the main agent).
-   `farmer_id`: Unique identifier (if available) to fetch personalized AgriStack data.

**Why this exists**:
The agent often needs "hidden" context that isn't in the chat history. For example, if a user says "What about *my* farm?", the agent needs the `farmer_id` from the context to know which farm to look up in AgriStack.

## 4. Prompt Engineering
-   **System Prompts**: Stored in `assets/prompts/` (implied structure based on `get_prompt` usage).
-   **Dynamic Injection**: The system prompt is not static. It injects:
    -   Today's Date (Crucial for "tomorrow's weather").
    -   User's Location context.
    -   Language instructions.

## 5. Tool Registry
Tools are effectively "Function Tools" provided to the LLM. They are defined in `agents/tools/` and imported into `agents/tools/__init__.py`.
-   The PydanticAI framework automatically generates JSON schemas for these tools based on their Python type hints.
-   The LLM sees these schemas and generates JSON arguments to call them.
