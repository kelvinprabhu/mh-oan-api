# Testing Telemetry

Since telemetry happens in the background, it can be tricky to verify. Here are strategies to test and validate it.

## 1. Local Verification (Manual)

### Using Application Logs
1.  Set `LOG_LEVEL=DEBUG` (or `INFO`) in `.env`.
2.  Trigget an action (e.g., send a chat message).
3.  Watch the console output. You should see logs indicating success or failure:
    *   Success: `INFO - Telemetry sent successfully: {...}`
    *   Failure: `ERROR - Error sending telemetry: ...`

### Using a Mock Server
Instead of sending junk data to the production telemetry server, use a mock.

1.  Use a service like [Webhook.site](https://webhook.site) or run a local netcat/python server.
2.  Update `.env`:
    ```bash
    TELEMETRY_API_URL=https://webhook.site/your-unique-id
    ```
3.  Perform actions in the app.
4.  Verify the payload structure received by the webhook.

## 2. Unit Testing via Mocking

To test code that emits telemetry without actually making network calls, use `unittest.mock`.

```python
from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient
from app.main import app

def test_chat_sends_telemetry():
    with patch("app.services.chat.send_telemetry") as mock_send:
        client = TestClient(app)
        
        # Simulate chat request
        response = client.post("/api/v1/chat", json={...})
        
        # Verify response is healthy
        assert response.status_code == 200
        
        # Verify telemetry was queued
        # Note: Since it's a background task, TestClient usually runs them unless disabled, 
        # but mocking the task function itself is the safest way to verify the *intent* to send.
        mock_send.assert_called()
        
        # Inspect payload
        call_args = mock_send.call_args[0][0]
        assert "events" in call_args
        assert call_args["events"][0]["eid"] == "OE_MODERATION"
```

## 3. Validating Schema

You can use the Pydantic models in `helpers/telemetry.py` to validate raw JSON payloads if you are debugging data quality issues.

```python
from helpers.telemetry import TelemetryRequest

raw_json = {...} # load from a file
try:
    validated = TelemetryRequest(**raw_json)
    print("Valid Schema")
except Exception as e:
    print(f"Invalid Schema: {e}")
```
