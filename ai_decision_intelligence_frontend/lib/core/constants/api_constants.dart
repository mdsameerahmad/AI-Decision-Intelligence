

class ApiConstants {
  // Single source of truth → your EC2 backend
  static const String _remoteUrl = "http://13.126.197.139:8000";

  static String get baseUrl {
    return _remoteUrl;
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