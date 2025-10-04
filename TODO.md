# TODO List

## Mobile App

- [ ] Handle token refresh so the user does not get logged out
- [ ] Implement automatic logout on token expiry
- [ ] Implement error handling for login (e.g. wrong username/password)
- [ ] Implement error handling for registration (username already exists, other validation errors)
- [ ] Add user profile management (view and edit profile)
- [ ] Implement token storage and automatic logout on token expiry

## Backend

- [x] Change user IDs to UUIDs (v7) for better scalability
- [ ] Refactor to use `jb` and views
- [ ] Configure Rails email sending using my existing mail provider (is there a gem? if not, smtp) and sidekiq workers
- [ ] Add profile picture support with a default profile picture of user initials and background color based on the uuid
- [ ] Configure Redis Rails cache in testing / production mode
- [ ] Implement JWT token blacklisting using Rails cache for proper logout functionality
- [ ] Add API rate limiting
- [ ] Add email verification for user registration and update
- [ ] Implement password reset functionality
- [ ] Add admin panel and user management features

### Cross-cutting

- [ ] Ensure consistent error response formats
- [ ] Add integration tests between backend and mobile
