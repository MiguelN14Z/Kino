import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/movie_api_service.dart';
import '../models/movie.dart';
import 'movies_state.dart';

class MoviesCubit extends Cubit<MoviesState> {
  MoviesCubit({MovieApiService? apiService})
      : _apiService = apiService ?? MovieApiService(),
        super(MoviesInitial()) {
    loadMovies(category: 'Upcoming');
  }

  final MovieApiService _apiService;

  Future<void> loadMovies({required String category}) async {
    emit(MoviesLoadInProgress());
    try {
      final List<Movie> movies =
          await _apiService.fetchMoviesByCategory(category);
      emit(MoviesLoadSuccess(movies: movies, category: category));
    } catch (e) {
      emit(MoviesLoadFailure('Error al cargar películas desde TMDB'));
    }
  }

  void changeCategory(String category) {
    loadMovies(category: category);
  }
}
