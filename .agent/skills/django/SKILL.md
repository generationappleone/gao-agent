---
name: Django
description: Skill for building web applications with Django — covering project structure, models, views (CBV/FBV), Django REST Framework, authentication, admin, testing, and deployment.
---

# Django Skill

## Overview
**Django** is a high-level Python web framework that encourages rapid development. It includes ORM, admin panel, authentication, and many batteries-included features. Use **Django REST Framework (DRF)** for API development.

---

## Project Structure

```
my_project/
├── config/                  # Project-level config
│   ├── __init__.py
│   ├── settings/
│   │   ├── __init__.py
│   │   ├── base.py          # Shared settings
│   │   ├── development.py
│   │   ├── production.py
│   │   └── testing.py
│   ├── urls.py              # Root URL config
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── users/               # User management app
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── urls.py
│   │   ├── services.py
│   │   ├── tests/
│   │   ├── admin.py
│   │   └── apps.py
│   ├── orders/              # Orders app
│   └── core/                # Shared utilities
│       ├── models.py        # Base model (timestamps, soft delete)
│       ├── pagination.py
│       └── permissions.py
├── manage.py
├── requirements/
│   ├── base.txt
│   ├── development.txt
│   └── production.txt
└── docker-compose.yml
```

---

## Models

```python
# apps/core/models.py — Base model with common fields
import uuid
from django.db import models

class BaseModel(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_deleted = models.BooleanField(default=False)
    
    class Meta:
        abstract = True
        ordering = ['-created_at']

# apps/users/models.py
from django.contrib.auth.models import AbstractUser
from apps.core.models import BaseModel

class User(AbstractUser, BaseModel):
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=200)
    phone = models.CharField(max_length=20, blank=True)
    avatar = models.ImageField(upload_to='avatars/', blank=True)
    role = models.CharField(max_length=20, choices=[
        ('user', 'User'), ('admin', 'Admin'), ('editor', 'Editor'),
    ], default='user')
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['full_name']
    
    class Meta:
        db_table = 'users'

# apps/orders/models.py
class Order(BaseModel):
    user = models.ForeignKey('users.User', on_delete=models.CASCADE, related_name='orders')
    status = models.CharField(max_length=20, choices=[
        ('pending', 'Pending'), ('paid', 'Paid'),
        ('shipped', 'Shipped'), ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
    ], default='pending')
    total_amount = models.DecimalField(max_digits=12, decimal_places=2)
    notes = models.TextField(blank=True)
    
    class Meta:
        db_table = 'orders'
```

---

## Django REST Framework (DRF)

```python
# apps/users/serializers.py
from rest_framework import serializers
from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'full_name', 'role', 'avatar', 'created_at']
        read_only_fields = ['id', 'created_at']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=12)
    
    class Meta:
        model = User
        fields = ['email', 'full_name', 'password']
    
    def create(self, validated_data):
        return User.objects.create_user(**validated_data)

# apps/users/views.py
from rest_framework import viewsets, permissions, status
from rest_framework.decorators import action
from rest_framework.response import Response

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(is_deleted=False)
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        qs = super().get_queryset()
        if role := self.request.query_params.get('role'):
            qs = qs.filter(role=role)
        return qs
    
    @action(detail=False, methods=['get'])
    def me(self, request):
        serializer = self.get_serializer(request.user)
        return Response({'success': True, 'data': serializer.data})
    
    def perform_destroy(self, instance):
        instance.is_deleted = True  # Soft delete
        instance.save()

# apps/users/urls.py
from rest_framework.routers import DefaultRouter
from .views import UserViewSet

router = DefaultRouter()
router.register('users', UserViewSet, basename='users')
urlpatterns = router.urls
```

---

## Middleware

```python
# apps/core/middleware.py
import time
import logging

logger = logging.getLogger(__name__)

class RequestLoggingMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        start = time.monotonic()
        response = self.get_response(request)
        duration = (time.monotonic() - start) * 1000
        
        logger.info(
            "request_completed",
            extra={
                'method': request.method,
                'path': request.path,
                'status': response.status_code,
                'duration_ms': round(duration, 2),
                'user_id': str(request.user.id) if request.user.is_authenticated else None,
            }
        )
        return response
```

---

## Testing

```python
# apps/users/tests/test_views.py
from django.test import TestCase
from rest_framework.test import APIClient
from apps.users.models import User

class UserViewSetTest(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@test.com', password='TestPass123!@#',
            full_name='Test User'
        )
        self.client.force_authenticate(user=self.user)
    
    def test_list_users(self):
        response = self.client.get('/api/v1/users/')
        self.assertEqual(response.status_code, 200)
        self.assertTrue(response.data['success'])
    
    def test_get_me(self):
        response = self.client.get('/api/v1/users/me/')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data['data']['email'], 'test@test.com')

# Run: python manage.py test apps/
```

## Best Practices
1. **Custom User model from day 1** — `AbstractUser` with email as username
2. **Apps for features** — keep apps focused and reusable
3. **DRF for APIs** — ViewSets + Routers for consistent REST
4. **Signals sparingly** — prefer explicit service calls over implicit signals
5. **Celery for async** — offload heavy work (email, reports) to task queue
6. **Django admin** — customize for operations team, don't expose publicly
7. **Gunicorn + Nginx** for production — `gunicorn config.wsgi:application -w 4`
