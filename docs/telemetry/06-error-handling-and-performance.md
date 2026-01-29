# Error Handling & Performance

## Reliability Strategy

The telemetry system is designed to be **fail-safe** and **non-blocking**. The failure of the telemetry system should **never** impact the core application experience (e.g., chat response).

### 1. Asynchronous Execution
*   **Mechanism**: FastAPI `BackgroundTasks`.
*   **Impact**: The HTTP response is returned to the user *before* the telemetry payload is even serialized or sent.
*   **Safeguard**: If the `TELEMETRY_API_URL` is down, the user does not perceive any latency or error.

### 2. Exception Handling
In `app/tasks/telemetry.py`, the network call is wrapped in a broad `try/except` block:

```python
try:
    response = requests.post(...)
    # ...
except Exception as e:
    logger.error(f"Error sending telemetry: {str(e)}")
    return {"error": str(e)}
```

*   **Behavior**: Exceptions (connection timeouts, DNS errors, 500s) are caught.
*   **Fallback**: The error is logged to the application logs (`stderr`) so developers can see it, but it is not re-raised to crash the worker process.

## Performance Impact

### Latency
*   **User-Facing**: Near zero (microseconds to add task to queue).
*   **System**: Uses a thread from the worker pool for the `requests.post` call (synchronous I/O).
*   **Consideration**: High volume of telemetry could saturate worker threads if thousands of requests happen simultaneously. *Recommendation: Use an async HTTP client (httpx) in the future.*

### Data Volume
*   Payloads are typically small (< 5KB JSON).
*   Sampling is currently **100%** (all events are sent). There is no logic to sample only a % of requests.

## Known Limitations
*   **No Persistence**: If the application crashes *after* queueing the task but *before* execution, the telemetry event is lost. Redis is not used as an intermediate or dead-letter queue for telemetry.
*   **Synchronous I/O in Background**: The current use of `requests` (blocking) inside a background task runs in a threadpool. Under extreme load, this could exhaust the pool.
