---
name: Kotlin / Android
description: Skill for native Android development with Kotlin — covering Jetpack Compose, MVVM, Coroutines, Room, Retrofit, Navigation, Hilt DI, and Material Design 3.
---

# Kotlin / Android Skill

## Overview
Kotlin is the official language for Android development. This skill covers Jetpack Compose as the modern UI toolkit.

**Reference**: [Android Developers](https://developer.android.com/kotlin)

## Jetpack Compose
```kotlin
@Composable
fun UserListScreen(viewModel: UserViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = { TopAppBar(title = { Text("Users") }) },
        floatingActionButton = {
            FloatingActionButton(onClick = { /* navigate */ }) {
                Icon(Icons.Default.Add, contentDescription = "Add")
            }
        }
    ) { padding ->
        when (val state = uiState) {
            is UiState.Loading -> CircularProgressIndicator(Modifier.padding(padding))
            is UiState.Success -> {
                LazyColumn(contentPadding = padding) {
                    items(state.users, key = { it.id }) { user ->
                        UserCard(user = user, onClick = { viewModel.selectUser(it) })
                    }
                }
            }
            is UiState.Error -> Text("Error: ${state.message}", Modifier.padding(padding))
        }
    }
}

@Composable
fun UserCard(user: User, onClick: (User) -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(8.dp).clickable { onClick(user) },
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Row(modifier = Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            AsyncImage(model = user.avatarUrl, contentDescription = null,
                modifier = Modifier.size(48.dp).clip(CircleShape))
            Spacer(Modifier.width(12.dp))
            Column {
                Text(user.name, style = MaterialTheme.typography.titleMedium)
                Text(user.email, style = MaterialTheme.typography.bodySmall)
            }
        }
    }
}
```

## ViewModel + Coroutines
```kotlin
@HiltViewModel
class UserViewModel @Inject constructor(
    private val repository: UserRepository
) : ViewModel() {
    private val _uiState = MutableStateFlow<UiState>(UiState.Loading)
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    init { fetchUsers() }

    fun fetchUsers() {
        viewModelScope.launch {
            _uiState.value = UiState.Loading
            repository.getUsers()
                .onSuccess { _uiState.value = UiState.Success(it) }
                .onFailure { _uiState.value = UiState.Error(it.message ?: "Unknown error") }
        }
    }
}

sealed interface UiState {
    data object Loading : UiState
    data class Success(val users: List<User>) : UiState
    data class Error(val message: String) : UiState
}
```

## Room Database
```kotlin
@Entity(tableName = "users")
data class UserEntity(
    @PrimaryKey val id: String,
    val name: String,
    val email: String,
    @ColumnInfo(name = "created_at") val createdAt: Long = System.currentTimeMillis()
)

@Dao
interface UserDao {
    @Query("SELECT * FROM users ORDER BY created_at DESC")
    fun getAll(): Flow<List<UserEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(users: List<UserEntity>)

    @Delete
    suspend fun delete(user: UserEntity)
}

@Database(entities = [UserEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun userDao(): UserDao
}
```

## Best Practices

| Practice | Description |
|----------|-------------|
| **Jetpack Compose** | Modern declarative UI (over XML) |
| **MVVM + UiState** | `sealed interface` for UI states |
| **Coroutines + Flow** | For async operations |
| **Hilt** | Dependency injection |
| **Room** | Type-safe local database |
| **Retrofit** | HTTP client with coroutine support |
| **Navigation Compose** | Type-safe navigation |
| **Material 3** | Follow Material Design 3 guidelines |
