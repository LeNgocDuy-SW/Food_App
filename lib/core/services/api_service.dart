import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _seafoodUrl =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';
  static const String _beefUrl =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Beef';

  Future<List<Map<String, dynamic>>> fetchSeafoodMeals() async {
    try {
      final response = await http.get(Uri.parse(_seafoodUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('meals') && data['meals'] is List) {
          return List<Map<String, dynamic>>.from(data['meals']);
        }
      }
    } catch (_) {
      // Fail silently or handle error in UI
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchBeefMeals() async {
    try {
      final response = await http.get(Uri.parse(_beefUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('meals') && data['meals'] is List) {
          return List<Map<String, dynamic>>.from(data['meals']);
        }
      }
    } catch (_) {
      // Fail silently or handle error in UI
    }
    return [];
  }
}
