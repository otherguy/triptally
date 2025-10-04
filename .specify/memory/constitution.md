<!--
SYNC IMPACT REPORT - Constitution v1.0.0
════════════════════════════════════════════════════════════════════════

Version Change: INITIAL → 1.0.0

Created Principles:
  1. Test-Driven Development (TDD) - Non-negotiable testing discipline
  2. Code Quality & Consistency - Rails/Flutter standards enforcement
  3. User Experience Consistency - Cross-platform UX alignment
  4. Performance & Scalability - Response time and efficiency requirements
  5. Security First - Authentication, validation, and data protection

Added Sections:
  - Technical Standards (Rails & Flutter conventions)
  - Development Workflow (PR/review process)
  - Governance (amendment process and compliance)

Template Consistency Status:
  ✅ .specify/templates/plan-template.md - Constitution Check section aligned
  ✅ .specify/templates/spec-template.md - Requirements validation aligned
  ✅ .specify/templates/tasks-template.md - TDD ordering enforced
  ✅ CLAUDE.md - Development guidelines consistent

Follow-up Actions: None

Ratification: Initial constitution establishing core development principles
            for TripTally monorepo (Rails backend + Flutter mobile)

════════════════════════════════════════════════════════════════════════
-->

# TripTally Constitution

## Core Principles

### I. Test-Driven Development (TDD) — NON-NEGOTIABLE

**All features MUST follow the Red-Green-Refactor cycle without exception.**

- Tests MUST be written before implementation code
- Tests MUST fail initially (Red phase verified)
- Implementation proceeds only after test approval
- Refactoring occurs only with passing tests (Green phase)
- No code merges without corresponding tests

**Backend (Rails)**:
- RSpec request specs for all API endpoints
- Model specs with Factory Bot for data validation
- Edge cases and error conditions tested
- SimpleCov coverage reports required

**Mobile (Flutter)**:
- Widget tests for all screens and components
- Repository unit tests with mocked dependencies
- Integration tests for critical user flows
- Riverpod provider overrides for state isolation

**Rationale**: TDD ensures correctness from the start, documents expected
behavior, enables safe refactoring, and prevents regressions. Non-negotiable
status reflects commitment to reliability and maintainability.

### II. Code Quality & Consistency

**Code MUST adhere to established language conventions and pass automated checks.**

- RuboCop (Rails Omakase style) MUST pass for all Ruby code
- Brakeman security scans MUST show no high/critical issues
- Dart analyzer MUST report zero errors/warnings
- Strong typing enforced (Ruby Sorbet optional, Dart strict mode)
- Magic numbers eliminated (use named constants)
- DRY principle applied (extract shared logic to services/utilities)

**Architecture Patterns**:
- Backend: RESTful controllers (thin), services (business logic), models (data)
- Mobile: Repository pattern with Riverpod state management
- Separation of concerns enforced at layer boundaries

**Rationale**: Consistent code style reduces cognitive load during reviews,
prevents common errors, and ensures the codebase remains approachable for
all team members.

### III. User Experience Consistency

**User-facing behavior MUST be predictable, intuitive, and aligned across
platforms.**

- Mobile UI follows Material Design guidelines
- API responses use consistent JSON structure (status/message/data/errors)
- Error messages are user-friendly (no stack traces in production)
- Loading states displayed for operations >200ms
- Offline behavior gracefully handled (Flutter connectivity checks)
- Authentication flows identical across iOS/Android

**Response Format Contract**:
```json
Success: { "status": "ok", "message": "...", "data": {...} }
Error:   { "status": "error", "errors": ["msg1", "msg2"] }
```

**Rationale**: Consistency reduces user confusion, builds trust, and simplifies
development by establishing clear contracts between frontend and backend.

### IV. Performance & Scalability

**System MUST meet defined performance targets under expected load.**

- API endpoints MUST respond within 200ms at p95 (excluding network latency)
- Database queries MUST use indexes for lookups (no N+1 queries)
- Mobile app MUST render UI at 60fps (Flutter performance overlay verification)
- API responses MUST use pagination for collections (default 20 items)
- Images MUST be optimized (Active Storage transformations on backend)
- Background jobs (Sidekiq) for async operations >500ms

**Performance Testing**:
- RSpec performance tests for critical endpoints
- Flutter DevTools timeline analysis for janky frames
- Load testing for endpoints expecting high traffic

**Rationale**: Performance directly impacts user satisfaction and retention.
Early establishment of performance budgets prevents costly refactoring later.

### V. Security First

**Security considerations MUST be integrated at every development stage.**

- JWT tokens with 24-hour expiry (HS256 algorithm)
- Passwords hashed with bcrypt cost factor 12
- All user input sanitized (Rails `sanitize` gem)
- CORS configured with explicit allowed origins
- HTTPS required in production (HTTP redirects enforced)
- Sensitive data stored in flutter_secure_storage (mobile)
- Parameter validation in controllers (strong parameters)
- OAuth providers verified (Apple, Google via Omniauth)

**Prohibited Practices**:
- Logging sensitive data (passwords, tokens, PII)
- Exposing internal error details to clients
- Storing tokens in localStorage (mobile: use secure storage)
- Skipping input validation on server side

**Rationale**: Security breaches destroy user trust and violate legal
obligations (GDPR, etc.). Baking security into development culture prevents
vulnerabilities from reaching production.

## Technical Standards

### Backend (Ruby on Rails 8.0)

- Ruby 3.4+, Rails 8.0+
- PostgreSQL (production), SQLite3 (development/test)
- Controllers namespaced under `Api::V1` for versioning
- Strong migrations enforced (`strong_migrations` gem)
- API documentation with RSwag (OpenAPI/Swagger)
- Async workers with Sidekiq for emails/background tasks

### Mobile (Flutter/Dart)

- Flutter SDK >=3.0.0 <4.0.0
- Dart strict mode enabled
- Riverpod for state management (no Provider/Bloc mix)
- Go Router for declarative routing
- JSON serialization via `json_serializable` + `build_runner`
- Dio HTTP client with JWT interceptors

### Monorepo Structure

- `/backend` - Rails API application
- `/mobile` - Flutter application
- Shared documentation in root (CLAUDE.md, TODO.md)
- Feature specs in `.specify/specs/[###-feature-name]/`

## Development Workflow

### Pull Request Requirements

- All tests passing (backend: RSpec, mobile: Flutter test)
- Code quality checks passing (RuboCop, Dart analyzer)
- Security scans passing (Brakeman)
- Test coverage maintained or improved (SimpleCov report)
- At least one approval from code owner
- No merge conflicts with main branch

### Review Checklist

- [ ] Tests written before implementation (TDD verified)
- [ ] Code follows language conventions (linter passing)
- [ ] Security considerations addressed (input validation, auth checks)
- [ ] Performance impact acceptable (no N+1 queries, no blocking operations)
- [ ] API contracts documented (RSwag annotations)
- [ ] Error handling complete (user-friendly messages)
- [ ] Mobile: code generation run if models changed (`build_runner`)

### Commit Standards

- Conventional Commits format: `type(scope): description`
- Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- Scopes: `backend`, `mobile`, `api`, `ui`, `auth`, etc.
- Breaking changes noted in commit body with `BREAKING CHANGE:` footer

## Governance

### Amendment Process

1. **Proposal**: Document proposed principle change with rationale
2. **Discussion**: Team review of impact on existing codebase
3. **Approval**: Consensus required for principle changes
4. **Migration**: Update affected code/docs to comply with new principle
5. **Version Bump**: Increment constitution version per semver rules

### Versioning Policy

- **MAJOR** (X.0.0): Removal/redefinition of existing principles
- **MINOR** (x.Y.0): Addition of new principles or sections
- **PATCH** (x.y.Z): Clarifications, typo fixes, non-semantic changes

### Compliance Review

- Constitution compliance checked during `/plan` command execution
- Violations documented in `Complexity Tracking` section of plan.md
- Deviations require explicit justification and simpler alternative analysis
- Repeated violations trigger architecture review

### Enforcement

- Automated checks in CI/CD (linters, security scans, test runs)
- Manual review checklist in PR template
- Constitution version referenced in all plan.md files
- Team retrospectives include constitution adherence discussion

---

**Version**: 1.0.0 | **Ratified**: 2025-10-04 | **Last Amended**: 2025-10-04
