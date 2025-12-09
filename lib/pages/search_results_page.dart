import 'package:flutter/material.dart';
import '../data/movie_api_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final MovieApiService _apiService = MovieApiService();
  late Future<List<Movie>> _searchFuture;

  static const Color _backgroundColor = Color(0xFF000000);
  static const Color _accentColor = Colors.white;
  static const Color _textSecondaryColor = Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();
    _searchFuture = _apiService.searchMovies(widget.query, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text('Resultados: "${widget.query}"'),
        backgroundColor: _backgroundColor,
        foregroundColor: _accentColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<Movie>>(
        future: _searchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _accentColor),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Ocurrió un error al buscar.\nVerifica tu conexión.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red[300]),
                ),
              ),
            );
          } else {
            final movies = snapshot.data ?? [];

            if (movies.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 50, color: _textSecondaryColor),
                    SizedBox(height: 10),
                    Text(
                      'No se encontraron películas.',
                      style: TextStyle(color: _textSecondaryColor),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: movies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, index) {
                final movie = movies[index];
                return SizedBox(
                  height: 280, 
                  child: MovieCard(
                    movie: movie,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MovieDetailPage(movie: movie),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}