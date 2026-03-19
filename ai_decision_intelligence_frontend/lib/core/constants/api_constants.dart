import 'package:flutter/foundation.dart';

class ApiConstants {
  // Set this to true to use the Railway backend URL even in debug mode
  static const bool useRailwayBackendInDebug = true; //mark true when using Railway Backend url and false for local

  static String get baseUrl {
    if (kIsWeb) {
      return kReleaseMode || useRailwayBackendInDebug
          ? "https://ai-decision-intelligence-l8wd.onrender.com"
          : "http://localhost:8000";
    } else {
      // For Android Emulator/iOS Simulator
      return kReleaseMode || useRailwayBackendInDebug
          ? "https://ai-decision-intelligence-l8wd.onrender.com"
          : "http://10.0.2.2:8000";
    }
  }

  static const String signup = "/auth/signup";
static const String login = "/auth/login";
static const String profile = "/auth/profile";
static const String forgotPassword = "/auth/forgot-password";
static const String resetPassword = "/auth/reset-password";

static const String uploadDataset = "/dataset/upload";
static const String datasetListEndpoint = "/dataset/list";
static const String deleteDatasetEndpoint = "/dataset/delete/";
static const String deleteMultipleDatasetsEndpoint = "/dataset/delete-multiple";

static const String summary = "/analysis/summary";
static const String correlation = "/analysis/correlation";
static const String suggestedQuestionsEndpoint = "/analysis/suggested-questions";

static const String chatAsk = "/chat/ask";
static const String chatHistoryEndpoint = "/chat/history";

static const String forecastPredict = "/forecast/predict";
static const String actionPlan = "/action-plan/generate";

}
