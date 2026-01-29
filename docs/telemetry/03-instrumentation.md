# Instrumentation Guide

This document details how telemetry is implemented in the codebase and how to instrument new features.

## Files & Directories

| File Path | Purpose |
| :--- | :--- |
| `helpers/telemetry.py` | **Data Models**. Defines Pydantic models for all event types (`OE_START`, `OE_MODERATION`, etc.). *Modify this to add new event types.* |
| `app/tasks/telemetry.py` | **Transport Layer**. Contains the `send_telemetry` function which makes the HTTP POST request. |
| `app/services/chat.py` | **Instrumentation Point**. Example of where telemetry events are created and queued. |
| `agents/__init__.py` | **Agent Instrumentation**. Initializes `logfire` for AI agent tracing. |

## 1. Custom Telemetry Instrumentation

To instrument a new part of the application (e.g., a new API endpoint or service):

### Step 1: define the Event (if needed)
If the event type doesn't exist in `helpers/telemetry.py`, define a new `Eks` class inheriting from `BaseEventData`.

### Step 2: Create the Event Object
Use the factory functions in `helpers/telemetry.py` to create an event instance.

```python
from helpers.telemetry import create_event, EventType, BaseEventData

# Example: Creating a generic event
my_event_data = BaseEventData(...) 
event = create_event(
    event_type=EventType.OE_INTERACT,
    event_data=my_event_data,
    uid="user_123",
    session_id="session_abc"
)
```

### Step 3: Send via Background Task
Always use `BackgroundTasks` to send telemetry to avoid blocking the request loop.

```python
from fastapi import BackgroundTasks
from app.tasks.telemetry import send_telemetry
from helpers.telemetry import TelemetryRequest

# Inside your route handler or service function
def my_service_function(background_tasks: BackgroundTasks):
    # ... logic ...
    
    # Wrap event in a request
    telemetry_request = TelemetryRequest(events=[event])
    
    # Queue the task
    background_tasks.add_task(send_telemetry, telemetry_request.dict())
```

### Context Propagation
*   **Session ID (`sid`)**: Critical for correlating events. Must be passed from the API handler down to the service and telemetry creation functions.
*   **User ID (`uid`)**: Should be consistent across the session.
*   **Content ID (`gdata_id`)**: Used to track specific pieces of content (e.g., a specific query or resource).

## 2. LLM / Agent Instrumentation (Logfire)

Instrumentation for AI agents is largely automatic if you use Pydantic AI and the `instrument=True` flag.

### Enabling for a New Agent
When defining a new `Agent`:

```python
import logfire
from pydantic_ai import Agent

# Ensure logfire is configured (usually in agents/__init__.py)
# logfire.configure(scrubbing=False)

my_agent = Agent(
    'openai:gpt-4o',
    instrument=True  # <--- This enables Logfire tracing automatically
)
```

### Manual Spans
If you need to trace a specific block of code involves no AI calls but you want it in the same trace:

```python
import logfire

with logfire.span('processing_data'):
    process_data()
```

## 3. Logs

Use the helper `get_logger` to ensure consistent formatting.

```python
from helpers.utils import get_logger

logger = get_logger(__name__)

logger.info("Function started")
logger.error("Something went wrong", exc_info=True)
```
