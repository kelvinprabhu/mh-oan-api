# Project Overview

## 1. Introduction
**MahaVistaar AI** (also referred to as MH-OAN-API) is an advanced, AI-powered voice assistant designed to empower farmers in Maharashtra by providing real-time, actionable agricultural information in their local language (Marathi).

### The Problem
Farmers often face challenges in accessing timely and accurate information regarding:
- Weather forecasts and historical data.
- Real-time market prices (Mandi rates).
- Government schemes and subsidies.
- Expert agricultural advice.

Existing solutions are often fragmented, text-heavy, or not available in local dialects, creating a digital divide.

### The Solution
MahaVistaar AI bridges this gap by offering a voice-first interface that farmers can interact with naturally. It aggregates data from multiple sources (Weather APIs, Agmarknet, MahaDBT, AgriStack) and uses Large Language Models (LLMs) to synthesize easy-to-understand responses.

## 2. Target Users & Use Cases
- **Primary Users**: Farmers in Maharashtra.
- **Key Use Cases**:
    - "What is today's market price for onions in Nashik?"
    - "Will it rain tomorrow in Pune?"
    - "Explain the PM-Kisan scheme requirements."
    - "How do I control pests on my cotton crop?"

## 3. System Behavior
1.  **Input**: The system accepts voice or text input (via an integrated frontend or WhatsApp bot).
2.  **Processing**:
    -   **Transcription/Translation**: Voice is converted to text and translated to English.
    -   **Moderation**: Input is checked for safety and relevance to agriculture.
    -   **Agentic Reasoning**: An AI agent analyzes the intent and selects appropriate tools (e.g., fetch weather, search schemes).
    -   **Tool Execution**: The system queries external APIs or databases.
    -   **Synthesis**: The LLM generates a cohesive response in English, which is then translated back to Marathi.
3.  **Output**: The user receives a text response and/or a synthesized voice response.

## 4. Technology Stack

### Core Frameworks
-   **Language**: Python 3.10+
-   **Web Framework**: FastAPI (High-performance Async API)
-   **AI Framework**: PydanticAI (Type-safe agent definition)

### Infrastructure & Databases
-   **Caching & Broker**: Redis (Message queue, Caching)
-   **Vector Database**: Marqo (Semantic search for documents/schemes)
-   **Containerization**: Docker & Docker Compose

### AI & Integrations
-   **LLMs**: OAN-hosted models, OpenAI, or other providers (configurable).
-   **Translation/Transcriptions**: Bhashini / Sarvam AI.
-   **External Data Sources**:
    -   Mandi Prices (Agmarknet)
    -   Weather APIs
    -   MahaDBT (Schemes)
    -   AgriStack

### Observability
-   **Telemetry**: Custom telemetry service integration.
-   **Logging**: Python standard logging with structured formats.
