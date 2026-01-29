# Telemetry Overview

## Introduction
This project employs a dual-telemetry strategy to ensure observability, debugging capabilities, and data collection for analytics. The telemetry system is designed to capture:
1.  **Application Logs**: Standard Python logging for runtime events and errors.
2.  **Custom Telemetry Events**: Structured events (EkStep format) for analytics, measuring user interactions, moderation results, and performance.
3.  **LLM Observability**: Integration with **Logfire** for tracing LLM execution, instrumenting agents, and debugging prompt performance.

## Why It Exists
The telemetry system solves several critical problems:
*   **User Journey Tracking**: Understanding how farmers interact with the voice assistant (e.g., questions asked, languages used).
*   **Safety & Compliance**: modifying moderation events to ensure queries are agricultural and safe strategies.
*   **Performance Monitoring**: Tracking API latency, translation success rates, and LLM response times.
*   **Debugging**: Tracing requests across the complex chain of agents (AgriNet, Moderation, Translation).

## Types of Telemetry Collected

### 1. Application Logs
*   **Source**: `logging` (standard library).
*   **Format**: `%(asctime)s - %(name)s - %(levelname)s - %(message)s`.
*   **Destination**: Console (stdout/stderr).
*   **Levels**: DEBUG (dev), INFO (prod), ERROR.

### 2. Custom Telemetry Events (EkStep / Sunbird Format)
*   **Source**: `app.tasks.telemetry.send_telemetry`.
*   **Format**: JSON (EkStep Scheme).
*   **Events**:
    *   `OE_START` / `OE_END`: Session lifecycle.
    *   `OE_INTERACT`: User interactions (e.g., clicks, voice inputs).
    *   `OE_MODERATION`: Results from the moderation agent.
    *   `OE_TRANSLATION`: Translation operational metrics.
    *   `OE_MEDIA`: Audio upload events.

### 3. Distributed Tracing & LLM Metrics
*   **Source**: `logfire` (Pydantic).
*   **Focus**: Internal state of AI agents, tool calls, and LLM inputs/outputs.
*   **Destination**: Logfire Cloud / Dashboard.

## Key Components
| Component | Responsibility | Status |
| :--- | :--- | :--- |
| **`app/tasks/telemetry.py`** | Background task to send JSON payloads to the configured telemetry API. | Implementation ready, currently optional in some flows. |
| **`helpers/telemetry.py`** | Pydantic models defining the strict schema for all telemetry events. | Active. |
| **`agents/__init__.py`** | Initializes Logfire for agent observability. | Active. |
| **`app/services/chat.py`** | Main entry point for generating chat-related telemetry (moderation, response). | Instrumentation logic exists but may be toggled off. |
