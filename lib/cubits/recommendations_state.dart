import '../models/movie.dart';

abstract class RecommendationsState {}

class RecommendationsInitial extends RecommendationsState {}

class RecommendationsLoadInProgress extends RecommendationsState {}

class RecommendationsLoadSuccess extends RecommendationsState {
  final List<Movie> movies;

  RecommendationsLoadSuccess(this.movies);
}

class RecommendationsLoadFailure extends RecommendationsState {
  final String message;

  RecommendationsLoadFailure(this.message);
}