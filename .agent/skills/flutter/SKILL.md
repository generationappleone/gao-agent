---
name: Flutter
description: Skill for building cross-platform mobile, web, and desktop applications with Flutter and Dart, covering project setup, state management, architecture, navigation, testing, and platform integration.
---

# Flutter Skill

## Overview
Flutter is Google's UI toolkit for building natively compiled apps for mobile (iOS/Android), web, and desktop from a single codebase. Use this skill for cross-platform application development.

## Project Setup
```bash
flutter create --org com.myapp --platforms android,ios,web my_app
cd my_app
```

## Directory Structure (Feature-First + Clean Architecture)
```
lib/
├── main.dart                      # Entry point
├── app.dart                       # App widget, routes, theme
├── core/
│   ├── constants/                 # App constants, API endpoints
│   ├── theme/                     # AppTheme, colors, typography
│   ├── utils/                     # Helpers, extensions
│   ├── network/                   # HTTP client, interceptors
│   └── di/                        # Dependency injection (get_it)
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/       # Remote/local data sources
│   │   │   ├── models/            # Data models (JSON serializable)
│   │   │   └── repositories/      # Repository implementations
│   │   ├── domain/
│   │   │   ├── entities/          # Business entities
│   │   │   ├── repositories/      # Repository contracts (abstract)
│   │   │   └── usecases/          # Business use cases
│   │   └── presentation/
│   │       ├── bloc/              # BLoC / Cubit state management
│   │       ├── pages/             # Screen widgets
│   │       └── widgets/           # Feature-specific widgets
│   └── home/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    └── widgets/                   # Reusable UI components
```

## State Management (BLoC + Cubit)
```dart
// ✅ REQUIRED: Cubit for simple state, BLoC for complex event-driven state

// --- State ---
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// --- Cubit ---
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthCubit(this._loginUseCase, this._logoutUseCase) : super(AuthInitial());

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    final result = await _loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    emit(AuthInitial());
  }
}
```

## Use Cases (Clean Architecture)
```dart
// Domain layer — no framework dependencies
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class LoginUseCase extends UseCase<User, LoginParams> {
  final AuthRepository _repository;
  LoginUseCase(this._repository);

  @override
  Future<Either<Failure, User>> call(LoginParams params) {
    return _repository.login(email: params.email, password: params.password);
  }
}

// Repository contract (DIP)
abstract class AuthRepository {
  Future<Either<Failure, User>> login({required String email, required String password});
  Future<void> logout();
}
```

## Data Models with JSON Serialization
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    @Default(true) bool isActive,
    required DateTime createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
```

## Dependency Injection (get_it)
```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Network
  sl.registerLazySingleton<Dio>(() => Dio(BaseOptions(baseUrl: AppConstants.apiBaseUrl)));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));

  // Repositories (bind abstract → concrete)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  // BLoC / Cubit
  sl.registerFactory(() => AuthCubit(sl(), sl()));
}
```

## Navigation (GoRouter)
```dart
final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final isLoggedIn = context.read<AuthCubit>().state is AuthAuthenticated;
    if (!isLoggedIn && !state.matchedLocation.startsWith('/auth')) return '/auth/login';
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomePage()),
    GoRoute(path: '/auth/login', builder: (_, __) => const LoginPage()),
  ],
);
```

## Testing
```dart
void main() {
  late AuthCubit authCubit;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    authCubit = AuthCubit(mockLoginUseCase, MockLogoutUseCase());
  });

  blocTest<AuthCubit, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] on successful login',
    build: () {
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(testUser));
      return authCubit;
    },
    act: (cubit) => cubit.login('test@example.com', 'password'),
    expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
  );
}
```

## Key Packages
| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `freezed` + `json_serializable` | Immutable models |
| `dartz` | Functional programming (Either) |
| `flutter_secure_storage` | Secure local storage |
| `cached_network_image` | Image caching |

## Rules Integration
- **SOLID**: Clean Architecture layers, DI with get_it, Use Case pattern (SRP), Repository contracts (DIP)
- **Security**: `flutter_secure_storage` for tokens, SSL pinning, input validation
- **Dependencies**: Check pub.dev scores, verify Dart SDK compatibility, run `dart pub audit`
