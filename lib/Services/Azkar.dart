import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islamic_app/Model/Azkar.dart';

ApiModel? apiModel;

class ApiService {
  Future<ApiModel?> fetchData() async {
    final url = Uri.parse(
        'https://raw.githubusercontent.com/nawafalqari/azkar-api/56df51279ab6eb86dc2f6202c7de26c8948331c1/azkar.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode JSON and explicitly cast it to Map<String, dynamic>
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Parse JSON into the ApiModel
      final apiModel = ApiModel.fromJson(data);

      // Debug print to ensure data is parsed correctly
      print(apiModel.apiModel);

      return apiModel;
    } else {
      print('Failed to load. Status code: ${response.statusCode}');
      return null;
    }
  }
}
