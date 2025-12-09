import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/movie.dart';
import '../data/openai_service.dart';
import '../data/movie_api_service.dart';
import 'recommendations_state.dart';

class RecommendationsCubit extends Cubit<RecommendationsState> {
  final OpenAIService openAIService;
  final MovieApiService movieApiService;

  RecommendationsCubit({
    required this.openAIService,
    required this.movieApiService,
  }) : super(RecommendationsInitial());

Future<void> generateRecommendations({
    List<Movie>? baseMovies,
    String? searchQuery,
  }) async {
    emit(RecommendationsLoadInProgress());

    try {
      String prompt = "";

      if (searchQuery != null && searchQuery.isNotEmpty) {
        prompt = "Recomienda 20  películas LO MAS PARECIDO POSIBLE A '$searchQuery'. "
           "Devuelve SOLO los títulos en español separados por barra vertical '|'. "
           "Ejemplo: Titanic|Avatar|El Padrino. "
           "No escribas nada más.";

      } else if (baseMovies != null && baseMovies.isNotEmpty) {
        final titles = baseMovies.map((m) => m.title).join(", ");
        prompt = "Al usuario le gustan: $titles. "
           "Recomienda 20 películas similares a TODAS las peliculas que esten en favorito por el usuario (para asegurar que existan en base de datos). "
           "Devuelve SOLO los títulos en español separados por barra vertical '|'. "
           "Ejemplo: Titanic|Avatar|El Padrino. "
           "No escribas nada más.";
      } else {
        emit(RecommendationsLoadFailure("Sin datos para recomendar."));
        return;
      }

      final aiResponse = await openAIService.getRecommendations(prompt);
      
      print("RESPUESTA RAW DE LA IA: $aiResponse");

      String normalizedResponse = aiResponse
          .replaceAll('_', '|')  
          .replaceAll('\n', '|') 
          .replaceAll(',', '|'); 

      List<String> movieTitles = normalizedResponse.split('|');

      List<Movie> finalMovies = [];

      for (String rawTitle in movieTitles) {
        String cleanTitle = rawTitle
            .replaceAll(RegExp(r'[0-9]+\.'), '') 
            .replaceAll('"', '')
            .replaceAll('.', '')
            .trim();

        if (cleanTitle.isEmpty) continue;

        print("Buscando en TMDB: '$cleanTitle'..."); 

        try {
          final searchResults = await movieApiService.searchMovies(cleanTitle);

          if (searchResults.isNotEmpty) {
            print("Encontrada: ${searchResults.first.title}");
            finalMovies.add(searchResults.first);
          } else {
            print("No encontrada en TMDB: $cleanTitle");
          }
        } catch (e) {
          print("Error de conexión buscando $cleanTitle: $e");
        }
      }

      if (finalMovies.isNotEmpty) {
        emit(RecommendationsLoadSuccess(finalMovies));
      } else {
        emit(RecommendationsLoadFailure(
          "La IA sugirió títulos, pero no pudimos encontrarlos en la base de datos."
        ));
      }
      
    } catch (e) {
      emit(RecommendationsLoadFailure("Error general: $e"));
    }
  }
}
  