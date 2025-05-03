import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Replace with your actual backend endpoint
  final String baseUrl = 'https://your-api-endpoint.com/api';
  
  Future<List<Map<String, dynamic>>> fetchCryptoData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/crypto'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load crypto data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching crypto data: $e');
    }
  }
} 