# Telemetry Integrations

This system integrates with two primary external systems for telemetry and observability.

## 1. Vistaar / EkStep Telemetry Service

The custom telemetry implementation connects to the Vistaar observability service (based on Sunbird/EkStep standards).

*   **Protocol**: HTTP / REST
*   **Method**: `POST`
*   **Content-Type**: `application/json`
*   **Authentication**: currently relies on IP whitelisting or open endpoints (no explicit `Authorization` header found in `send_telemetry` task).
*   **Payload Structure**: see `helpers/telemetry.py` for the full schema.

### Exporter Details
The exporter is a direct HTTP client implemented in `app/tasks/telemetry.py`.
*   **Library**: `requests`
*   **Timeout**: 30s connect, 60s read.
*   **Retry Policy**: None explicit in the `send_telemetry` function itself, but runs as a background task.

## 2. Logfire (Pydantic)

Logfire is used for deep introspection of the AI agents.

*   **Integration**: Python SDK (`logfire` package).
*   **Data Sent**:
    *   Traces (Spans)
    *   Console Logs (if configured)
    *   Metrics (system info)
*   **Authentication**: Bearer Token via `LOGFIRE_TOKEN` environment variable.
*   **Transport**: Batched, asynchronous background transmission to Logfire Cloud.

## 3. AWS S3 (Audio artifacts)

While not "telemetry" in the strict sense, audio uploads generate `OE_MEDIA` telemetry events.
*   **Integration**: `boto3`
*   **Relation to Telemetry**: Successful uploads trigger a telemetry event containing the S3 bucket and key, linking the binary asset to the analytics record.
