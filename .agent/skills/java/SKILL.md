---
name: Java
description: Skill for Java development, covering project setup with Spring Boot, clean architecture, JPA/Hibernate, REST APIs, testing, and enterprise patterns.
---

# Java Skill

## Overview
Java is the enterprise standard for backend development. Spring Boot provides auto-configuration, dependency injection, JPA/Hibernate ORM, Spring Security, and REST API development. Modern Java (17+) includes records, sealed classes, pattern matching, and text blocks.

**References**:
- [Spring Boot Documentation](https://docs.spring.io/spring-boot/docs/current/reference/)
- [Java Documentation](https://docs.oracle.com/en/java/)

---

## Project Structure (Spring Boot)

```
src/main/java/com/myapp/
├── MyAppApplication.java
├── config/
│   └── SecurityConfig.java
├── controller/
│   └── ProductController.java
├── service/
│   └── ProductService.java
├── repository/
│   └── ProductRepository.java
├── model/
│   ├── entity/Product.java
│   └── dto/ProductDTO.java
└── exception/
    └── GlobalExceptionHandler.java
```

---

## Entity

```java
@Entity
@Table(name = "products", indexes = {
    @Index(name = "idx_status", columnList = "status"),
    @Index(name = "idx_category", columnList = "category_id")
})
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 200)
    private String name;

    @Column(unique = true, nullable = false)
    private String slug;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private Integer price = 0;

    @Column(nullable = false)
    private Integer stock = 0;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private ProductStatus status = ProductStatus.DRAFT;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @Column(name = "created_at", updatable = false)
    @CreatedDate
    private LocalDateTime createdAt;

    // Getters, setters
}

public enum ProductStatus { DRAFT, ACTIVE, ARCHIVED }
```

---

## Repository

```java
public interface ProductRepository extends JpaRepository<Product, UUID>, JpaSpecificationExecutor<Product> {
    Optional<Product> findBySlug(String slug);
    Page<Product> findByStatus(ProductStatus status, Pageable pageable);

    @Query("SELECT p FROM Product p WHERE p.status = :status AND p.name LIKE %:search%")
    Page<Product> searchProducts(@Param("status") ProductStatus status, @Param("search") String search, Pageable pageable);
}
```

---

## Service

```java
@Service
@Transactional(readOnly = true)
public class ProductService {
    private final ProductRepository productRepo;

    public ProductService(ProductRepository productRepo) {
        this.productRepo = productRepo;
    }

    public Page<ProductDTO> listProducts(int page, int size, String search) {
        Pageable pageable = PageRequest.of(page - 1, size, Sort.by("createdAt").descending());
        Page<Product> products = (search != null && !search.isEmpty())
            ? productRepo.searchProducts(ProductStatus.ACTIVE, search, pageable)
            : productRepo.findByStatus(ProductStatus.ACTIVE, pageable);
        return products.map(ProductDTO::fromEntity);
    }

    @Transactional
    public ProductDTO createProduct(CreateProductRequest req) {
        Product product = new Product();
        product.setName(req.name());
        product.setSlug(req.name().toLowerCase().replaceAll("[^a-z0-9]+", "-"));
        product.setPrice(req.price());
        product.setStock(req.stock());
        return ProductDTO.fromEntity(productRepo.save(product));
    }
}
```

---

## Controller

```java
@RestController
@RequestMapping("/api/products")
public class ProductController {
    private final ProductService productService;

    public ProductController(ProductService productService) {
        this.productService = productService;
    }

    @GetMapping
    public Page<ProductDTO> listProducts(
        @RequestParam(defaultValue = "1") int page,
        @RequestParam(defaultValue = "20") int size,
        @RequestParam(required = false) String search
    ) {
        return productService.listProducts(page, size, search);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<ProductDTO> createProduct(@Valid @RequestBody CreateProductRequest req) {
        return ResponseEntity.status(201).body(productService.createProduct(req));
    }
}

// DTO with Java 17 record
public record CreateProductRequest(
    @NotBlank String name,
    @Min(0) Integer price,
    @Min(0) Integer stock,
    @NotNull UUID categoryId
) {}

public record ProductDTO(UUID id, String name, String slug, Integer price, String status, LocalDateTime createdAt) {
    public static ProductDTO fromEntity(Product p) {
        return new ProductDTO(p.getId(), p.getName(), p.getSlug(), p.getPrice(), p.getStatus().name(), p.getCreatedAt());
    }
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Records** | Use Java records for DTOs (immutable) |
| **UUID** | GenerationType.UUID for primary keys |
| **Pagination** | Spring Data Page with Pageable |
| **@Transactional** | readOnly=true for reads, writable for writes |
| **Constructor injection** | Prefer over @Autowired |
| **Validation** | @Valid with Jakarta Bean Validation |
| **Enum** | @Enumerated(STRING) for statuses |
| **FetchType.LAZY** | Avoid N+1 with lazy loading |
| **@PreAuthorize** | Method-level security |
| **Exception handler** | @ControllerAdvice for global error handling |

---

## Rules Integration
- **Entity**: JPA with UUID, indexes, enums
- **Repository**: JpaRepository with custom queries
- **Service**: Transactional business logic
- **Controller**: REST endpoints with validation
- **DTOs**: Java records for request/response
