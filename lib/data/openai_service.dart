import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey = 'YOUR_OPENAI API_KEY_HERE '; 

  Future<String> getRecommendations(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
    "model": "gpt-3.5-turbo",
    "messages": [
      {"role": "system", "content": "Eres un asistente que SOLO responde con títulos de películas separados por el símbolo guión bajo '_'. No digas nada más. Ejemplo: Matrix_Titanic_Avatar"},
      {"role": "user", "content": prompt}
    ],
    }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Error OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}