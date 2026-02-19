---
name: Python
description: Skill for Python development, covering project setup, type hints, async programming, web frameworks (FastAPI, Django), testing, packaging, and best practices.
---

# Python Skill

## Overview
Python is a versatile, high-level programming language. Use this skill for web backends (FastAPI, Django), data processing, automation, ML/AI, and scripting.

## Project Setup

### Modern Project Structure
```
project/
├── src/
│   └── my_app/
│       ├── __init__.py
│       ├── main.py              # Entry point
│       ├── config.py            # Settings (Pydantic)
│       ├── domain/              # Business logic (SRP)
│       │   ├── models.py
│       │   └── services.py
│       ├── infrastructure/      # External integrations (DIP)
│       │   ├── database.py
│       │   └── repositories.py
│       ├── api/                 # HTTP layer
│       │   ├── routes.py
│       │   ├── schemas.py       # Request/Response DTOs
│       │   └── dependencies.py
│       └── utils/
├── tests/
│   ├── conftest.py
│   ├── unit/
│   └── integration/
├── pyproject.toml               # Project metadata + dependencies
├── .env.example
├── Dockerfile
└── README.md
```

### pyproject.toml (Modern Standard)
```toml
[project]
name = "my-app"
version = "1.0.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.109.0,<0.110.0",
    "uvicorn[standard]>=0.27.0,<0.28.0",
    "pydantic>=2.6.0,<3.0.0",
    "pydantic-settings>=2.1.0,<3.0.0",
    "sqlalchemy[asyncio]>=2.0.0,<3.0.0",
    "asyncpg>=0.29.0,<0.30.0",
    "alembic>=1.13.0,<2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "pytest-cov>=4.1.0",
    "ruff>=0.2.0",
    "mypy>=1.8.0",
]
```

## Type Hints (MUST use)
```python
from typing import Protocol, runtime_checkable
from collections.abc import Sequence

# ✅ REQUIRED: Full type annotations
@runtime_checkable
class UserRepository(Protocol):
    async def find_by_id(self, user_id: str) -> User | None: ...
    async def find_all(self, limit: int = 50, offset: int = 0) -> Sequence[User]: ...
    async def create(self, data: CreateUserDto) -> User: ...
    async def update(self, user_id: str, data: UpdateUserDto) -> User: ...
    async def delete(self, user_id: str) -> bool: ...

class UserService:
    def __init__(self, repo: UserRepository, hasher: PasswordHasher) -> None:
        self._repo = repo
        self._hasher = hasher

    async def register(self, dto: CreateUserDto) -> User:
        hashed = self._hasher.hash(dto.password)
        return await self._repo.create(dto.model_copy(update={"password": hashed}))
```

## FastAPI Best Practices
```python
from fastapi import FastAPI, Depends, HTTPException, status
from pydantic import BaseModel, Field, EmailStr

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    password: str = Field(..., min_length=8, max_length=128)

class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

@router.post("/users", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def create_user(
    request: CreateUserRequest,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await service.register(CreateUserDto(**request.model_dump()))
    return UserResponse.from_orm(user)
```

## Async Programming
```python
import asyncio
from contextlib import asynccontextmanager

# ✅ Use async/await for I/O operations
async def fetch_all_data(user_ids: list[str]) -> list[dict]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_user(session, uid) for uid in user_ids]
        return await asyncio.gather(*tasks, return_exceptions=True)

# ✅ Use context managers for resource cleanup
@asynccontextmanager
async def get_db_session():
    session = async_session_factory()
    try:
        yield session
        await session.commit()
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()
```

## Testing
```python
import pytest
from unittest.mock import AsyncMock

@pytest.fixture
def mock_repo() -> AsyncMock:
    repo = AsyncMock(spec=UserRepository)
    repo.create.return_value = User(id="uuid-1", email="test@example.com", name="Test")
    return repo

@pytest.mark.asyncio
async def test_register_user(mock_repo: AsyncMock):
    service = UserService(repo=mock_repo, hasher=FakeHasher())
    user = await service.register(CreateUserDto(email="test@example.com", name="Test", password="pass1234"))

    assert user.email == "test@example.com"
    mock_repo.create.assert_called_once()
```

## Tools
| Tool | Purpose |
|------|---------|
| `ruff` | Linting + formatting (replaces flake8, black, isort) |
| `mypy` | Static type checking |
| `pytest` | Testing |
| `alembic` | Database migrations |
| `pip-audit` | Security vulnerability scanning |

## Rules Integration
- **SOLID**: Protocol classes (ISP/DIP), single-responsibility modules, dependency injection
- **Security**: Pydantic validation, `SecretStr`, argon2 hashing, parameterized queries
- **Dependencies**: `pyproject.toml` with version bounds, `pip-audit` before deploy
