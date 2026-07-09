import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String _seafoodUrl =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Seafood';
  static const String _beefUrl =
      'https://www.themealdb.com/api/json/v1/1/filter.php?c=Beef';

  Future<List<Map<String, dynamic>>> fetchSeafoodMeals() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_seafoodUrl));
      // Set connection timeout
      client.connectionTimeout = const Duration(seconds: 10);

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as Map<String, dynamic>;
        if (data.containsKey('meals') && data['meals'] is List) {
          return List<Map<String, dynamic>>.from(data['meals']);
        }
      }
    } catch (_) {
      // Fail silently or handle error in UI
    } finally {
      client.close();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchBeefMeals() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(_beefUrl));
      // Set connection timeout
      client.connectionTimeout = const Duration(seconds: 10);

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = json.decode(responseBody) as Map<String, dynamic>;
        if (data.containsKey('meals') && data['meals'] is List) {
          return List<Map<String, dynamic>>.from(data['meals']);
        }
      }
    } catch (_) {
      // Fail silently or handle error in UI
    } finally {
      client.close();
    }
    return [];
  }
}
