import '../models/movie.dart';

abstract class MoviesState {}

class MoviesInitial extends MoviesState {}

class MoviesLoadInProgress extends MoviesState {}

class MoviesLoadSuccess extends MoviesState {
  final List<Movie> movies;
  final String category; 

  MoviesLoadSuccess({
    required this.movies,
    required this.category,
  });
}

class MoviesLoadFailure extends MoviesState {
  final String message;

  MoviesLoadFailure(this.message);
}
