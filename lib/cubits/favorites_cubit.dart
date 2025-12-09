import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/movie_api_service.dart';
import '../models/movie.dart';
import 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({MovieApiService? apiService})
      : _apiService = apiService ?? MovieApiService(),
        super(FavoritesInitial()) {
    loadFavorites();
  }

  static const String _prefsKey = 'favorite_ids';
  final MovieApiService _apiService;

  Future<void> loadFavorites() async {
    emit(FavoritesLoadInProgress());
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_prefsKey) ?? [];

      final List<Movie> movies = [];
      for (final id in ids) {
        try {
          final movie = await _apiService.fetchMovieDetail(id);
          movies.add(movie);
        } catch (_) {}
      }

      emit(FavoritesLoadSuccess(
        favoriteIds: ids,
        favoriteMovies: movies,
      ));
    } catch (e) {
      emit(FavoritesLoadFailure('Error al cargar favoritos'));
    }
  }

  Future<void> toggleFavorite(Movie movie) async {
    final currentState = state;
    if (currentState is! FavoritesLoadSuccess) return;

    final List<String> ids = List.from(currentState.favoriteIds);
    final List<Movie> movies = List.from(currentState.favoriteMovies);

    final exists = ids.contains(movie.id);

    if (exists) {
      ids.remove(movie.id);
      movies.removeWhere((m) => m.id == movie.id);
    } else {
      ids.add(movie.id);
      movies.add(movie);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, ids);

    emit(FavoritesLoadSuccess(
      favoriteIds: ids,
      favoriteMovies: movies,
    ));
  }

  bool isFavorite(String movieId) {
    final currentState = state;
    if (currentState is FavoritesLoadSuccess) {
      return currentState.favoriteIds.contains(movieId);
    }
    return false;
  }
}
