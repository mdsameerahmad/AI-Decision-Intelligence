import 'package:flutter/material.dart';

// --- Models ---
class InsightModel {
  final String? emoji;
  final String? title;
  final String description; // This will be the suggested question
  final String? actionLabel;
  final Color? accentColor;

  const InsightModel({
    this.emoji,
    this.title,
    required this.description,
    this.actionLabel,
    this.accentColor,
  });

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      description: json['suggested_question'],
      // Default values for frontend specific fields
      emoji: "💡",
      title: "AI Insight",
      actionLabel: "View",
      accentColor: Colors.blue, // Default color
    );
  }
}

class DatasetModel {
  final int id;
  final String fileName;
  final String filePath;
  final String uploadedAt;
  final int? rows; // Not directly from /dataset/list
  final int? columns; // Not directly from /dataset/list
  final bool? isAnalyzed; // Not directly from /dataset/list

  const DatasetModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.uploadedAt,
    this.rows,
    this.columns,
    this.isAnalyzed,
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) {
    return DatasetModel(
      id: json['id'],
      fileName: json['file_name'],
      filePath: json['file_path'],
      uploadedAt: json['uploaded_at'],
      // rows, columns, isAnalyzed will be null or derived later
    );
  }
}

class ActivityModel {
  final int id;
  final String query;
  final String response;
  final String createdAt;
  final String? action; // Derived
  final String? detail; // Derived
  final String? timeAgo; // Derived
  final IconData? icon; // Derived
  final Color? dotColor; // Derived

  const ActivityModel({
    required this.id,
    required this.query,
    required this.response,
    required this.createdAt,
    this.action,
    this.detail,
    this.timeAgo,
    this.icon,
    this.dotColor,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      query: json['query'],
      response: json['response'],
      createdAt: json['created_at'],
      // Derived fields for frontend display
      action: "AI Chat Session", // Default action
      detail: json['query'], // Use query as detail for now
      timeAgo: "Just now", // Will be formatted later
      icon: Icons.chat_bubble_rounded, // Default icon
      dotColor: Colors.blue, // Default color
    );
  }
}

// --- Sample Data ---
const List<InsightModel> sampleInsights = [];

const List<DatasetModel> sampleDatasets = [];

const List<ActivityModel> sampleActivities = [];
