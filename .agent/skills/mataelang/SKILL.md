---
name: "MataElang OS"
description: "High-performance enterprise network monitoring system built with Python, FastAPI, and SQLAlchemy."
dependencies:
  - "fastapi"
  - "sqlalchemy"
  - "aiohttp"
  - "icmplib"
  - "reportlab"
  - "pydantic"
  - "speedtest-cli"
---

# 🦅 MataElang (MatEl) OS — Development Guide

This skill provides a comprehensive understanding of the **MataElang (MatEl) OS** codebase. MataElang is a high-performance network monitoring and surveillance system utilizing asynchronous Python (FastAPI, aiohttp) and a SQLite database optimized with Write-Ahead Logging (WAL). It natively supports HTTP, ICMP (Ping), SSL expiry checks, TCP port scanning, GHOST path vulnerability scanning, and ECO efficiency audits.

## 🏗️ Architecture & Stack

MataElang OS is built as a highly concurrent monolithic backend.

*   **Framework**: FastAPI (ASGI) for high-performance REST APIs and WebSockets.
*   **Database**: SQLite with `PRAGMA journal_mode=WAL` for concurrent background task safety, managed via SQLAlchemy ORM.
*   **Concurrency**: Uses `asyncio` and `aiohttp` for massive concurrency in monitoring tasks without threading overhead.
*   **Data Validation**: Pydantic for rigid schema validation and data parsing.
*   **Authentication**: JWT (JSON Web Tokens) with Argon2 password hashing.
*   **Deployment Target**: The core engine is designed to be compiled down to C-extensions via **Cython (`.pyd` or `.so`)** for performance and IP protection.

## 📁 Project Structure

The codebase is organized in a flat, modular structure:

*   `main.py`: The entry point. Initializes FastAPI, sets up the ASGI lifespan (background tasks), handles WebSockets, and maps the primary routing for auth and monitors.
*   `database.py`: SQLAlchemy engine setup and connection pooling. Critically configures SQLite WAL mode.
*   `models.py`: SQLAlchemy declarative Base classes representing the database tables.
*   `schemas.py`: Pydantic models for request validation and response serialization.
*   `crud.py`: Data access layer. Contains all functions that interact directly with the SQLAlchemy Session.
*   `monitoring.py`: The core `MonitoringEngine`. Contains the asynchronous logic for all network telemetry checks.
*   `notifications.py`: The alerting engine. Formats messages and dispatches them via Telegram or other integrated channels.
*   `auth.py`: Cryptographic utilities. Handles Argon2 hashing and JWT token generation/validation.
*   `net_tools.py`: Wrappers around synchronous blocking tools (like `speedtest-cli` and `icmplib.traceroute`) utilizing `asyncio.run_in_executor`. Also houses the PDF/CSV report generation logic using ReportLab.
*   `email_utils.py`: Asynchronous email dispatcher using `fastapi-mail` for user registration and recovery workflows.
*   `run_matel.py`: The production launcher. Designed to import the compiled `main` module via uvicorn.

## 🧠 Core Systems Deep Dive

### 1. The Asynchronous Monitoring Engine (`monitoring.py`)

The heart of MataElang is the `MonitoringEngine` class. It utilizes `aiohttp.ClientSession` for network requests to avoid blocking the main event loop.

#### HTTP Checks & Defacement Detection
It performs an HTTP GET. If `expected_hash` is provided, it calculates the SHA-256 hash of the response content and compares it to detect unauthorized modifications (web defacement).

#### GHOST Path Probing (`check_ghost_paths`)
A highly aggressive asynchronous web crawler. It parses HTML responses, extracting `href` and `src` attributes, and attempts to resolve paths to discover exposed sensitive files (e.g., `.env`, `.git/config`, `phpinfo.php`).

#### Port Scanning (`check_port_scan`)
Uses `asyncio.open_connection` with a strict timeout (2.0s) to concurrently map open ports against a baseline string (`expected_ports`).

### 2. The Background Event Loop (`main.py`)

FastAPI's `@asynccontextmanager` (`lifespan`) manages the lifecycle of the application's background workers independent of HTTP requests.

```python
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await monitoring_engine.start() # Initialize aiohttp session
    monitoring_task = asyncio.create_task(monitoring_loop(interval=30))
    traffic_task = asyncio.create_task(traffic_simulation_loop())
    
    yield # Application serves requests here
    
    # Teardown
    monitoring_task.cancel()
    traffic_task.cancel()
    await monitoring_engine.stop()
```

The `monitoring_loop` periodically fetches all monitors, injects them into `check_multiple_monitors` (which uses `asyncio.gather`), assesses status changes, and fires the `notification_service`.

### 3. Distributed Tracing & Visualization (WebSockets)

`main.py` incorporates a WebSocket endpoint (`/ws/traffic`) pushed by a background task `traffic_simulation_loop`. The background task continuously resolves geographic targets (using simulated source cities) and broadcasts JSON payloads to connected monitoring dashboards (NOC-style view).

### 4. Database Safety and Concurrency (`database.py`)

Because the application runs a heavy background `asyncio` loop that constantly writes heartbeats while serving API requests, SQLite requires specific tuning to avoid "database is locked" errors.

```python
# Enable WAL Mode for SQLite stability (Crucial for background tasks)
@event.listens_for(engine, "connect")
def set_sqlite_pragma(dbapi_connection, connection_record):
    cursor = dbapi_connection.cursor()
    cursor.execute("PRAGMA journal_mode=WAL") # Write-Ahead Logging
    cursor.execute("PRAGMA synchronous=NORMAL")
    cursor.close()
```

## 🔒 Security & Performance Features

*   **Argon2 Hashing**: `auth.py` utilizes Argon2, defending against GPU-based password cracking.
*   **Thread Pools for Blocking Ops**: `net_tools.py` uses `ThreadPoolExecutor` for synchronous, blocking libraries. `speedtest-cli` and the synchronous `traceroute` from `icmplib` must *never* be run directly on the main event loop.
*   **FastAPI BackgroundTasks**: Email sending (`email_utils.py`) is offloaded to FastAPI's built-in `BackgroundTasks` attached to the request, returning an immediate 200 OK to the client.

## ✨ Development Best Practices (Rules)

When modifying the MataElang codebase, MUST follow these constraints:

### Asynchronous Purity
Do **not** introduce any synchronous, blocking network calls or long-running CPU tasks in the API endpoints or the `monitoring_loop`. If you must use a sync library (like report generation), offload it using `asyncio.get_event_loop().run_in_executor()`.

### Database Session Lifecycle
The `get_db` dependency yields a Session. Background tasks **must not** share Sessions. Background tasks like `monitoring_loop` must safely generate and cleanly close their own Session instances using the `get_db` generator.

```python
# CORRECT pattern for background tasks
db_gen = get_db()
db = next(db_gen)
try:
    # Use db here
finally:
    db.close()
```

### Type Safety and Validation
Always construct responses using Pydantic schemas (defined in `schemas.py`). Do not return raw SQLAlchemy models or dicts from route endpoints unless explicitly typed via `response_model`.

### Cython Constraints
Because the final application is compiled via Cython (`.pyd` or `.so`), ensure that any dynamic loading, introspection (`inspect` module), or complex decorators are tested locally, as Cython occasionally struggles with advanced metaprogramming.

## 🛠️ Modifying the Telemetry Modules (`monitoring.py`)

If you are adding a new monitoring capability (e.g., DNS resolution checks or Database connection pinging):
1.  Add the new type to the `MonitorType` Enum in `models.py`.
2.  Create the asynchronous logic inside the `MonitoringEngine` class in `monitoring.py`.
3.  Execute the payload safely within a `try/except` block and standardize the return type to `Tuple[MonitorStatus, Optional[float], float, Optional[str]]` (Status, Latency, Packet Loss, Error Message).
4.  Map the new type inside the routing `check_monitor` function switch block.
