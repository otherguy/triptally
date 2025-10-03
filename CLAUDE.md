# TripTally - Project Context for Claude

## Overview

TripTally is a trip planning and management application with a **monorepo structure** containing:

- **Backend**: Ruby on Rails 8.0 REST API (`/backend`)
- **Mobile**: Flutter/Dart mobile application (`/mobile`)

## Your Role

You are acting as:

1. **Senior Ruby Backend Developer** - Expert in building secure, stable, and performant REST APIs with Ruby on Rails
2. **Senior Flutter/Dart Developer** - Expert in cross-platform mobile app development for iOS and Android

Your expertise includes:

- RESTful API design and implementation
- JWT-based authentication and authorization
- Database design and Active Record patterns
- Ruby best practices and Rails conventions
- Flutter state management (Riverpod)
- Dart language features and best practices
- Mobile architecture patterns (Repository, Provider)
- Cross-platform iOS/Android development
- HTTP client integration and error handling
- Secure storage and authentication flows

---

## Backend (Rails API)

### Technology Stack

- **Ruby**: 3.4+
- **Rails**: 8.0+
- **Database**: PostgreSQL (production), SQLite3 (development/test)
- **Authentication**: JWT with HS256, bcrypt for password hashing
- **Testing**: RSpec with Factory Bot, Faker, Shoulda Matchers
- **Code Quality**: RuboCop (Rails Omakase style), Brakeman (security scanning)
- **Documentation**: RSwag (OpenAPI/Swagger)
- **Coverage**: SimpleCov

### Key Gems

- `jwt` - JSON Web Token authentication
- `bcrypt` - Secure password hashing
- `uuid7` - UUID v7 generation for user IDs
- `rack-cors` - CORS handling
- `sanitize` - HTML input sanitization
- `strong_migrations` - Safe database migrations
- `image_processing` - Active Storage image transformations

### Authentication Flow

1. **Registration/Login**: Returns JWT token with 24-hour expiry
2. **Token Format**: `Bearer <token>` in `Authorization` header
3. **Token Payload**: `{ user_id: string, exp: integer }`
4. **Secret**: `Rails.application.secret_key_base`
5. **Algorithm**: HS256

**Note**: Token blacklisting is not yet implemented (see TODO).

### API Response Patterns

**Success Response**:

```json
{
  "message": "Success message",
  "user": { "id": "uuid", "name": "...", "email": "..." },
  "token": "jwt_token"
}
```

**Error Response**:

```json
{
  "error": "Error message"
}
// or
{
  "errors": ["Error 1", "Error 2"]
}
```

### Security Considerations

- JWT tokens expire after 24 hours
- Passwords hashed with bcrypt
- Email validation with RFC-compliant regex
- Input sanitization with `sanitize` gem
- CORS configured for cross-origin requests
- Parameter validation in controllers
- Strong migrations for safe schema changes
- Brakeman security scanning

### Testing

- **Framework**: RSpec
- **Factories**: Factory Bot with Faker
- **Matchers**: Shoulda Matchers
- **Coverage**: SimpleCov with console and JSON formatters
- **Location**: `spec/` directory

---

## Mobile (Flutter/Dart)

### Technology Stack

- **Flutter SDK**: >=3.0.0 <4.0.0
- **State Management**: Riverpod (flutter_riverpod, riverpod_annotation)
- **Navigation**: Go Router
- **HTTP Client**: Dio
- **Secure Storage**: flutter_secure_storage
- **Code Generation**: json_serializable, build_runner

### Architecture Pattern

**Repository Pattern with Riverpod State Management**:

1. **Services Layer** (`services/`):
   - `api_client.dart` - Configured Dio instance with JWT interceptors
   - `storage_service.dart` - Secure token storage (FlutterSecureStorage)

2. **Repository Layer** (`repositories/`):
   - Business logic and API calls
   - Example: `auth_repository.dart` handles login/register

3. **Provider Layer** (`providers/`):
   - Riverpod providers for state management
   - Exposes repositories and state to UI

4. **Models Layer** (`models/`):
   - JSON serializable data classes
   - Generated with `json_serializable`
   - Example: `user.dart`, `auth_response.dart`

5. **UI Layer** (`screens/`):
   - Widget-based screens
   - Consumes providers with `ConsumerWidget` or `ConsumerStatefulWidget`

### Key Dependencies

- `dio: ^5.9.0` - HTTP client
- `flutter_secure_storage: ^9.2.4` - Encrypted storage for tokens
- `flutter_riverpod: ^3.0.1` - State management
- `go_router: ^16.2.4` - Declarative routing
- `json_annotation: ^4.9.0` - JSON serialization annotations

### API Client Configuration

- **Base URL**: `http://localhost:3000`
- **Headers**: `Content-Type: application/json`, `Accept: application/json`
- **Timeouts**: 10 seconds (connect and receive)
- **Interceptors**:
  - Automatically adds `Authorization: Bearer <token>` header
  - Handles 401 errors by clearing stored token

### Authentication Flow

1. User logs in/registers via screens
2. Repository calls API endpoint
3. On success, token stored in `flutter_secure_storage`
4. `AuthNotifier` updates authentication state
5. Router redirects based on auth state
6. All subsequent API calls include JWT in headers

### State Management Pattern

Uses Riverpod providers:

- `authNotifierProvider` - Authentication state
- `routerProvider` - Router with auth-based redirects
- Repository providers - API data access

### Models

All models use `json_serializable` with code generation:

```dart
@JsonSerializable()
class User {
  final int id;  // Note: Backend uses UUID, but mobile currently expects int
  final String email;
  final String name;
  // ...
}
```

**Important**: There's a type mismatch - backend uses UUID (string) for user ID, but mobile expects int. This needs to be fixed.

### Screens

- `login_screen.dart` - User login form
- `register_screen.dart` - User registration form
- `home_screen.dart` - Authenticated home screen

### Development Commands

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run tests
flutter test
```

---

## Development Guidelines

### Backend (Rails)

1. **Follow Rails Conventions**:
   - Models in `app/models/`
   - Controllers namespaced under `Api::V1`
   - RESTful routing patterns
   - Use strong parameters

2. **Security First**:
   - Always validate and sanitize user input
   - Use `has_secure_password` for authentication
   - Implement proper authorization checks
   - Follow OWASP guidelines

3. **Testing**:
   - Write RSpec tests for all models and controllers
   - Use Factory Bot for test data
   - Aim for high test coverage
   - Test edge cases and error conditions

4. **Code Quality**:
   - Follow RuboCop rules (Rails Omakase style)
   - Run Brakeman for security checks
   - Use strong_migrations for safe schema changes
   - Keep controllers thin, models fat

5. **API Design**:
   - Use proper HTTP status codes
   - Return consistent JSON responses
   - Version APIs (`/api/v1/`)
   - Document with RSwag

### Mobile (Flutter/Dart)

1. **Architecture**:
   - Follow Repository pattern
   - Use Riverpod for state management
   - Keep business logic in repositories
   - Keep UI logic in screens/widgets

2. **Code Generation**:
   - Use `json_serializable` for models
   - Run `build_runner` after model changes
   - Use `riverpod_generator` for providers

3. **State Management**:
   - Use `ConsumerWidget` or `ConsumerStatefulWidget`
   - Read providers with `ref.read()` for actions
   - Watch providers with `ref.watch()` for reactive UI
   - Use `StateNotifier` for complex state

4. **Error Handling**:
   - Catch `DioException` for HTTP errors
   - Show user-friendly error messages
   - Handle network failures gracefully
   - Log errors for debugging

5. **Security**:
   - Store tokens in `flutter_secure_storage`
   - Never log sensitive data
   - Validate input on client and server
   - Use HTTPS in production

6. **Testing**:
   - Write widget tests for screens
   - Write unit tests for repositories
   - Mock dependencies with Riverpod overrides
   - Test error scenarios

---

## Important Notes

1. **Monorepo Structure**: Backend and mobile are separate applications in the same repository
2. **ID Type Mismatch**: Backend uses UUID v7 (string), mobile models expect int - needs fixing
3. **Authentication**: JWT tokens with 24-hour expiry, no refresh mechanism yet
4. **Database**: PostgreSQL for production, SQLite3 for development/test
5. **API Versioning**: All endpoints under `/api/v1/` namespace
6. **State Management**: Riverpod is the chosen solution for Flutter
7. **Code Generation**: Run `build_runner` after model changes in mobile app

---

## Contact & Resources

- **Rails Guides**: https://guides.rubyonrails.org/
- **Flutter Docs**: https://docs.flutter.dev/
- **Riverpod Docs**: https://riverpod.dev/
- **Dio Docs**: https://pub.dev/packages/dio

---

## When Working on This Project

### Backend Tasks

- Consider security implications of all changes
- Write tests before implementing features (TDD)
- Update API documentation when adding or modifying endpoints
- Use proper HTTP status codes
- Validate and sanitize all inputs
- Follow RESTful conventions

### Mobile Tasks

- Run code generation after model changes
- Test on both iOS and Android when possible
- Handle loading and error states in UI
- Use proper navigation with Go Router
- Store sensitive data securely
- Follow Material Design guidelines

### Cross-platform Considerations

- Ensure API contracts match between backend and mobile
- Keep response formats consistent
- Handle errors gracefully on both sides
- Maintain backwards compatibility when updating APIs
- Document breaking changes clearly
