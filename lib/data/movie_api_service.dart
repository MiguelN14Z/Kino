import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieApiService {
  static const String _apiKey = '';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchMoviesByCategory(String category) async {
    String endpoint;
    switch (category) {
      case 'Upcoming':
        endpoint = '/movie/upcoming';
        break;
      case 'Trending':
        endpoint = '/movie/popular';
        break;
      case 'New':
        endpoint = '/movie/now_playing';
        break;
      default:
        endpoint = '/movie/popular';
    }

    final uri = Uri.parse(
      '$_baseUrl$endpoint?api_key=$_apiKey&language=es-ES&page=1',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final results = data['results'];
    if (results is! List) {
      return [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map((json) => Movie.fromTmdbListJson(json))
        .toList();
  }

  Future<List<Movie>> searchMovies(String query,
      {int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/search/movie?api_key=$_apiKey&language=es-ES'
      '&query=$query&page=$page&include_adult=false',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (data['results'] is! List) {
      return [];
    }

    final results = data['results'] as List;

    return results
        .whereType<Map<String, dynamic>>()
        .map((json) => Movie.fromTmdbListJson(json))
        .toList();
  }

  Future<Movie> fetchMovieDetail(String id) async {
    final uri = Uri.parse(
      '$_baseUrl/movie/$id?api_key=$_apiKey&language=es-ES'
      '&append_to_response=videos',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Movie.fromTmdbDetailJson(data);
  }
}
