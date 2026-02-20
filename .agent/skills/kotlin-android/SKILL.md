---
name: Kotlin / Android
description: Skill for native Android development with Kotlin — covering Jetpack Compose, MVVM, Coroutines, Room, Retrofit, Navigation, Hilt DI, and Material Design 3.
---

# Kotlin / Android Skill

## Overview
Kotlin is the preferred language for Android development. Modern Android uses Jetpack Compose for declarative UI, MVVM architecture, Coroutines for async, Room for local DB, Retrofit for REST APIs, Hilt for DI, and Material Design 3.

**References**:
- [Android Developers](https://developer.android.com/)
- [Jetpack Compose](https://developer.android.com/compose)
- [Kotlin Documentation](https://kotlinlang.org/docs/)

---

## Jetpack Compose UI

```kotlin
@Composable
fun ProductListScreen(viewModel: ProductViewModel = hiltViewModel()) {
    val products by viewModel.products.collectAsStateWithLifecycle()
    val isLoading by viewModel.isLoading.collectAsStateWithLifecycle()

    Scaffold(
        topBar = { TopAppBar(title = { Text("Products") }) },
        floatingActionButton = { FloatingActionButton(onClick = { /* navigate to create */ }) { Icon(Icons.Default.Add, "Add") } }
    ) { padding ->
        if (isLoading) {
            Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) { CircularProgressIndicator() }
        } else {
            LazyColumn(Modifier.padding(padding)) {
                items(products, key = { it.id }) { product ->
                    ProductCard(product = product, onClick = { /* navigate */ })
                }
            }
        }
    }
}

@Composable
fun ProductCard(product: Product, onClick: () -> Unit) {
    Card(Modifier.fillMaxWidth().padding(8.dp).clickable(onClick = onClick), shape = RoundedCornerShape(16.dp)) {
        Row(Modifier.padding(16.dp)) {
            AsyncImage(model = product.imageUrl, contentDescription = product.name, modifier = Modifier.size(80.dp).clip(RoundedCornerShape(12.dp)))
            Column(Modifier.padding(start = 12.dp)) {
                Text(product.name, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                Text("$${product.price / 100.0}", color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.Bold)
                Text("★ ${product.rating}", style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
```

---

## ViewModel

```kotlin
@HiltViewModel
class ProductViewModel @Inject constructor(private val repository: ProductRepository) : ViewModel() {
    private val _products = MutableStateFlow<List<Product>>(emptyList())
    val products: StateFlow<List<Product>> = _products.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init { loadProducts() }

    private fun loadProducts() {
        viewModelScope.launch {
            _isLoading.value = true
            _products.value = repository.getProducts()
            _isLoading.value = false
        }
    }
}
```

---

## Retrofit API

```kotlin
interface ApiService {
    @GET("api/products")
    suspend fun getProducts(@Query("page") page: Int = 1): PaginatedResponse<Product>

    @POST("api/products")
    suspend fun createProduct(@Body data: CreateProductRequest): Product
}

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {
    @Provides @Singleton
    fun provideApiService(): ApiService = Retrofit.Builder()
        .baseUrl(BuildConfig.API_URL)
        .addConverterFactory(GsonConverterFactory.create())
        .build()
        .create(ApiService::class.java)
}
```

---

## Best Practices

| Practice | Details |
|----------|---------|
| **Compose** | Declarative UI with @Composable functions |
| **MVVM** | ViewModel + StateFlow for state |
| **Coroutines** | viewModelScope for async operations |
| **Hilt** | Dependency injection with @HiltViewModel |
| **Room** | Local database with type-safe queries |
| **Retrofit** | Type-safe HTTP client with suspend |
| **Navigation** | Jetpack Navigation Compose |
| **Material 3** | MaterialTheme for consistent design |
| **StateFlow** | Reactive state with lifecycle awareness |
| **Coil** | AsyncImage for image loading |

---

## Rules Integration
- **UI**: Jetpack Compose with Material Design 3
- **Architecture**: MVVM with ViewModel + StateFlow
- **Network**: Retrofit with coroutines
- **DI**: Hilt for dependency injection
