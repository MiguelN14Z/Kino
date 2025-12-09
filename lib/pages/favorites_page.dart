import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/favorites_state.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('favorites'),
      color: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mis Favoritos',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tu colección personal de cine.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<FavoritesCubit, FavoritesState>(
              builder: (context, state) {
                if (state is FavoritesLoadSuccess) {
                  final movies = state.favoriteMovies;

                  if (movies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 60, color: Colors.grey[800]),
                          const SizedBox(height: 16),
                          const Text(
                            'Aún no tienes favoritos',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
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
                } else if (state is FavoritesLoadFailure) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.white)));
                } else {
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}