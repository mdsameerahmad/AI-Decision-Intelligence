import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/app_models.dart';
import '../../../data/repositories/dataset_repository.dart';

// --- Events ---
abstract class DashboardEvent {}

class LoadDatasets extends DashboardEvent {}

class LoadChatHistory extends DashboardEvent {}

class DeleteDataset extends DashboardEvent {
  final int datasetId;
  DeleteDataset(this.datasetId);
}

class ToggleDatasetSelection extends DashboardEvent {
  final int datasetId;
  ToggleDatasetSelection(this.datasetId);
}

class SelectAllDatasets extends DashboardEvent {
  final bool selectAll;
  SelectAllDatasets(this.selectAll);
}

class DeleteSelectedDatasets extends DashboardEvent {}

class UploadDataset extends DashboardEvent {
  final Uint8List fileBytes;
  final String fileName;
  UploadDataset(this.fileBytes, this.fileName);
}

class ImportGoogleSheet extends DashboardEvent {
  final String url;
  ImportGoogleSheet(this.url);
}

class GetSummary extends DashboardEvent {
  final String filePath;
  GetSummary(this.filePath);
}

class GetCorrelation extends DashboardEvent {
  final String filePath;
  GetCorrelation(this.filePath);
}

class GetSuggestedQuestions extends DashboardEvent {
  final String filePath;
  GetSuggestedQuestions(this.filePath);
}

class AskChatbot extends DashboardEvent {
  final String question;
  AskChatbot(this.question);
}

class GenerateActionPlan extends DashboardEvent {
  final String problem;
  GenerateActionPlan(this.problem);
}

class ClearSummary extends DashboardEvent {}

class ClearCorrelation extends DashboardEvent {}

class ClearChat extends DashboardEvent {}

class SelectChatSession extends DashboardEvent {
  final String? datasetPath;
  final String? sessionTitle;
  SelectChatSession({this.datasetPath, this.sessionTitle});
}

class GetForecast extends DashboardEvent {
  final String filePath;
  final String column;
  GetForecast(this.filePath, this.column);
}

// --- State ---
class DashboardState {
  final List<DatasetModel> datasets;
  final Set<int> selectedDatasetIds;
  final Map<String, dynamic>? activeSummary;
  final Map<String, dynamic>? activeCorrelation;
  final List<String> suggestedQuestions;
  final List<Map<String, String>> chatHistory;
  final bool isLoading;
  final String? errorMessage;
  final String? lastFilePath;
  final Map<String, dynamic>? forecastResult;

  DashboardState({
    this.datasets = const [],
    this.selectedDatasetIds = const {},
    this.activeSummary,
    this.activeCorrelation,
    this.suggestedQuestions = const [],
    this.chatHistory = const [],
    this.isLoading = false,
    this.errorMessage,
    this.lastFilePath,
    this.forecastResult,
  });

  DashboardState copyWith({
    List<DatasetModel>? datasets,
    Set<int>? selectedDatasetIds,
    Map<String, dynamic>? activeSummary,
    Map<String, dynamic>? activeCorrelation,
    List<String>? suggestedQuestions,
    List<Map<String, String>>? chatHistory,
    bool? isLoading,
    String? errorMessage,
    String? lastFilePath,
    Map<String, dynamic>? forecastResult,
    bool clearSummary = false,
    bool clearCorrelation = false,
    bool clearChat = false,
    bool clearSuggestedQuestions = false,
  }) {
    return DashboardState(
      datasets: datasets ?? this.datasets,
      selectedDatasetIds: selectedDatasetIds ?? this.selectedDatasetIds,
      activeSummary: clearSummary ? null : (activeSummary ?? this.activeSummary),
      activeCorrelation: clearCorrelation ? null : (activeCorrelation ?? this.activeCorrelation),
      suggestedQuestions: clearSuggestedQuestions ? [] : (suggestedQuestions ?? this.suggestedQuestions),
      chatHistory: clearChat ? [] : (chatHistory ?? this.chatHistory),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      lastFilePath: lastFilePath ?? this.lastFilePath,
      forecastResult: forecastResult ?? this.forecastResult,
    );
  }
}

// --- Bloc ---
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DatasetRepository repository;

  DashboardBloc(this.repository) : super(DashboardState()) {
    on<LoadDatasets>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final List<dynamic> rawDatasets = await repository.listDatasets();
        final datasets = rawDatasets.map((e) => DatasetModel.fromJson(e)).toList();
        emit(state.copyWith(datasets: datasets, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<UploadDataset>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await repository.uploadDataset(event.fileBytes, event.fileName);
        final List<dynamic> rawDatasets = await repository.listDatasets();
        final datasets = rawDatasets.map((e) => DatasetModel.fromJson(e)).toList();
        emit(state.copyWith(datasets: datasets, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<ImportGoogleSheet>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await repository.importGoogleSheet(event.url);
        final List<dynamic> rawDatasets = await repository.listDatasets();
        final datasets = rawDatasets.map((e) => DatasetModel.fromJson(e)).toList();
        emit(state.copyWith(datasets: datasets, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<DeleteDataset>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        await repository.deleteDataset(event.datasetId);
        
        // Update the list after deletion
        final List<dynamic> rawDatasets = await repository.listDatasets();
        final datasets = rawDatasets.map((e) => DatasetModel.fromJson(e)).toList();
        
        // If the deleted dataset was the active one, clear its summary and correlation
        bool clearActiveData = false;
        if (state.datasets.any((d) => d.id == event.datasetId && d.filePath == state.lastFilePath)) {
          clearActiveData = true;
        }

        // Remove from selection if it was selected
        final newSelection = Set<int>.from(state.selectedDatasetIds)..remove(event.datasetId);

        emit(state.copyWith(
          datasets: datasets, 
          selectedDatasetIds: newSelection,
          isLoading: false,
          clearSummary: clearActiveData,
          clearCorrelation: clearActiveData,
          clearSuggestedQuestions: clearActiveData,
          lastFilePath: clearActiveData ? null : state.lastFilePath,
        ));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<ToggleDatasetSelection>((event, emit) {
      final newSelection = Set<int>.from(state.selectedDatasetIds);
      if (newSelection.contains(event.datasetId)) {
        newSelection.remove(event.datasetId);
      } else {
        newSelection.add(event.datasetId);
      }
      emit(state.copyWith(selectedDatasetIds: newSelection));
    });

    on<SelectAllDatasets>((event, emit) {
      if (event.selectAll) {
        final allIds = state.datasets.map((d) => d.id).toSet();
        emit(state.copyWith(selectedDatasetIds: allIds));
      } else {
        emit(state.copyWith(selectedDatasetIds: {}));
      }
    });

    on<DeleteSelectedDatasets>((event, emit) async {
      if (state.selectedDatasetIds.isEmpty) return;
      
      emit(state.copyWith(isLoading: true));
      try {
        final idsToDelete = state.selectedDatasetIds.toList();
        await repository.deleteMultipleDatasets(idsToDelete);
        
        // Update the list after deletion
        final List<dynamic> rawDatasets = await repository.listDatasets();
        final datasets = rawDatasets.map((e) => DatasetModel.fromJson(e)).toList();
        
        // Check if active dataset was deleted
        bool clearActiveData = false;
        if (state.datasets.any((d) => state.selectedDatasetIds.contains(d.id) && d.filePath == state.lastFilePath)) {
          clearActiveData = true;
        }

        emit(state.copyWith(
          datasets: datasets, 
          selectedDatasetIds: {}, // Clear selection
          isLoading: false,
          clearSummary: clearActiveData,
          clearCorrelation: clearActiveData,
          clearSuggestedQuestions: clearActiveData,
          lastFilePath: clearActiveData ? null : state.lastFilePath,
        ));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<GetSummary>((event, emit) async {
      emit(state.copyWith(
        isLoading: true, 
        lastFilePath: event.filePath,
        clearSuggestedQuestions: true, // Clear old questions when new summary is requested
        clearCorrelation: true, // Clear old correlation when new summary is requested
      ));
      try {
        final summary = await repository.getSummary(event.filePath);
        emit(state.copyWith(activeSummary: summary, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<GetCorrelation>((event, emit) async {
      emit(state.copyWith(isLoading: true, lastFilePath: event.filePath));
      try {
        final correlation = await repository.getCorrelation(event.filePath);
        emit(state.copyWith(activeCorrelation: correlation, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<GetSuggestedQuestions>((event, emit) async {
      emit(state.copyWith(isLoading: true, lastFilePath: event.filePath));
      try {
        final questions = await repository.getSuggestedQuestions(event.filePath);
        emit(state.copyWith(
          suggestedQuestions: List<String>.from(questions),
          isLoading: false,
        ));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<AskChatbot>((event, emit) async {
      if (state.lastFilePath == null) return;
      final newHistory = List<Map<String, String>>.from(state.chatHistory)
        ..add({'sender': 'user', 'message': event.question, 'dataset': state.lastFilePath ?? '', 'title': ''});
      emit(state.copyWith(chatHistory: newHistory, isLoading: true));

      try {
        final response = await repository.askChatbot(state.lastFilePath!, event.question);
        final botHistory = List<Map<String, String>>.from(state.chatHistory)
          ..add({'sender': 'bot', 'message': response['answer'], 'dataset': state.lastFilePath ?? '', 'title': ''});
        emit(state.copyWith(chatHistory: botHistory, isLoading: false));
      } catch (e) {
        final errorHistory = List<Map<String, String>>.from(state.chatHistory)
          ..add({'sender': 'bot', 'message': 'Error: ${e.toString()}', 'dataset': state.lastFilePath ?? '', 'title': ''});
        emit(state.copyWith(chatHistory: errorHistory, isLoading: false));
      }
    });

    on<GenerateActionPlan>((event, emit) async {
      final newHistory = List<Map<String, String>>.from(state.chatHistory)
        ..add({'sender': 'user', 'message': 'Generate a strategic plan for: ${event.problem}'});
      emit(state.copyWith(chatHistory: newHistory, isLoading: true));

      try {
        final response = await repository.generateActionPlan(event.problem);
        final tasks = response['recommended_tasks'] as List<dynamic>;
        final planMessage = tasks.join('\n\n');
        
        final botHistory = List<Map<String, String>>.from(state.chatHistory)
          ..add({'sender': 'bot', 'message': planMessage});
        emit(state.copyWith(chatHistory: botHistory, isLoading: false));
      } catch (e) {
        final errorHistory = List<Map<String, String>>.from(state.chatHistory)
          ..add({'sender': 'bot', 'message': 'Error generating plan: ${e.toString()}'});
        emit(state.copyWith(chatHistory: errorHistory, isLoading: false));
      }
    });

    on<ClearSummary>((event, emit) {
      emit(state.copyWith(clearSummary: true));
    });

    on<ClearCorrelation>((event, emit) {
      emit(state.copyWith(clearCorrelation: true));
    });

    on<ClearChat>((event, emit) {
      emit(state.copyWith(clearChat: true));
    });

    on<LoadChatHistory>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final list = await repository.getChatHistory();
        final history = <Map<String, String>>[];
        for (final item in list) {
          final query = item['query']?.toString() ?? '';
          final response = item['response']?.toString() ?? '';
          final dataset = item['dataset_path']?.toString();
          final title = item['session_title']?.toString();
          if (query.isNotEmpty) {
            history.add({'sender': 'user', 'message': query, 'dataset': dataset ?? '', 'title': title ?? ''});
          }
          if (response.isNotEmpty) {
            history.add({'sender': 'bot', 'message': response, 'dataset': dataset ?? '', 'title': title ?? ''});
          }
        }
        emit(state.copyWith(chatHistory: history, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<SelectChatSession>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final list = await repository.getChatHistory();
        final filtered = <Map<String, String>>[];
        for (final item in list) {
          final ds = item['dataset_path']?.toString();
          final title = item['session_title']?.toString();
          final matchesDs = event.datasetPath == null || event.datasetPath == ds;
          final matchesTitle = event.sessionTitle == null || event.sessionTitle == title;
          if (matchesDs && matchesTitle) {
            final query = item['query']?.toString() ?? '';
            final response = item['response']?.toString() ?? '';
            if (query.isNotEmpty) {
              filtered.add({'sender': 'user', 'message': query});
            }
            if (response.isNotEmpty) {
              filtered.add({'sender': 'bot', 'message': response});
            }
          }
        }
        emit(state.copyWith(chatHistory: filtered, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });

    on<GetForecast>((event, emit) async {
      emit(state.copyWith(isLoading: true));
      try {
        final forecast = await repository.getForecast(event.filePath, event.column);
        emit(state.copyWith(forecastResult: forecast, isLoading: false));
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString(), isLoading: false));
      }
    });
  }
}
