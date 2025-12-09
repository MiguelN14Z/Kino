import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/recommendations_cubit.dart';
import '../cubits/recommendations_state.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/favorites_state.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';

class RecommendationsPage extends StatefulWidget {
  const RecommendationsPage({super.key});

  @override
  State<RecommendationsPage> createState() => _RecommendationsPageState();
}

class _RecommendationsPageState extends State<RecommendationsPage> {
  final TextEditingController _searchController = TextEditingController();

  static const Color _backgroundColor = Color(0xFF000000);
  static const Color _accentColor = Colors.white;
  static const Color _textSecondaryColor = Color(0xFFB0B0B0);
  static const Color _inputBackgroundColor = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchByText() {
    if (_searchController.text.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<RecommendationsCubit>().generateRecommendations(
      searchQuery: _searchController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _accentColor,
          selectionColor: Colors.white24,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _inputBackgroundColor,
          hintStyle: TextStyle(color: _textSecondaryColor.withOpacity(0.7)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _accentColor, width: 1),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        appBar: AppBar(
          title: const Text('Asistente de Cine IA'),
          backgroundColor: _backgroundColor,
          elevation: 0,
          foregroundColor: _accentColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "BÚSQUEDA INTELIGENTE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _textSecondaryColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      onSubmitted: (_) => _searchByText(),
                      decoration: const InputDecoration(
                        hintText: 'Ej: "Suspenso psicológico de los 90"',
                        prefixIcon: Icon(Icons.psychology_outlined, color: _textSecondaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _searchByText,
                      icon: const Icon(Icons.arrow_forward, color: Colors.black),
                      tooltip: "Buscar",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              BlocBuilder<FavoritesCubit, FavoritesState>(
                builder: (context, favState) {
                  final hasFavorites = favState is FavoritesLoadSuccess && 
                                       favState.favoriteMovies.isNotEmpty;
                  return SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: hasFavorites ? _accentColor : _textSecondaryColor,
                        side: BorderSide(
                          color: hasFavorites ? _accentColor : const Color(0xFF333333), 
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: hasFavorites ? () {
                        FocusScope.of(context).unfocus();
                        _searchController.clear();
                        context.read<RecommendationsCubit>().generateRecommendations(
                          baseMovies: favState.favoriteMovies,
                        );
                      } : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Agrega favoritos para usar esta función", style: TextStyle(color: Colors.black)),
                            backgroundColor: Colors.white,
                          ),
                        );
                      },
                      icon: Icon(
                        hasFavorites ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                      ),
                      label: Text(
                        hasFavorites 
                          ? 'RECOMENDAR SEGÚN MIS GUSTOS'
                          : 'AGREGA FAVORITOS PRIMERO',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF222222)),
              const SizedBox(height: 10),
              Expanded(
                child: BlocBuilder<RecommendationsCubit, RecommendationsState>(
                  builder: (context, state) {
                    if (state is RecommendationsLoadInProgress) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: _accentColor),
                            SizedBox(height: 16),
                            Text("Consultando a la IA...", style: TextStyle(color: _textSecondaryColor)),
                          ],
                        ),
                      );
                    } else if (state is RecommendationsLoadFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "⚠️ ${state.message}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      );
                    } else if (state is RecommendationsLoadSuccess) {
                      final movies = state.movies;
                      if (movies.isEmpty) {
                        return const Center(child: Text("No se encontraron coincidencias.", style: TextStyle(color: _textSecondaryColor)));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 10, bottom: 20),
                        itemCount: movies.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final movie = movies[index];
                          // Altura fija obligatoria
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
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome_outlined,
                                size: 50, color: Color(0xFF222222)),
                            SizedBox(height: 16),
                            Text(
                              "Tu asistente de cine personal",
                              style: TextStyle(color: Color(0xFF444444)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}