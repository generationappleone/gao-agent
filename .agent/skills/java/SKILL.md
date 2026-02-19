---
name: Java
description: Skill for Java development, covering project setup with Spring Boot, clean architecture, JPA/Hibernate, REST APIs, testing, and enterprise patterns.
---

# Java Skill

## Overview
Java is a strongly-typed, object-oriented language for enterprise applications. Use this skill with Spring Boot for web services, microservices, and enterprise backends.

## Project Setup

### Spring Boot (Spring Initializr)
```bash
# Generate via CLI
curl https://start.spring.io/starter.tgz \
  -d type=gradle-project \
  -d language=java \
  -d bootVersion=3.2.2 \
  -d javaVersion=21 \
  -d dependencies=web,data-jpa,postgresql,validation,security,actuator \
  -d groupId=com.myapp \
  -d artifactId=my-service | tar -xzvf -
```

### Directory Structure (Clean Architecture)
```
src/main/java/com/myapp/
├── MyApplication.java              # Entry point
├── domain/                          # Business logic (no framework deps)
│   ├── model/                       # Entities, value objects
│   ├── service/                     # Domain services
│   ├── repository/                  # Repository interfaces (DIP)
│   └── exception/                   # Domain exceptions
├── application/                     # Use cases / orchestration
│   ├── dto/                         # Data Transfer Objects
│   ├── mapper/                      # Entity ↔ DTO mappers
│   └── usecase/                     # Application services
├── infrastructure/                  # Framework + external
│   ├── persistence/                 # JPA repositories
│   ├── config/                      # Spring config, security
│   └── external/                    # Third-party integrations
└── api/                             # HTTP layer
    ├── controller/                  # REST controllers
    ├── request/                     # Request DTOs
    ├── response/                    # Response DTOs
    └── advice/                      # Global exception handlers
```

## Entity with JPA & UUID
```java
@Entity
@Table(name = "users")
@SQLRestriction("deleted_at IS NULL")  // Soft delete filter
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(columnDefinition = "uuid")
    private UUID id;

    @Column(nullable = false, unique = true, length = 255)
    private String email;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;

    @Column(name = "is_active", nullable = false)
    private boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "deleted_at")
    private Instant deletedAt;

    // Constructors, getters/setters, builder pattern...
}
```

## Repository (Spring Data JPA)
```java
// Domain interface (DIP — high-level defines contract)
public interface UserRepository {
    Optional<User> findById(UUID id);
    Optional<User> findByEmail(String email);
    User save(User user);
    void deleteById(UUID id);
    Page<User> findAll(Pageable pageable);
}

// Infrastructure implementation
@Repository
public interface JpaUserRepository extends JpaRepository<User, UUID>, UserRepository {
    Optional<User> findByEmailAndDeletedAtIsNull(String email);

    @Query("SELECT u FROM User u WHERE u.isActive = true AND u.deletedAt IS NULL")
    Page<User> findAllActive(Pageable pageable);
}
```

## REST Controller
```java
@RestController
@RequestMapping("/api/v1/users")
@Validated
public class UserController {

    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse createUser(@Valid @RequestBody CreateUserRequest request) {
        return userService.createUser(request);
    }

    @GetMapping("/{id}")
    public UserResponse getUser(@PathVariable UUID id) {
        return userService.findById(id)
            .orElseThrow(() -> new ResourceNotFoundException("User", id));
    }
}
```

## Global Exception Handler
```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ErrorResponse handleNotFound(ResourceNotFoundException ex) {
        return new ErrorResponse("NOT_FOUND", ex.getMessage());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErrorResponse handleValidation(MethodArgumentNotValidException ex) {
        var errors = ex.getBindingResult().getFieldErrors().stream()
            .map(e -> e.getField() + ": " + e.getDefaultMessage())
            .toList();
        return new ErrorResponse("VALIDATION_ERROR", "Invalid request", errors);
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ErrorResponse handleGeneral(Exception ex) {
        log.error("Unhandled exception", ex);
        return new ErrorResponse("INTERNAL_ERROR", "An unexpected error occurred");
    }
}
```

## Testing
```java
@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {

    @Autowired private MockMvc mockMvc;
    @MockBean private UserService userService;

    @Test
    void createUser_shouldReturn201() throws Exception {
        var request = new CreateUserRequest("test@example.com", "John", "Doe", "password123");
        when(userService.createUser(any())).thenReturn(new UserResponse(UUID.randomUUID(), "test@example.com"));

        mockMvc.perform(post("/api/v1/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(request)))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.email").value("test@example.com"));
    }
}
```

## Rules Integration
- **SOLID**: Clean Architecture layers, DI via Spring constructor injection, Repository pattern
- **Security**: Spring Security, `@Valid` annotations, BCryptPasswordEncoder, JWT
- **Database**: UUID PKs, JPA audit annotations, soft delete, Flyway/Liquibase migrations
- **Dependencies**: Check with `gradle dependencyCheckAnalyze` or `mvn dependency-check:check`
