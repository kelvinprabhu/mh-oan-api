# Debugging & Troubleshooting

Common issues with telemetry and how to fix them.

## Issue 1: "I don't see any telemetry in the dashboard"

### Checklist
1.  **Check `.env`**: Is `TELEMETRY_API_URL` set correctly?
2.  **Check Logs**: Look for `ERROR - Error sending telemetry`.
3.  **Network**: Can the container/server reach the external URL? (Try `curl` from inside the terminal).
4.  **Code Check**: Is the `background_tasks.add_task(send_telemetry, ...)` actually being called?
    *   *Note*: As of the current version, the telemetry call in `app/services/chat.py` might be commented out. Search for `# background_tasks.add_task(send_telemetry` and uncomment it if needed.

## Issue 2: "Logfire traces are missing"

### Checklist
1.  **Token**: Ensure `LOGFIRE_TOKEN` is present in `.env`.
2.  **Initialization**: Verify `logfire.configure(scrubbing=False)` runs at startup (`agents/__init__.py`).
3.  **Instrumentation**: Ensure the agent is initialized with `instrument=True`.

## Issue 3: "Application is slow / Latency Spikes"

*   **Diagnosis**: If `telemetry_api_url` is slow, it shouldn't affect the user (because it's backgrounded). However, if the thread pool is exhausted, it might.
*   **Verification**: Check if `requests` is timing out. Reduce the timeout in `app/tasks/telemetry.py`.

## Validating Connectivity

Run this quick python script in the shell to verify the system can send data:

```python
# test_connectivity.py
import requests
import os
from dotenv import load_dotenv

load_dotenv()

url = os.getenv("TELEMETRY_API_URL")
print(f"Testing connectivity to: {url}")

try:
    resp = requests.post(url, json={"test": "ping"}, timeout=5)
    print(f"Status: {resp.status_code}")
    print(f"Response: {resp.text}")
except Exception as e:
    print(f"Failed: {e}")
```
