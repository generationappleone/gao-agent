---
name: Flask
description: Skill for building web applications with Flask — covering project structure, blueprints, REST APIs, authentication, database integration (SQLAlchemy), testing, and deployment.
---

# Flask Skill

## Overview
Flask is a lightweight Python micro-framework for building web applications and APIs. It provides routing, request handling, and extension support while staying minimal and flexible. Flask-SQLAlchemy, Flask-Migrate, and Flask-JWT-Extended are the most common extensions.

**References**:
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Flask-SQLAlchemy](https://flask-sqlalchemy.palletsprojects.com/)
- [Flask-JWT-Extended](https://flask-jwt-extended.readthedocs.io/)

---

## Setup

```bash
pip install flask flask-sqlalchemy flask-migrate flask-jwt-extended flask-cors marshmallow
```

---

## Application Factory

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from flask_cors import CORS

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    # Initialize extensions
    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)
    CORS(app)

    # Register blueprints
    from app.api.auth import auth_bp
    from app.api.products import products_bp
    from app.api.orders import orders_bp

    app.register_blueprint(auth_bp, url_prefix='/api/auth')
    app.register_blueprint(products_bp, url_prefix='/api/products')
    app.register_blueprint(orders_bp, url_prefix='/api/orders')

    # Register error handlers
    register_error_handlers(app)

    return app


def register_error_handlers(app):
    @app.errorhandler(400)
    def bad_request(e):
        return {'error': 'Bad request', 'message': str(e)}, 400

    @app.errorhandler(404)
    def not_found(e):
        return {'error': 'Not found'}, 404

    @app.errorhandler(422)
    def unprocessable(e):
        return {'error': 'Validation error', 'message': str(e)}, 422

    @app.errorhandler(500)
    def server_error(e):
        return {'error': 'Internal server error'}, 500
```

---

## Configuration

```python
# app/config.py
import os

class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'change-me')
    SQLALCHEMY_DATABASE_URI = os.environ.get('DATABASE_URL', 'postgresql://localhost/myapp')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'jwt-change-me')
    JWT_ACCESS_TOKEN_EXPIRES = 3600  # 1 hour
    JWT_REFRESH_TOKEN_EXPIRES = 2592000  # 30 days

class DevelopmentConfig(Config):
    DEBUG = True

class ProductionConfig(Config):
    DEBUG = False

class TestingConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'

config = {
    'development': DevelopmentConfig,
    'production': ProductionConfig,
    'testing': TestingConfig,
    'default': DevelopmentConfig,
}
```

---

## Models

```python
# app/models/user.py
import uuid
from werkzeug.security import generate_password_hash, check_password_hash
from app import db

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = db.Column(db.String(255), unique=True, nullable=False, index=True)
    password_hash = db.Column(db.String(255), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    role = db.Column(db.String(20), nullable=False, default='user')
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    orders = db.relationship('Order', backref='user', lazy='dynamic')

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)

    def to_dict(self):
        return {'id': self.id, 'email': self.email, 'name': self.name, 'role': self.role, 'created_at': self.created_at.isoformat()}


# app/models/product.py
class Category(db.Model):
    __tablename__ = 'categories'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(100), nullable=False)
    slug = db.Column(db.String(100), unique=True, nullable=False)
    products = db.relationship('Product', backref='category', lazy='dynamic')

class Product(db.Model):
    __tablename__ = 'products'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name = db.Column(db.String(200), nullable=False)
    slug = db.Column(db.String(200), unique=True, nullable=False)
    description = db.Column(db.Text)
    price = db.Column(db.Integer, nullable=False, default=0)
    stock = db.Column(db.Integer, nullable=False, default=0)
    category_id = db.Column(db.String(36), db.ForeignKey('categories.id'), nullable=False)
    status = db.Column(db.String(10), nullable=False, default='draft', index=True)
    rating = db.Column(db.Float, default=0)
    rating_count = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    __table_args__ = (
        db.Index('idx_products_status_category', 'status', 'category_id'),
    )

    def to_dict(self):
        return {
            'id': self.id, 'name': self.name, 'slug': self.slug,
            'description': self.description, 'price': self.price,
            'stock': self.stock, 'status': self.status,
            'category': {'id': self.category.id, 'name': self.category.name} if self.category else None,
            'rating': self.rating, 'rating_count': self.rating_count,
            'created_at': self.created_at.isoformat(),
        }
```

---

## Auth Blueprint

```python
# app/api/auth.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, create_refresh_token, jwt_required, get_jwt_identity
from app import db
from app.models.user import User

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already exists'}), 409

    user = User(email=data['email'], name=data['name'])
    user.set_password(data['password'])
    db.session.add(user)
    db.session.commit()

    return jsonify({'user': user.to_dict()}), 201

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data['email']).first()
    if not user or not user.check_password(data['password']):
        return jsonify({'error': 'Invalid credentials'}), 401

    access_token = create_access_token(identity=user.id, additional_claims={'role': user.role})
    refresh_token = create_refresh_token(identity=user.id)

    return jsonify({'access_token': access_token, 'refresh_token': refresh_token, 'user': user.to_dict()})

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def me():
    user = User.query.get_or_404(get_jwt_identity())
    return jsonify({'user': user.to_dict()})

@auth_bp.route('/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    identity = get_jwt_identity()
    access_token = create_access_token(identity=identity)
    return jsonify({'access_token': access_token})
```

---

## Products Blueprint

```python
# app/api/products.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from app import db
from app.models.product import Product

products_bp = Blueprint('products', __name__)

@products_bp.route('', methods=['GET'])
def list_products():
    page = request.args.get('page', 1, type=int)
    limit = request.args.get('limit', 20, type=int)
    search = request.args.get('search', '')
    category = request.args.get('category', '')
    sort_by = request.args.get('sort', 'newest')

    query = Product.query.filter_by(status='active')

    if search:
        query = query.filter(Product.name.ilike(f'%{search}%'))
    if category:
        query = query.filter(Product.category.has(slug=category))

    if sort_by == 'price_asc':
        query = query.order_by(Product.price.asc())
    elif sort_by == 'price_desc':
        query = query.order_by(Product.price.desc())
    elif sort_by == 'rating':
        query = query.order_by(Product.rating.desc())
    else:
        query = query.order_by(Product.created_at.desc())

    pagination = query.paginate(page=page, per_page=limit, error_out=False)

    return jsonify({
        'data': [p.to_dict() for p in pagination.items],
        'total': pagination.total,
        'page': page,
        'total_pages': pagination.pages,
    })

@products_bp.route('/<slug>', methods=['GET'])
def get_product(slug):
    product = Product.query.filter_by(slug=slug).first_or_404()
    return jsonify(product.to_dict())

@products_bp.route('', methods=['POST'])
@jwt_required()
def create_product():
    claims = get_jwt()
    if claims.get('role') != 'admin':
        return jsonify({'error': 'Forbidden'}), 403

    data = request.get_json()
    from app.utils import slugify
    product = Product(
        name=data['name'], slug=slugify(data['name']),
        description=data.get('description', ''), price=data['price'],
        stock=data.get('stock', 0), category_id=data['category_id'],
    )
    db.session.add(product)
    db.session.commit()
    return jsonify(product.to_dict()), 201
```

---

## Commands

```bash
# Database
flask db init
flask db migrate -m "Initial migration"
flask db upgrade

# Run
flask run --debug --port 5000

# Shell
flask shell
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **App factory** | Use `create_app()` pattern for testability |
| **Blueprints** | Organize related routes into blueprints |
| **Config classes** | Separate dev/prod/test configurations |
| **SQLAlchemy** | Use relationships, indexes, lazy loading |
| **JWT** | Access + refresh tokens with role claims |
| **Pagination** | Use `paginate()` for list endpoints |
| **Error handlers** | Register global error handlers |
| **to_dict()** | Model serialization method |
| **Migrations** | Use Flask-Migrate for schema changes |
| **Security** | Hash passwords, validate input, check roles |

---

## Rules Integration
- **Factory**: create_app() with extensions and blueprints
- **Models**: SQLAlchemy with UUID PKs, indexes, relationships
- **Auth**: JWT with access/refresh tokens and role claims
- **CRUD**: Blueprints with pagination, search, filtering
- **Admin**: Role-based access control via JWT claims
