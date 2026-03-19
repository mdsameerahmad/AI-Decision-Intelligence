# AI Decision Intelligence Frontend 🚀

A modern, AI-powered data analysis and decision intelligence platform built with **Flutter**. This application provides users with deep insights into their datasets, featuring automated summaries, correlation analysis, predictive forecasting, and an interactive AI chatbot for strategic decision-making.

---

## **Project Overview**

The **AI Decision Intelligence** frontend is designed to be a professional, high-performance dashboard that transforms raw data (CSV) into actionable business intelligence. It integrates with a FastAPI backend to process data and leverage LLMs for generating strategic advice.

### **Core Features**
- **Smart Data Upload**: Drag-and-drop or browse CSV datasets for analysis.
- **Automated Summarization**: Instant overview of dataset statistics, including row/column counts and key markers (mean, min, max).
- **Correlation Insights**: Interactive heatmaps and bar charts showing how variables move together.
- **Predictive Forecasting**: Forecast future trends based on historical data patterns.
- **AI Strategy Chatbot**: A session-based AI assistant that answers questions about your data and generates detailed strategic action plans.
- **Modern UI/UX**: Glassmorphism effects, staggered animations, and a sleek blue-white gradient theme.

---

## **Tech Stack**

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform support for Web, Android, iOS, Windows)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (BLOC pattern for clean, reactive architecture)
- **Local State & Hooks**: [flutter_hooks](https://pub.dev/packages/flutter_hooks)
- **Data Visualization**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Networking**: [http](https://pub.dev/packages/http)
- **Storage**: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) (JWT handling)
- **UI Components**: [Google Fonts](https://pub.dev/packages/google_fonts), [Lucide Icons](https://pub.dev/packages/lucide_icons)

---

## **Detailed Frontend Architecture**

The project follows a feature-driven architecture within the `lib/` directory, ensuring modularity and maintainability.

### **1. Core (`lib/core/`)**
Contains global configurations, constants, themes, and utility functions used across the entire app.
- `constants/`:
    - [api_constants.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/core/constants/api_constants.dart): API endpoints, base URL configuration, and a toggle (`useRailwayBackendInDebug`) to switch between local and Railway backend URLs in debug mode.
- `theme/`:
    - [app_theme.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/core/theme/app_theme.dart): Global styling, colors, and font configurations.
- `utils/`:
    - `responsive_helper.dart`, `validator.dart`: General utility functions.

### **2. Data (`lib/data/`)**
The data layer responsible for API communication, data modeling, and business logic.
- `services/`:
    - [api_service.dart](file:///d:\Project WOrk\ai_analyser\ai_decision_intelligence_frontend\lib\data\services\api_service.dart): Low-level wrapper for HTTP requests and JWT token management.
- `repositories/`:
    - [auth_repository.dart](file:///d:\Project WOrk\ai_analyser\ai_decision_intelligence_frontend\lib\data\repositories\auth_repository.dart), [dataset_repository.dart](file:///d:\Project WOrk\ai_analyser\ai_decision_intelligence_frontend\lib\data\repositories\dataset_repository.dart): High-level abstractions for fetching and sending data, encapsulating business logic.
- `models/`:
    - [app_models.dart](file:///d:\Project WOrk\ai_analyser\ai_decision_intelligence_frontend\lib\data\models\app_models.dart), [user_model.dart](file:///d:\Project WOrk\ai_analyser\ai_decision_intelligence_frontend\lib\data\models\user_model.dart): Type-safe definitions for API request/response data.

### **3. Features (`lib/features/`)**
Each directory represents a specific, modular functional area of the app, typically containing its own BLoC for state management and `pages/` for UI components.
- `auth/`: Authentication and user management flows (welcome, login, signup, profile, reset password).
- `chat/`: AI Chatbot interface and strategy mode.
- `common/`: Shared widgets and layouts used across multiple features (e.g., `main_scaffold.dart`, `app_bottom_nav_bar.dart`).
- `correlation/`: Data correlation visualization and analysis.
- `dashboard/`: Main landing page for dataset management, upload, and overview.
- `summary/`: Statistical summaries and visualizations of datasets.

### **4. Other Key Files/Folders**
- `main.dart`: The application's entry point, responsible for initializing the app, setting up Bloc providers, and defining the root widget tree.
- `assets/`: Stores static assets like images (`illustration.jpg`, `logo.png`).
- `web/`: Contains files specific to Flutter web builds, including `index.html`, `manifest.json`, and icons. This directory is crucial for web deployment.
- `android/`, `ios/`, `linux/`, `macos/`, `windows/`: Platform-specific project files for native builds.
- `pubspec.yaml`: Dependency management file.
- `firebase.json`, `.firebaserc`: Firebase configuration files for hosting.

---

## **Deployment Strategies**

The frontend application supports deployment to multiple platforms, leveraging Flutter's cross-platform capabilities.

### **1. Web Deployment (Firebase Hosting)**
*   **Process**:
    1.  **Build Web Assets**: Run `flutter build web` to compile your Flutter app into static web files (HTML, CSS, JavaScript) located in the `build/web` directory.
    2.  **Deploy to Firebase**: Use the Firebase CLI command `firebase deploy --only hosting` to upload the contents of `build/web` to Firebase Hosting.
*   **Configuration**:
    *   `firebase.json`: Defines hosting rules, including the `public` directory (`build/web`) and `rewrites` for single-page application routing (e.g., redirecting all paths to `index.html`).
    *   `.firebaserc`: Stores Firebase project aliases.
*   **Benefits**: Fast content delivery via CDN, automatic SSL, custom domain support, and seamless integration with other Firebase services.

### **2. Mobile App Deployment (Android)**
*   **Build Commands**:
    *   `flutter build apk --release`: Generates a release-optimized Android Package Kit (`.apk`) file, suitable for direct installation on devices or distribution outside of Google Play. Output is typically in `build/app/outputs/apk/release/`.
    *   `flutter build appbundle --release`: Generates an Android App Bundle (`.aab`) file, the recommended format for publishing to the Google Play Store. Output is typically in `build/app/outputs/bundle/release/`.
*   **Installation/Distribution**:
    *   For testing on a connected device: `flutter run --release` (builds and installs a release-optimized version).
    *   For wider distribution: Upload the `.aab` file to the Google Play Console.

### **3. Mobile App Deployment (iOS)**
*   **Build Command**: `flutter build ios --release`
*   **Output**: Generates an iOS application archive (`.ipa` file) suitable for distribution. This command requires a macOS machine with Xcode.
*   **Installation/Distribution**: The `.ipa` file can be distributed via TestFlight for beta testing or uploaded to the Apple App Store Connect for official release.

---

## **Getting Started**

### **Prerequisites**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Dart SDK](https://dart.dev/get-dart)
- An active backend instance (FastAPI)
- [Firebase CLI](https://firebase.google.com/docs/cli) (for web deployment)

### **Installation**
1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure the API**:
   Update `lib/core/constants/api_constants.dart` with your backend's base URL. Use the `useRailwayBackendInDebug` toggle to switch between local and Railway backend URLs in debug mode.
4. **Run the app**:
   ```bash
   flutter run
   ```

### Deployment Quick Reference

*   **For Web Deployment (Firebase Hosting)**:
    ```bash
    flutter build web
    firebase deploy
    ```

*   **For Mobile App Deployment (Android)**:
    ```bash
    flutter build apk --release
    # Or to install directly on a connected device:
    flutter install
    ```

---

## **Design Principles**
- **User-Centric**: Every action is guided by intuitive icons and helpful tooltips.
- **Engaging**: Staggered animations and page transitions make the app feel fluid.
- **Educational**: Correlation and summary sections include explanations to help non-experts understand data.
- **Responsive**: Floating input bars and flexible layouts ensure usability across different screen sizes.

---

## **Development History**
The project evolved from a basic Flutter prototype into a polished intelligence platform, focusing on:
- **Bulk Operations**: Multi-selection and batch deletion of datasets.
- **AI Polishing**: Refined LLM prompts for symbol-free, emoji-rich responses.
- **Interactive Visuals**: Integration of `fl_chart` for data-driven storytelling.
- **Technical Stability**: Pinned dependencies for `vector_math` and `fl_chart` to resolve SDK conflicts.

---