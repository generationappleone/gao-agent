---
name: ASP.NET
description: Skill for building web applications with ASP.NET Core, covering MVC, Razor Pages, Blazor, middleware, authentication, SignalR, and deployment patterns.
---

# ASP.NET Core Skill

## Overview
ASP.NET Core is a cross-platform web framework for building MVC apps, Razor Pages, Blazor SPAs, and real-time SignalR applications. This skill focuses on ASP.NET Core 8+ web-specific patterns (see .NET skill for foundational API/architecture patterns).

## Project Types

```bash
# MVC (Model-View-Controller)
dotnet new mvc -n MyApp.Web -o src/MyApp.Web

# Razor Pages (page-based model)
dotnet new webapp -n MyApp.Web -o src/MyApp.Web

# Blazor Server
dotnet new blazorserver -n MyApp.Blazor -o src/MyApp.Blazor

# Blazor WebAssembly (WASM)
dotnet new blazorwasm -n MyApp.Blazor -o src/MyApp.Blazor
```

## MVC Pattern

### Controller
```csharp
[Authorize]
public class UsersController : Controller
{
    private readonly IUserService _userService;
    public UsersController(IUserService userService) => _userService = userService;

    // GET /users
    [HttpGet]
    public async Task<IActionResult> Index(int page = 1, int pageSize = 20)
    {
        var users = await _userService.GetPaginatedAsync(page, pageSize);
        return View(users);
    }

    // GET /users/create
    [HttpGet]
    public IActionResult Create() => View();

    // POST /users/create
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(CreateUserViewModel model)
    {
        if (!ModelState.IsValid) return View(model);
        await _userService.CreateAsync(model);
        TempData["Success"] = "User created successfully.";
        return RedirectToAction(nameof(Index));
    }

    // GET /users/edit/{id}
    [HttpGet]
    public async Task<IActionResult> Edit(Guid id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user is null) return NotFound();
        return View(user);
    }

    // POST /users/delete/{id}
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Delete(Guid id)
    {
        await _userService.DeleteAsync(id);
        TempData["Success"] = "User deleted.";
        return RedirectToAction(nameof(Index));
    }
}
```

### View (Razor)
```html
@model PaginatedList<UserDto>

@section Title { <title>Users — Admin</title> }

<div class="container py-4">
  <div class="d-flex justify-content-between align-items-center mb-4">
    <h1 class="h3">Users</h1>
    <a asp-action="Create" class="btn btn-primary">
      <i class="bi bi-plus-lg me-1"></i> Add User
    </a>
  </div>

  @if (TempData["Success"] != null)
  {
    <div class="alert alert-success alert-dismissible fade show">
      @TempData["Success"]
      <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
  }

  <div class="card shadow-sm">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="table-light">
          <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Status</th>
            <th class="text-end">Actions</th>
          </tr>
        </thead>
        <tbody>
          @foreach (var user in Model.Items)
          {
            <tr>
              <td>@user.FirstName @user.LastName</td>
              <td>@user.Email</td>
              <td>
                <span class="badge bg-@(user.IsActive ? "success" : "secondary")">
                  @(user.IsActive ? "Active" : "Inactive")
                </span>
              </td>
              <td class="text-end">
                <a asp-action="Edit" asp-route-id="@user.Id" class="btn btn-sm btn-outline-primary">Edit</a>
                <form asp-action="Delete" asp-route-id="@user.Id" method="post" class="d-inline"
                      onsubmit="return confirm('Are you sure?')">
                  @Html.AntiForgeryToken()
                  <button class="btn btn-sm btn-outline-danger">Delete</button>
                </form>
              </td>
            </tr>
          }
        </tbody>
      </table>
    </div>
  </div>
</div>
```

## Middleware Pipeline
```csharp
// Program.cs — Middleware order matters!
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.UseExceptionHandler("/Error");
    app.UseHsts();                    // Security: HSTS
}

app.UseHttpsRedirection();           // Security: Force HTTPS
app.UseStaticFiles();                 // Serve wwwroot/
app.UseRouting();

// Security headers
app.Use(async (context, next) =>
{
    context.Response.Headers.Append("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Append("X-Frame-Options", "DENY");
    context.Response.Headers.Append("X-XSS-Protection", "0");
    context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");
    context.Response.Headers.Append("Permissions-Policy", "camera=(), microphone=(), geolocation=()");
    await next();
});

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute("default", "{controller=Home}/{action=Index}/{id?}");
app.MapRazorPages();                  // If using Razor Pages
app.MapBlazorHub();                   // If using Blazor Server

app.Run();
```

## Identity & Authentication
```csharp
// Add ASP.NET Identity
builder.Services.AddIdentity<ApplicationUser, IdentityRole<Guid>>(options =>
{
    options.Password.RequiredLength = 12;
    options.Password.RequireUppercase = true;
    options.Password.RequireLowercase = true;
    options.Password.RequireDigit = true;
    options.Password.RequireNonAlphanumeric = true;
    options.Lockout.MaxFailedAccessAttempts = 5;
    options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<AppDbContext>()
.AddDefaultTokenProviders();

// Cookie config
builder.Services.ConfigureApplicationCookie(options =>
{
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    options.Cookie.SameSite = SameSiteMode.Strict;
    options.ExpireTimeSpan = TimeSpan.FromHours(2);
    options.SlidingExpiration = true;
    options.LoginPath = "/Account/Login";
    options.AccessDeniedPath = "/Account/AccessDenied";
});
```

## SignalR (Real-time)
```csharp
// Hub
public class NotificationHub : Hub
{
    public async Task SendMessage(string user, string message)
    {
        await Clients.All.SendAsync("ReceiveMessage", user, message);
    }
}

// Program.cs
builder.Services.AddSignalR();
app.MapHub<NotificationHub>("/hubs/notifications");
```

```javascript
// Client-side
const connection = new signalR.HubConnectionBuilder()
    .withUrl("/hubs/notifications")
    .withAutomaticReconnect()
    .build();

connection.on("ReceiveMessage", (user, message) => {
    console.log(`${user}: ${message}`);
});

await connection.start();
```

## Tag Helpers (Form)
```html
<form asp-controller="Users" asp-action="Create" method="post">
  <div class="mb-3">
    <label asp-for="Email" class="form-label"></label>
    <input asp-for="Email" class="form-control" />
    <span asp-validation-for="Email" class="text-danger"></span>
  </div>
  <button type="submit" class="btn btn-primary">Create</button>
</form>
@section Scripts { <partial name="_ValidationScriptsPartial" /> }
```

## Rules Integration
- **SOLID**: MVC pattern separates Controller (SRP), Service (business logic), Repository (data)
- **Security**: CSRF tokens (`ValidateAntiForgeryToken`), Identity password policy, secure cookies, security headers
- **UI/UX**: Pair with Bootstrap or Tailwind CSS for premium admin interfaces
- **SEO**: Use `<title>`, meta tags in `_Layout.cshtml`, semantic HTML in views
