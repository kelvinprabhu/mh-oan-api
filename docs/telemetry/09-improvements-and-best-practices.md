# Improvements & Best Practices

Based on the analysis of the current implementation, here are recommended improvements.

## 1. Technical Debt & Fixes

### 🔴 Critical: Enable Telemetry in Chat Service
The telemetry calls in `app/services/chat.py` appear to be commented out in some blocks.
**Action**: Review the commented-out code, verify the event creation logic is up to date, and uncomment it to enable data flow.

### 🟡 Medium: Use Async HTTP Client
The current implementation uses `requests` (synchronous) inside a `BackgroundTasks`. While FastAPI runs these in a threadpool, it is better practice to use an asynchronous library like `httpx` or `aiohttp` to avoid blocking worker threads, especially under load.

**Current**:
```python
# app/tasks/telemetry.py
requests.post(url, ...) # Blocks thread
```

**Recommended**:
```python
# app/tasks/telemetry.py
import httpx
async with httpx.AsyncClient() as client:
    await client.post(url, ...) # Non-blocking
```

## 2. Best Practices

### Structured Logging
Move fully to structured logging (JSON logs).
*   **Why**: Easier to query in aggregation tools (Splunk, ELK, Datadog).
*   **How**: Integrate `structlog` or configure `logfire` to handle standard logging output as well.

### Correlation Configuration
Ensure a single `Trace-ID` or `Session-ID` travels from the frontend -> API -> Telemetry -> Logfire.
*   Currently, `session_id` is manually passed.
*   Consider using OpenTelemetry's context propagation to make this automatic.

### Dead Letter Queue (DLQ)
If sending telemetry fails, the data is currently lost.
*   **Improvement**: If the HTTP POST fails, push the payload to a Redis list (`telemetry_retry_queue`). A separate worker can retry sending these later.

### Environment-Specific Sampling
In production, you might not want to log *every* single interaction if volume scales up.
*   **Improvement**: Add a `TELEMETRY_SAMPLING_RATE` (e.g., 0.1 for 10%) env var.
