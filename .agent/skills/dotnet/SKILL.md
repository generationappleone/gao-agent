---
name: .NET
description: Skill for building applications with .NET (C#), covering project setup, clean architecture, Entity Framework Core, dependency injection, async patterns, testing, and deployment.
---

# .NET (C#) Skill

## Overview
.NET is a cross-platform framework for building web APIs, microservices, desktop, and mobile applications. This skill covers .NET 8+ with C# 12, clean architecture, EF Core, and modern patterns.

## Project Setup

### Create New Project
```bash
# Web API
dotnet new webapi -n MyApp.Api -o src/MyApp.Api --use-controllers
# or minimal API
dotnet new webapi -n MyApp.Api -o src/MyApp.Api

# Class Library (Domain, Application, Infrastructure layers)
dotnet new classlib -n MyApp.Domain -o src/MyApp.Domain
dotnet new classlib -n MyApp.Application -o src/MyApp.Application
dotnet new classlib -n MyApp.Infrastructure -o src/MyApp.Infrastructure

# Test project
dotnet new xunit -n MyApp.Tests -o tests/MyApp.Tests

# Create solution
dotnet new sln -n MyApp
dotnet sln add src/MyApp.Api src/MyApp.Domain src/MyApp.Application src/MyApp.Infrastructure tests/MyApp.Tests
```

## Project Structure (Clean Architecture)
```
src/
├── MyApp.Domain/              # Enterprise rules — NO dependencies
│   ├── Entities/
│   │   ├── User.cs
│   │   └── BaseEntity.cs
│   ├── ValueObjects/
│   │   └── Email.cs
│   ├── Enums/
│   ├── Exceptions/
│   │   └── DomainException.cs
│   └── Interfaces/
│       └── IUserRepository.cs
│
├── MyApp.Application/         # Use cases — depends on Domain only
│   ├── DTOs/
│   │   ├── UserDto.cs
│   │   └── CreateUserRequest.cs
│   ├── Interfaces/
│   │   └── IUserService.cs
│   ├── Services/
│   │   └── UserService.cs
│   ├── Validators/
│   │   └── CreateUserValidator.cs   # FluentValidation
│   └── Mappings/
│       └── MappingProfile.cs        # AutoMapper
│
├── MyApp.Infrastructure/      # External concerns
│   ├── Data/
│   │   ├── AppDbContext.cs
│   │   ├── Configurations/
│   │   │   └── UserConfiguration.cs  # EF Core Fluent API
│   │   └── Repositories/
│   │       └── UserRepository.cs
│   ├── Services/
│   │   └── EmailService.cs
│   └── DependencyInjection.cs
│
└── MyApp.Api/                 # Presentation layer
    ├── Controllers/
    │   └── UsersController.cs
    ├── Middleware/
    │   └── ExceptionHandlingMiddleware.cs
    ├── Program.cs
    └── appsettings.json
```

## Domain Layer
```csharp
// Entities/BaseEntity.cs
public abstract class BaseEntity
{
    public Guid Id { get; protected set; } = Guid.NewGuid(); // UUID v4
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DeletedAt { get; set; } // Soft delete
    public bool IsDeleted => DeletedAt.HasValue;
}

// Entities/User.cs
public class User : BaseEntity
{
    public string Email { get; private set; } = string.Empty;
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string PasswordHash { get; private set; } = string.Empty;
    public bool IsActive { get; private set; } = true;

    // Factory method (DDD pattern)
    public static User Create(string email, string firstName, string lastName, string passwordHash)
    {
        return new User
        {
            Email = email ?? throw new ArgumentNullException(nameof(email)),
            FirstName = firstName,
            LastName = lastName,
            PasswordHash = passwordHash,
        };
    }

    public void Deactivate()
    {
        IsActive = false;
        DeletedAt = DateTime.UtcNow;
    }
}

// Interfaces/IUserRepository.cs
public interface IUserRepository
{
    Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default);
    Task<User?> GetByEmailAsync(string email, CancellationToken ct = default);
    Task<IReadOnlyList<User>> GetAllAsync(CancellationToken ct = default);
    Task AddAsync(User user, CancellationToken ct = default);
    Task UpdateAsync(User user, CancellationToken ct = default);
    Task DeleteAsync(User user, CancellationToken ct = default);
}
```

## EF Core Configuration
```csharp
// Data/AppDbContext.cs
public class AppDbContext : DbContext
{
    public DbSet<User> Users => Set<User>();

    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }

    // Auto-update timestamps
    public override Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }
        return base.SaveChangesAsync(ct);
    }
}

// Configurations/UserConfiguration.cs
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Email).HasMaxLength(255).IsRequired();
        builder.HasIndex(u => u.Email).IsUnique();
        builder.Property(u => u.FirstName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.LastName).HasMaxLength(100).IsRequired();
        builder.Property(u => u.PasswordHash).HasMaxLength(255).IsRequired();
        builder.HasQueryFilter(u => u.DeletedAt == null); // Global soft delete filter
    }
}
```

## API Controller
```csharp
[ApiController]
[Route("api/[controller]")]
[Produces("application/json")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;
    public UsersController(IUserService userService) => _userService = userService;

    [HttpGet]
    [ProducesResponseType(typeof(IEnumerable<UserDto>), StatusCodes.Status200OK)]
    public async Task<IActionResult> GetAll(CancellationToken ct)
    {
        var users = await _userService.GetAllAsync(ct);
        return Ok(users);
    }

    [HttpGet("{id:guid}")]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct)
    {
        var user = await _userService.GetByIdAsync(id, ct);
        return user is null ? NotFound() : Ok(user);
    }

    [HttpPost]
    [ProducesResponseType(typeof(UserDto), StatusCodes.Status201Created)]
    [ProducesResponseType(typeof(ValidationProblemDetails), StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Create([FromBody] CreateUserRequest request, CancellationToken ct)
    {
        var user = await _userService.CreateAsync(request, ct);
        return CreatedAtAction(nameof(GetById), new { id = user.Id }, user);
    }
}
```

## Dependency Injection (Program.cs)
```csharp
var builder = WebApplication.CreateBuilder(args);

// EF Core
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("Default")));

// Repositories & Services
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IUserService, UserService>();

// FluentValidation
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserValidator>();

// AutoMapper
builder.Services.AddAutoMapper(typeof(MappingProfile));

// API
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Security
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options => { /* JWT config */ });

var app = builder.Build();

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
```

## Global Exception Middleware
```csharp
public class ExceptionHandlingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try { await _next(context); }
        catch (DomainException ex)
        {
            _logger.LogWarning(ex, "Domain error");
            context.Response.StatusCode = 400;
            await context.Response.WriteAsJsonAsync(new { error = ex.Message });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unhandled exception");
            context.Response.StatusCode = 500;
            await context.Response.WriteAsJsonAsync(new { error = "Internal server error" });
        }
    }
}
```

## Commands
```bash
# Run
dotnet run --project src/MyApp.Api

# EF Migrations
dotnet ef migrations add InitialCreate --project src/MyApp.Infrastructure --startup-project src/MyApp.Api
dotnet ef database update --startup-project src/MyApp.Api

# Test
dotnet test --verbosity normal

# Publish
dotnet publish -c Release -o ./publish
```

## Rules Integration
- **SOLID**: Clean Architecture enforces DIP, repository pattern enforces ISP
- **Database**: UUID primary keys, soft delete, audit columns, EF Fluent API configuration
- **Security**: JWT authentication, global exception handling, input validation (FluentValidation)
- **Dependencies**: Lock versions in `.csproj`, use `dotnet list package --vulnerable`
