---
name: Angular
description: Skill for building enterprise web applications with Angular — covering modules, components, services, dependency injection, RxJS, routing, forms, HttpClient, pipes, guards, and Angular CLI.
---

# Angular Skill

## Overview
Angular is a comprehensive TypeScript framework for building enterprise web applications. It provides signals-based reactivity, standalone components, dependency injection, RxJS integration, and a powerful CLI. Angular 17+ uses the modern control flow syntax (`@if`, `@for`).

**References**:
- [Angular Documentation](https://angular.dev/)
- [Angular CLI](https://angular.dev/tools/cli)
- [RxJS Documentation](https://rxjs.dev/)

---

## Setup

```bash
npm install -g @angular/cli
ng new myapp --standalone --routing --style=scss
cd myapp && ng serve
```

---

## Standalone Component with Signals

```typescript
// src/app/components/product-list/product-list.component.ts
import { Component, signal, computed, effect, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ProductService } from '../../services/product.service';
import { Product } from '../../models/product.model';

@Component({
  selector: 'app-product-list',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  template: `
    <div class="product-list">
      <div class="filters">
        <input
          [(ngModel)]="searchQuery"
          placeholder="Search products..."
          class="search-input"
        />
        <select [(ngModel)]="sortBy">
          <option value="newest">Newest</option>
          <option value="price_asc">Price: Low to High</option>
          <option value="price_desc">Price: High to Low</option>
          <option value="rating">Highest Rated</option>
        </select>
        <span>{{ filteredProducts().length }} products</span>
      </div>

      @if (loading()) {
        <div class="loading">Loading...</div>
      } @else if (filteredProducts().length === 0) {
        <div class="empty">No products found</div>
      } @else {
        <div class="grid">
          @for (product of filteredProducts(); track product.id) {
            <div class="product-card" [routerLink]="['/products', product.slug]">
              <img [src]="product.images[0]" [alt]="product.name" />
              <h3>{{ product.name }}</h3>
              <p class="price">{{ product.price | currency:'IDR':'symbol-narrow' }}</p>
              <div class="rating">★ {{ product.rating.toFixed(1) }}</div>
              <button (click)="addToCart($event, product)" class="btn-cart">Add to Cart</button>
            </div>
          }
        </div>
      }
    </div>
  `,
})
export class ProductListComponent implements OnInit {
  private productService = inject(ProductService);

  products = signal<Product[]>([]);
  loading = signal(true);
  searchQuery = signal('');
  sortBy = signal('newest');

  filteredProducts = computed(() => {
    let result = this.products();
    const query = this.searchQuery().toLowerCase();

    if (query) {
      result = result.filter(p =>
        p.name.toLowerCase().includes(query) ||
        p.description?.toLowerCase().includes(query)
      );
    }

    switch (this.sortBy()) {
      case 'price_asc': return [...result].sort((a, b) => a.price - b.price);
      case 'price_desc': return [...result].sort((a, b) => b.price - a.price);
      case 'rating': return [...result].sort((a, b) => b.rating - a.rating);
      default: return result;
    }
  });

  constructor() {
    effect(() => {
      console.log('Filtered count:', this.filteredProducts().length);
    });
  }

  async ngOnInit() {
    const data = await this.productService.getProducts();
    this.products.set(data);
    this.loading.set(false);
  }

  addToCart(event: Event, product: Product) {
    event.stopPropagation();
    // Cart logic
  }
}
```

---

## Service with HttpClient

```typescript
// src/app/services/product.service.ts
import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
import { Product, PaginatedResponse } from '../models/product.model';

@Injectable({ providedIn: 'root' })
export class ProductService {
  private http = inject(HttpClient);
  private baseUrl = '/api/products';

  async getProducts(params?: {
    category?: string; search?: string; sort?: string; page?: number; limit?: number;
  }): Promise<Product[]> {
    let httpParams = new HttpParams();
    if (params?.category) httpParams = httpParams.set('category', params.category);
    if (params?.search) httpParams = httpParams.set('search', params.search);
    if (params?.sort) httpParams = httpParams.set('sort', params.sort);
    if (params?.page) httpParams = httpParams.set('page', params.page.toString());
    if (params?.limit) httpParams = httpParams.set('limit', params.limit.toString());

    const res = await firstValueFrom(
      this.http.get<PaginatedResponse<Product>>(this.baseUrl, { params: httpParams })
    );
    return res.data;
  }

  async getProduct(slug: string): Promise<Product> {
    return firstValueFrom(this.http.get<Product>(`${this.baseUrl}/${slug}`));
  }

  async createProduct(data: Partial<Product>): Promise<Product> {
    return firstValueFrom(this.http.post<Product>(this.baseUrl, data));
  }

  async updateProduct(id: string, data: Partial<Product>): Promise<Product> {
    return firstValueFrom(this.http.put<Product>(`${this.baseUrl}/${id}`, data));
  }

  async deleteProduct(id: string): Promise<void> {
    await firstValueFrom(this.http.delete(`${this.baseUrl}/${id}`));
  }
}
```

---

## Routes with Guards

```typescript
// src/app/app.routes.ts
import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';
import { adminGuard } from './guards/admin.guard';

export const routes: Routes = [
  { path: '', loadComponent: () => import('./pages/home/home.component').then(m => m.HomeComponent) },
  { path: 'products', loadComponent: () => import('./pages/products/products.component').then(m => m.ProductsComponent) },
  { path: 'products/:slug', loadComponent: () => import('./pages/product-detail/product-detail.component').then(m => m.ProductDetailComponent) },
  { path: 'login', loadComponent: () => import('./pages/login/login.component').then(m => m.LoginComponent) },
  {
    path: 'dashboard',
    canActivate: [authGuard],
    loadComponent: () => import('./pages/dashboard/dashboard.component').then(m => m.DashboardComponent),
  },
  {
    path: 'admin',
    canActivate: [authGuard, adminGuard],
    loadChildren: () => import('./pages/admin/admin.routes').then(m => m.adminRoutes),
  },
  { path: '**', loadComponent: () => import('./pages/not-found/not-found.component').then(m => m.NotFoundComponent) },
];
```

```typescript
// src/app/guards/auth.guard.ts
import { inject } from '@angular/core';
import { Router, CanActivateFn } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isAuthenticated()) return true;
  return router.createUrlTree(['/login']);
};
```

---

## HTTP Interceptor

```typescript
// src/app/interceptors/auth.interceptor.ts
import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { AuthService } from '../services/auth.service';

export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const auth = inject(AuthService);
  const token = auth.getAccessToken();

  if (token) {
    req = req.clone({
      setHeaders: { Authorization: `Bearer ${token}` },
    });
  }

  return next(req);
};
```

```typescript
// src/app/app.config.ts
import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { routes } from './app.routes';
import { authInterceptor } from './interceptors/auth.interceptor';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideHttpClient(withInterceptors([authInterceptor])),
  ],
};
```

---

## Reactive Forms

```typescript
// src/app/pages/login/login.component.ts
import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <div class="field">
        <label for="email">Email</label>
        <input id="email" type="email" formControlName="email" />
        @if (form.get('email')?.invalid && form.get('email')?.touched) {
          <span class="error">Valid email is required</span>
        }
      </div>
      <div class="field">
        <label for="password">Password</label>
        <input id="password" type="password" formControlName="password" />
        @if (form.get('password')?.invalid && form.get('password')?.touched) {
          <span class="error">Password must be at least 8 characters</span>
        }
      </div>
      @if (error) { <div class="error-message">{{ error }}</div> }
      <button type="submit" [disabled]="form.invalid || loading">
        {{ loading ? 'Signing in...' : 'Sign In' }}
      </button>
    </form>
  `,
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private auth = inject(AuthService);
  private router = inject(Router);

  form = this.fb.nonNullable.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  loading = false;
  error = '';

  async onSubmit() {
    if (this.form.invalid) return;
    this.loading = true;
    this.error = '';

    try {
      await this.auth.login(this.form.getRawValue());
      this.router.navigate(['/dashboard']);
    } catch (e: any) {
      this.error = e.error?.message || 'Login failed';
    } finally {
      this.loading = false;
    }
  }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Standalone** | Use standalone components (no NgModules) |
| **Signals** | Use `signal()`, `computed()`, `effect()` for reactivity |
| **Control flow** | Use `@if`, `@for`, `@switch` instead of `*ngIf`, `*ngFor` |
| **inject()** | Use `inject()` instead of constructor DI |
| **Lazy loading** | Use `loadComponent` / `loadChildren` for routes |
| **Functional guards** | Use `CanActivateFn` instead of class-based guards |
| **Interceptors** | Functional `HttpInterceptorFn` for auth tokens |
| **firstValueFrom** | Convert Observable to Promise when needed |
| **Reactive forms** | Use `FormBuilder.nonNullable` for type safety |
| **Track** | Always use `track` property in `@for` blocks |

---

## Rules Integration
- **Components**: Standalone with signals and modern control flow
- **Services**: HttpClient with firstValueFrom for async/await
- **Routing**: Lazy-loaded routes with functional guards
- **Forms**: Reactive forms with validation and type safety
- **DI**: Function-based inject(), interceptors, guards
