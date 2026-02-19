---
name: Flask
description: Skill for building web applications with Flask — covering project structure, blueprints, REST APIs, authentication, database integration (SQLAlchemy), testing, and deployment.
---

# Flask Skill

## Overview
**Flask** is a lightweight Python web framework (microframework). It provides routing, templating (Jinja2), and request handling, with extensions for everything else (ORM, auth, CORS, etc.).

---

## Project Structure

```
my_app/
├── app/
│   ├── __init__.py          # Application factory
│   ├── config.py            # Configuration
│   ├── extensions.py        # Extension instances (db, migrate, etc.)
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   └── order.py
│   ├── api/
│   │   ├── __init__.py      # Blueprint registration
│   │   ├── auth.py          # Auth routes
│   │   ├── users.py         # User CRUD
│   │   └── orders.py        # Order CRUD
│   ├── services/
│   │   ├── auth_service.py
│   │   └── user_service.py
│   ├── schemas/             # Marshmallow/Pydantic schemas
│   │   ├── user_schema.py
│   │   └── order_schema.py
│   └── utils/
│       ├── errors.py        # Error handlers
│       └── decorators.py    # Auth decorators
├── migrations/              # Alembic migrations
├── tests/
│   ├── conftest.py
│   ├── test_auth.py
│   └── test_users.py
├── .env
├── .flaskenv
├── requirements.txt
└── wsgi.py                  # WSGI entry point
```

---

## Application Factory

```python
# app/__init__.py
from flask import Flask
from app.config import Config
from app.extensions import db, migrate, cors, jwt

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)
    
    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    cors.init_app(app, resources={r"/api/*": {"origins": app.config['CORS_ORIGINS']}})
    jwt.init_app(app)
    
    # Register blueprints
    from app.api.auth import auth_bp
    from app.api.users import users_bp
    from app.api.orders import orders_bp
    
    app.register_blueprint(auth_bp, url_prefix='/api/v1/auth')
    app.register_blueprint(users_bp, url_prefix='/api/v1/users')
    app.register_blueprint(orders_bp, url_prefix='/api/v1/orders')
    
    # Register error handlers
    from app.utils.errors import register_error_handlers
    register_error_handlers(app)
    
    return app

# app/extensions.py
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from flask_jwt_extended import JWTManager

db = SQLAlchemy()
migrate = Migrate()
cors = CORS()
jwt = JWTManager()

# app/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'sqlite:///app.db')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'jwt-dev-secret')
    JWT_ACCESS_TOKEN_EXPIRES = 900  # 15 minutes
    CORS_ORIGINS = os.environ.get('CORS_ORIGINS', 'http://localhost:5173').split(',')

class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
```

---

## REST API Blueprint

```python
# app/api/users.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.models.user import User
from app.schemas.user_schema import UserSchema
from app.extensions import db

users_bp = Blueprint('users', __name__)
user_schema = UserSchema()
users_schema = UserSchema(many=True)

@users_bp.route('/', methods=['GET'])
@jwt_required()
def get_users():
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    query = User.query.filter_by(is_active=True)
    
    # Filtering
    if role := request.args.get('role'):
        query = query.filter_by(role=role)
    
    # Sorting
    sort = request.args.get('sort', 'created_at')
    order = request.args.get('order', 'desc')
    sort_col = getattr(User, sort, User.created_at)
    query = query.order_by(sort_col.desc() if order == 'desc' else sort_col.asc())
    
    pagination = query.paginate(page=page, per_page=per_page, error_out=False)
    
    return jsonify({
        'success': True,
        'data': users_schema.dump(pagination.items),
        'meta': {
            'page': pagination.page,
            'per_page': pagination.per_page,
            'total': pagination.total,
            'total_pages': pagination.pages,
        }
    })

@users_bp.route('/<uuid:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    user = User.query.get_or_404(str(user_id))
    return jsonify({'success': True, 'data': user_schema.dump(user)})

@users_bp.route('/<uuid:user_id>', methods=['PATCH'])
@jwt_required()
def update_user(user_id):
    user = User.query.get_or_404(str(user_id))
    data = request.get_json()
    
    for key, value in data.items():
        if hasattr(user, key) and key not in ('id', 'created_at', 'password_hash'):
            setattr(user, key, value)
    
    db.session.commit()
    return jsonify({'success': True, 'data': user_schema.dump(user)})
```

---

## Error Handling

```python
# app/utils/errors.py
from flask import jsonify
from werkzeug.exceptions import HTTPException

def register_error_handlers(app):
    @app.errorhandler(400)
    def bad_request(e):
        return jsonify({'success': False, 'error': {'code': 'BAD_REQUEST', 'message': str(e)}}), 400
    
    @app.errorhandler(404)
    def not_found(e):
        return jsonify({'success': False, 'error': {'code': 'NOT_FOUND', 'message': 'Resource not found'}}), 404
    
    @app.errorhandler(422)
    def validation_error(e):
        return jsonify({'success': False, 'error': {'code': 'VALIDATION_ERROR', 'message': str(e)}}), 422
    
    @app.errorhandler(500)
    def internal_error(e):
        return jsonify({'success': False, 'error': {'code': 'INTERNAL_ERROR', 'message': 'Internal server error'}}), 500
```

---

## Testing

```python
# tests/conftest.py
import pytest
from app import create_app
from app.config import TestConfig
from app.extensions import db as _db

@pytest.fixture
def app():
    app = create_app(TestConfig)
    with app.app_context():
        _db.create_all()
        yield app
        _db.drop_all()

@pytest.fixture
def client(app):
    return app.test_client()

@pytest.fixture
def auth_headers(client):
    # Register + login to get token
    client.post('/api/v1/auth/register', json={'email': 'test@test.com', 'password': 'Test123!@#'})
    res = client.post('/api/v1/auth/login', json={'email': 'test@test.com', 'password': 'Test123!@#'})
    token = res.json['token']
    return {'Authorization': f'Bearer {token}'}

# tests/test_users.py
def test_get_users(client, auth_headers):
    res = client.get('/api/v1/users/', headers=auth_headers)
    assert res.status_code == 200
    assert res.json['success'] is True
```

## Best Practices
1. **Application factory** — always use `create_app()` pattern
2. **Blueprints** for modularity — group related routes
3. **Extensions in separate file** — avoid circular imports
4. **Schemas for validation** — Marshmallow or Pydantic
5. **Config from environment** — never hardcode secrets
6. **Gunicorn for production** — `gunicorn -w 4 -b 0.0.0.0:5000 wsgi:app`
7. **Alembic for migrations** — `flask db migrate`, `flask db upgrade`
