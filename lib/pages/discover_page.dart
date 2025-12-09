import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/movies_cubit.dart';
import '../cubits/movies_state.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('discover'),
      color: const Color(0xFF000000),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descubrir',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Explora tendencias y recomendaciones.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFB0B0B0),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<MoviesCubit, MoviesState>(
              builder: (context, state) {
                if (state is MoviesLoadInProgress || state is MoviesInitial) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                } else if (state is MoviesLoadFailure) {
                  return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: Colors.white)));
                } else if (state is MoviesLoadSuccess) {
                  final movies = state.movies;
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
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}