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

## **Folder Structure & File Analysis**

The project follows a feature-driven architecture within the `lib/` directory:

### **1. Core (`lib/core/`)**
Contains global constants, themes, and utility functions used across the entire app.
- [api_constants.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/core/constants/api_constants.dart): API endpoints and base URL configuration.
- [app_theme.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/core/theme/app_theme.dart): Global styling, colors, and font configurations.

### **2. Data (`lib/data/`)**
The data layer responsible for API communication and data modeling.
- **Services**: [api_service.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/data/services/api_service.dart) - Wrapper for HTTP requests and JWT token management.
- **Repositories**: [auth_repository.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/data/repositories/auth_repository.dart), [dataset_repository.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/data/repositories/dataset_repository.dart) - High-level abstractions for fetching and sending data.
- **Models**: [app_models.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/data/models/app_models.dart), [user_model.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/data/models/user_model.dart) - Type-safe definitions for API responses.

### **3. Features (`lib/features/`)**
Each directory represents a specific functional area of the app.
- **Auth**: [welcome_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/auth/pages/welcome_page.dart), [login_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/auth/pages/login_page.dart) - Onboarding and authentication flows with staggered entry animations.
- **Dashboard**: [dashboard_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/dashboard/pages/dashboard_page.dart) - Main landing page for dataset management and upload.
- **Summary**: [summary_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/summary/pages/summary_page.dart) - Statistical visualization of datasets.
- **Correlation**: [correlation_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/correlation/pages/correlation_page.dart) - Bar charts and matrices for variable relationships.
- **Chat**: [chat_page.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/chat/pages/chat_page.dart) - Floating chat interface with strategy mode.
- **Common**: [main_scaffold.dart](file:///d:/Project%20WOrk/ai_analyser/ai_decision_intelligence_frontend/lib/features/common/widgets/main_scaffold.dart) - The root layout wrapper managing bottom navigation and page transitions.

---

## **Directory Structure**

```text
ai_decision_intelligence_frontend/
├── assets/
│   └── images/                 # App illustrations and static assets
├── lib/
│   ├── core/                   # Global configuration and themes
│   │   ├── constants/          # API endpoints and app constants
│   │   └── theme/              # Global UI styling
│   ├── data/                   # Data layer (API & Models)
│   │   ├── models/             # Data models (JSON parsing)
│   │   ├── repositories/       # Business logic for data fetching
│   │   └── services/           # Low-level network services (HTTP/JWT)
│   ├── features/               # Modular feature implementations
│   │   ├── auth/               # Authentication & Welcome flow
│   │   ├── chat/               # AI Chatbot & Strategy Mode
│   │   ├── common/             # Shared widgets (Nav Bar, Scaffold)
│   │   ├── correlation/        # Data correlation visualization
│   │   ├── dashboard/          # Dataset management & Upload
│   │   └── summary/            # Statistical summaries
│   └── main.dart               # App entry point & Bloc providers
├── test/                       # Unit and widget tests
├── pubspec.yaml                # Dependency management
└── README.md                   # Project documentation
```

---

## **Getting Started**

### **Prerequisites**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable version recommended)
- [Dart SDK](https://dart.dev/get-dart)
- An active backend instance (FastAPI)

### **Installation**
1. **Clone the repository**
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Configure the API**:
   Update `lib/core/constants/api_constants.dart` with your backend's base URL.
4. **Run the app**:
   ```bash
   flutter run
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
