import '../models/movie.dart';

abstract class FavoritesState {}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoadInProgress extends FavoritesState {}

class FavoritesLoadSuccess extends FavoritesState {
  final List<String> favoriteIds;
  final List<Movie> favoriteMovies;

  FavoritesLoadSuccess({
    required this.favoriteIds,
    required this.favoriteMovies,
  });
}

class FavoritesLoadFailure extends FavoritesState {
  final String message;

  FavoritesLoadFailure(this.message);
}
