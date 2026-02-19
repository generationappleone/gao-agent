---
name: Angular
description: Skill for building enterprise web applications with Angular — covering modules, components, services, dependency injection, RxJS, routing, forms, HttpClient, pipes, guards, and Angular CLI.
---

# Angular Skill

## Overview
Angular is a TypeScript-based platform for building enterprise applications. This skill covers Angular 17+ with standalone components as the modern standard.

**Reference**: [Angular Documentation](https://angular.dev/)

## Project Setup
```bash
npx -y @angular/cli@latest new my-app --standalone --style=scss --routing --ssr=false
```

## Standalone Component
```typescript
// user-list.component.ts
import { Component, inject, OnInit, signal, computed } from "@angular/core";
import { CommonModule } from "@angular/common";
import { UserService } from "./user.service";

@Component({
  selector: "app-user-list",
  standalone: true,
  imports: [CommonModule],
  template: `
    <h2>Users ({{ count() }})</h2>
    <input [ngModel]="search()" (ngModelChange)="search.set($event)" placeholder="Search..." />
    @if (loading()) {
      <p>Loading...</p>
    } @else {
      <ul>
        @for (user of filteredUsers(); track user.id) {
          <li>{{ user.name }} — {{ user.email }}</li>
        }
      </ul>
    }
  `,
})
export class UserListComponent implements OnInit {
  private userService = inject(UserService);

  users = signal<User[]>([]);
  search = signal("");
  loading = signal(false);

  filteredUsers = computed(() =>
    this.users().filter(u => u.name.toLowerCase().includes(this.search().toLowerCase()))
  );
  count = computed(() => this.filteredUsers().length);

  async ngOnInit() {
    this.loading.set(true);
    this.users.set(await this.userService.getAll());
    this.loading.set(false);
  }
}
```

## Services & Dependency Injection
```typescript
// user.service.ts
import { Injectable, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { firstValueFrom } from "rxjs";

@Injectable({ providedIn: "root" })
export class UserService {
  private http = inject(HttpClient);
  private apiUrl = "/api/users";

  async getAll(): Promise<User[]> {
    return firstValueFrom(this.http.get<User[]>(this.apiUrl));
  }

  async getById(id: string): Promise<User> {
    return firstValueFrom(this.http.get<User>(`${this.apiUrl}/${id}`));
  }

  async create(user: Partial<User>): Promise<User> {
    return firstValueFrom(this.http.post<User>(this.apiUrl, user));
  }
}
```

## Routing
```typescript
// app.routes.ts
import { Routes } from "@angular/router";
import { authGuard } from "./guards/auth.guard";

export const routes: Routes = [
  { path: "", loadComponent: () => import("./pages/home.component").then(m => m.HomeComponent) },
  { path: "users", loadComponent: () => import("./pages/users.component").then(m => m.UsersComponent) },
  { path: "users/:id", loadComponent: () => import("./pages/user-detail.component").then(m => m.UserDetailComponent) },
  { path: "dashboard", loadComponent: () => import("./pages/dashboard.component").then(m => m.DashboardComponent), canActivate: [authGuard] },
  { path: "**", loadComponent: () => import("./pages/not-found.component").then(m => m.NotFoundComponent) },
];
```

## Reactive Forms
```typescript
import { FormBuilder, Validators, ReactiveFormsModule } from "@angular/forms";

@Component({
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="name" />
      <input formControlName="email" type="email" />
      <button [disabled]="form.invalid">Submit</button>
    </form>
  `,
})
export class UserFormComponent {
  private fb = inject(FormBuilder);
  form = this.fb.nonNullable.group({
    name: ["", [Validators.required, Validators.minLength(2)]],
    email: ["", [Validators.required, Validators.email]],
  });

  onSubmit() {
    if (this.form.valid) {
      console.log(this.form.getRawValue());
    }
  }
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Standalone components** | Default since Angular 17 — no NgModules |
| **Signals** | Use `signal()` over Subject/BehaviorSubject for state |
| **`inject()`** | Preferred over constructor injection |
| **Lazy loading** | Use `loadComponent` for route-level code splitting |
| **Reactive forms** | Preferred over template-driven for complex forms |
| **OnPush** | Use `ChangeDetectionStrategy.OnPush` for performance |
| **Typed forms** | Use `nonNullable.group()` for type-safe forms |
| **Guards** | Use functional guards (`canActivate: [fn]`) |
| **Interceptors** | Use functional interceptors for HTTP middleware |
| **`@defer`** | Use deferrable views for lazy-loading components |
