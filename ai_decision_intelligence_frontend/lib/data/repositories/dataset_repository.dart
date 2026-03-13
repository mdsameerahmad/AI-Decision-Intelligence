import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/constants/api_constants.dart';
import '../../data/services/api_service.dart';

class DatasetRepository {
  final ApiService apiService;

  DatasetRepository(this.apiService);

  Future<List<dynamic>> listDatasets() async {
    final response = await apiService.get(ApiConstants.datasetListEndpoint);
    return response['datasets'];
  }

  Future<void> deleteDataset(int datasetId) async {
    await apiService.delete("${ApiConstants.deleteDatasetEndpoint}$datasetId");
  }

  Future<void> deleteMultipleDatasets(List<int> datasetIds) async {
    await apiService.post(
      ApiConstants.deleteMultipleDatasetsEndpoint,
      {"dataset_ids": datasetIds},
    );
  }

  Future<Map<String, dynamic>> uploadDataset(Uint8List fileBytes, String fileName) async {
    var uri = Uri.parse(ApiConstants.baseUrl + ApiConstants.uploadDataset);
    var request = http.MultipartRequest('POST', uri);

    final token = await apiService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      fileBytes,
      filename: fileName,
      contentType: MediaType('text', 'csv'),
    ));

    var response = await request.send();
    var responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return apiService.jsonDecode(responseBody.body);
    } else {
      throw Exception('Failed to upload dataset: ${responseBody.body}');
    }
  }

  Future<Map<String, dynamic>> getSummary(String filePath) async {
    return await apiService.post(
      ApiConstants.summary,
      {"file_path": filePath},
    );
  }

  Future<Map<String, dynamic>> getCorrelation(String filePath) async {
    return await apiService.post(
      ApiConstants.correlation,
      {"file_path": filePath},
    );
  }

  Future<List<dynamic>> getSuggestedQuestions(String filePath) async {
    final response = await apiService.post(
      ApiConstants.suggestedQuestionsEndpoint,
      {"file_path": filePath},
    );
    return response['suggested_questions'];
  }

  Future<Map<String, dynamic>> askChatbot(String filePath, String question) async {
    return await apiService.post(
      ApiConstants.chatAsk,
      {"file_path": filePath, "question": question},
    );
  }

  Future<Map<String, dynamic>> generateActionPlan(String problem) async {
    return await apiService.post(
      ApiConstants.actionPlan,
      {"problem": problem},
    );
  }

  Future<List<dynamic>> getChatHistory() async {
    final response = await apiService.get(ApiConstants.chatHistoryEndpoint);
    return response['history'] ?? response;
  }
}
