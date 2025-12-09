import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/movies_cubit.dart';
import '../cubits/movies_state.dart';
import '../widgets/movie_card.dart';
import 'movie_detail_page.dart';
import 'discover_page.dart';
import 'favorites_page.dart';
import 'search_results_page.dart';
import 'recommendations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  static const Color _backgroundColor = Color(0xFF000000);
  static const Color _surfaceColor = Color(0xFF121212);
  static const Color _accentColor = Colors.white;
  static const Color _textSecondaryColor = Color(0xFFB0B0B0);
  static const Color _inputBackgroundColor = Color(0xFF1E1E1E);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        primaryColor: _accentColor,
        colorScheme: const ColorScheme.dark(
          primary: _accentColor,
          secondary: _accentColor,
          surface: _surfaceColor,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _inputBackgroundColor,
          hintStyle: TextStyle(color: _textSecondaryColor.withOpacity(0.7)),
          prefixIconColor: _textSecondaryColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _buildBody(),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const DiscoverPage();
      case 2:
        return const FavoritesPage();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      key: const ValueKey('home'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMoviesSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/images/kino_logo.png', // Asegúrate de tener el logo aquí
                height: 50,
                fit: BoxFit.contain,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.menu, color: _accentColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explora el cine. Descubre joyas ocultas, clásicos de culto y los últimos estrenos con la ayuda de nuestra IA.',
            style: TextStyle(
              fontSize: 14,
              color: _textSecondaryColor,
              height: 1.4,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            decoration: const InputDecoration(
              hintText: 'Buscar película, director o género...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (value) {
              final q = value.trim();
              if (q.isEmpty) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchResultsPage(query: q),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: _accentColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ).copyWith(
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.white;
                    }
                    return null;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color>(
                  (states) {
                    if (states.contains(WidgetState.pressed)) {
                      return Colors.black;
                    }
                    return _accentColor;
                  }
                )
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecommendationsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text(
                'CONSULTAR ASISTENTE IA',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoviesSection() {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: BlocBuilder<MoviesCubit, MoviesState>(
        builder: (context, state) {
          String currentCategory = 'Upcoming';
          if (state is MoviesLoadSuccess) {
            currentCategory = state.category;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                child: Text(
                  "CARTELERA",
                  style: TextStyle(
                    color: _textSecondaryColor.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Upcoming', 'Próximamente', currentCategory),
                    const SizedBox(width: 10),
                    _buildCategoryChip('Trending', 'Tendencias', currentCategory),
                    const SizedBox(width: 10),
                    _buildCategoryChip('New', 'Novedades', currentCategory),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 220,
                child: _buildMoviesCarousel(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoviesCarousel(MoviesState state) {
    if (state is MoviesLoadInProgress || state is MoviesInitial) {
      return const Center(child: CircularProgressIndicator(color: _accentColor));
    } else if (state is MoviesLoadFailure) {
      return Center(
        child: Text(
          state.message,
          style: const TextStyle(color: _textSecondaryColor),
        ),
      );
    } else if (state is MoviesLoadSuccess) {
      final movies = state.movies;
      if (movies.isEmpty) {
        return const Center(
          child: Text(
            'No hay películas disponibles',
            style: TextStyle(color: _textSecondaryColor),
          ),
        );
      }
      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return SizedBox(
            width: 160,
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
  }

  Widget _buildCategoryChip(String apiKeyLabel, String displayLabel, String currentCategory) {
    final bool isSelected = currentCategory == apiKeyLabel;
    return GestureDetector(
      onTap: () {
        context.read<MoviesCubit>().changeCategory(apiKeyLabel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? _accentColor : _textSecondaryColor.withOpacity(0.3),
            width: 1.5
          ),
        ),
        child: Text(
          displayLabel.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: isSelected ? Colors.black : _textSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF222222), width: 1))
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: _backgroundColor,
        selectedItemColor: _accentColor,
        unselectedItemColor: _textSecondaryColor.withOpacity(0.5),
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            activeIcon: Icon(Icons.home_filled),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Descubrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}