# GetXify Example App

A comprehensive Flutter application demonstrating the key features of the GetXify package.

## Features Demonstrated

This example showcases the following GetXify capabilities:

### Routing & Navigation

- **Nested Routing**: Complex route structure with parent-child relationships
- **Route Guards**: Authentication middleware (EnsureAuthMiddleware, EnsureNotAuthedMiddleware)
- **Named Routes**: Type-safe route navigation using `Routes` class
- **Route Parameters**: Dynamic route parameters (e.g., product details)
- **Transitions**: Various page transitions (cupertino, size, etc.)
- **Router Outlet**: Nested navigation with `GetRouterOutlet`

### State Management

- **Reactive State**: Using `.obs` for reactive variables
- **Services**: Global state management with `GetxService`
- **Controllers**: View controllers with `GetxController`

### Dependency Injection

- **Bindings**: Dependency injection using `Binding` class
- **Lazy Loading**: LazyPut for efficient memory usage
- **Global Services**: Singleton services accessible via `Get.find()`

### Architecture

- **Clean Architecture**: Separation of concerns with modules
- **MVVM Pattern**: Model-View-ViewModel structure
- **Module Organization**: Each feature in its own module (bindings, controllers, views)

## Project Structure

```
lib/
├── app/
│   ├── middleware/          # Route guards and middleware
│   ├── modules/            # Feature modules
│   │   ├── dashboard/      # Dashboard feature
│   │   ├── home/           # Home with bottom navigation
│   │   ├── login/          # Authentication
│   │   ├── products/       # Product listing
│   │   ├── product_details/# Product details
│   │   ├── profile/        # User profile
│   │   ├── root/           # Root navigator
│   │   └── settings/       # App settings
│   └── routes/             # Route configuration
├── models/                 # Data models
├── services/               # Global services
└── main.dart              # App entry point
```

## Running the Example

1. Ensure you have Flutter installed
2. Navigate to the example directory:
   ```bash
   cd example
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Key Modules

### Authentication

- Demonstrates login/logout flow
- Route guards to protect authenticated routes
- Redirect after successful login

### Navigation

- Bottom navigation with 3 tabs
- Nested routing within tabs
- Smooth transitions between routes

### Products

- Product listing page
- Product details with dynamic routing
- Authentication required for product details

## Learning Resources

This example is designed to help you understand:

- How to structure a GetXify application
- Implementing authentication with route guards
- Managing complex navigation scenarios
- Using dependency injection effectively
- Organizing code in a scalable way

## Notes

- This example uses the local getxify package (path: ../)
- The app demonstrates both authenticated and public routes
- Middleware logs route transitions for debugging purposes
