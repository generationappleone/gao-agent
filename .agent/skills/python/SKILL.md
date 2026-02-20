---
name: Python
description: Skill for Python development, covering project setup, type hints, async programming, web frameworks (FastAPI, Django), testing, packaging, and best practices.
---

# Python Skill

## Overview
Python is a versatile programming language for web development (Django, Flask, FastAPI), data science, automation, and AI/ML. Modern Python (3.12+) provides type hints, async/await, pattern matching, dataclasses, and powerful standard library.

**References**:
- [Python Documentation](https://docs.python.org/3/)
- [FastAPI](https://fastapi.tiangolo.com/)

---

## FastAPI Application

```python
# main.py
from fastapi import FastAPI, HTTPException, Depends, Query
from pydantic import BaseModel, Field
from typing import Optional
from uuid import UUID, uuid4
from datetime import datetime

app = FastAPI(title="MyApp API", version="1.0.0")

# Models with Pydantic
class ProductCreate(BaseModel):
    name: str = Field(min_length=2, max_length=200)
    price: int = Field(ge=0)
    description: str = ""
    category_id: UUID

class ProductResponse(BaseModel):
    id: UUID
    name: str
    slug: str
    price: int
    status: str
    created_at: datetime

    model_config = {"from_attributes": True}

class PaginatedResponse(BaseModel):
    data: list[ProductResponse]
    total: int
    page: int
    total_pages: int

# Routes
@app.get("/api/products", response_model=PaginatedResponse)
async def list_products(
    page: int = Query(default=1, ge=1),
    search: Optional[str] = None,
    category: Optional[str] = None,
):
    # Database query with pagination
    products, total = await product_service.list(page=page, search=search, category=category)
    return PaginatedResponse(data=products, total=total, page=page, total_pages=(total + 19) // 20)

@app.post("/api/products", response_model=ProductResponse, status_code=201)
async def create_product(data: ProductCreate, user=Depends(get_current_admin)):
    return await product_service.create(data)

@app.get("/api/products/{slug}", response_model=ProductResponse)
async def get_product(slug: str):
    product = await product_service.get_by_slug(slug)
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    return product
```

---

## Modern Python Patterns

```python
# Dataclasses
from dataclasses import dataclass, field

@dataclass
class Config:
    debug: bool = False
    database_url: str = ""
    redis_url: str = ""
    cors_origins: list[str] = field(default_factory=list)

# Pattern matching (3.10+)
def handle_status(status: str) -> str:
    match status:
        case "pending": return "Waiting for processing"
        case "processing": return "Being prepared"
        case "shipped": return "On the way"
        case _: return "Unknown status"

# Type hints
def calculate_total(items: list[dict[str, int]], tax_rate: float = 0.11) -> int:
    subtotal = sum(item["price"] * item["quantity"] for item in items)
    return round(subtotal * (1 + tax_rate))

# Context managers
from contextlib import asynccontextmanager

@asynccontextmanager
async def get_db():
    session = SessionLocal()
    try:
        yield session
        await session.commit()
    except Exception:
        await session.rollback()
        raise
    finally:
        await session.close()
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Type hints** | Use type annotations for all functions |
| **Pydantic** | Data validation and serialization |
| **FastAPI** | Async REST API with auto-docs |
| **Dataclasses** | Structured configuration objects |
| **Pattern matching** | Structural pattern matching (3.10+) |
| **async/await** | Use for I/O-bound operations |
| **Context managers** | Resource management with `with`/`async with` |
| **Virtual env** | Use venv or poetry for dependencies |
| **pytest** | Test framework with fixtures |
| **Black + Ruff** | Code formatting and linting |

---

## Rules Integration
- **API**: FastAPI with Pydantic models and type hints
- **Models**: Pydantic for validation, dataclasses for config
- **Async**: async/await for database, HTTP operations
- **Modern**: Pattern matching, type hints, f-strings
