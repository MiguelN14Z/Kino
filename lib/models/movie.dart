class Movie {
  final String id;       
  final String title;    
  final String overview; 
  final double rating;   
  final String posterUrl;
  final String genres;   
  final int year;        
  final String? trailerKey; 

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.rating,
    required this.posterUrl,
    required this.genres,
    required this.year,
    this.trailerKey,
  });

  factory Movie.fromTmdbListJson(Map<String, dynamic> json) {
    final double voteAverage = (json['vote_average'] is num)
        ? (json['vote_average'] as num).toDouble()
        : 0.0;

    final String? posterPath = json['poster_path'];
    final String fullPosterUrl = (posterPath != null && posterPath.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : '';

    final String releaseDate = (json['release_date'] ?? '').toString();
    int parsedYear = 0;
    if (releaseDate.isNotEmpty) {
      parsedYear = int.tryParse(releaseDate.substring(0, 4)) ?? 0;
    }

    return Movie(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      rating: voteAverage,
      posterUrl: fullPosterUrl,
      genres: '', 
      year: parsedYear,
    );
  }

  factory Movie.fromTmdbDetailJson(Map<String, dynamic> json) {
    final double voteAverage = (json['vote_average'] is num)
        ? (json['vote_average'] as num).toDouble()
        : 0.0;

    final String? posterPath = json['poster_path'];
    final String fullPosterUrl = (posterPath != null && posterPath.isNotEmpty)
        ? 'https://image.tmdb.org/t/p/w500$posterPath'
        : '';

    final String releaseDate = (json['release_date'] ?? '').toString();
    int parsedYear = 0;
    if (releaseDate.isNotEmpty) {
      parsedYear = int.tryParse(releaseDate.substring(0, 4)) ?? 0;
    }

    // géneros
    String genres = '';
    final genresJson = json['genres'];
    if (genresJson is List) {
      final names = genresJson
          .whereType<Map<String, dynamic>>()
          .map((g) => g['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      genres = names.join(', ');
    }

    String? trailerKey;
    final videos = json['videos'];
    if (videos is Map<String, dynamic>) {
      final results = videos['results'];
      if (results is List) {
        for (final v in results) {
          final mv = v as Map<String, dynamic>;
          final site = (mv['site'] ?? '').toString();
          final type = (mv['type'] ?? '').toString();
          if (site == 'YouTube' &&
              (type == 'Trailer' || type == 'Teaser')) {
            trailerKey = mv['key']?.toString();
            break;
          }
        }
      }
    }

    return Movie(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      rating: voteAverage,
      posterUrl: fullPosterUrl,
      genres: genres,
      year: parsedYear,
      trailerKey: trailerKey,
    );
  }
}
