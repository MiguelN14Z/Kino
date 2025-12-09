import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/favorites_cubit.dart';
import '../cubits/favorites_state.dart';
import '../data/movie_api_service.dart';
import '../data/review_service.dart';
import '../models/movie.dart';
import '../models/review.dart';
import 'trailer_page.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({super.key, required this.movie});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? _detailedMovie;
  bool _loadingDetail = false;
  final MovieApiService _apiService = MovieApiService();

  final ReviewService _reviewService = ReviewService();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _nameController =
      TextEditingController(text: "Usuario");
  double _reviewRating = 5.0;
  bool _sendingReview = false;

  static const Color _backgroundColor = Color(0xFF000000);
  static const Color _surfaceColor = Color(0xFF121212);
  static const Color _accentColor = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0B0);
  static const Color _inputFillColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loadingDetail = true;
    });
    try {
      final detail = await _apiService.fetchMovieDetail(widget.movie.id);
      setState(() {
        _detailedMovie = detail;
      });
    } catch (_) {
    } finally {
      setState(() {
        _loadingDetail = false;
      });
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(Movie movie) async {
    final text = _reviewController.text.trim();
    final name = _nameController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escribe un comentario antes de enviar', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
        ),
      );
      return;
    }

    setState(() {
      _sendingReview = true;
    });

    try {
      await _reviewService.addReview(
        movieId: movie.id,
        rating: _reviewRating,
        comment: text,
        userName: name.isEmpty ? 'Anónimo' : name,
      );
      _reviewController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reseña publicada', style: TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar reseña'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sendingReview = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = _detailedMovie ?? widget.movie;
    final ratingText =
        movie.rating == 0.0 ? 'N/A' : movie.rating.toStringAsFixed(1);

    return Scaffold(
      backgroundColor: _backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 450,
                  width: double.infinity,
                  child: movie.posterUrl.isNotEmpty
                      ? Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: _surfaceColor),
                        )
                      : Container(color: _surfaceColor),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 250,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          _backgroundColor.withOpacity(0.8),
                          _backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (movie.year != 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white70),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  movie.year.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            if (movie.year != 0) const SizedBox(width: 10),
                            if (movie.genres.isNotEmpty)
                              Expanded(
                                child: Text(
                                  movie.genres,
                                  style: const TextStyle(
                                    color: _textSecondary,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 6),
                            Text(
                              ratingText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "/ 10",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_loadingDetail)
              const LinearProgressIndicator(
                minHeight: 2,
                color: _accentColor,
                backgroundColor: _surfaceColor,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, state) {
                      final favoritesCubit = context.read<FavoritesCubit>();
                      final isFav = favoritesCubit.isFavorite(movie.id);
                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFav ? Colors.white : _surfaceColor,
                                  foregroundColor: isFav ? Colors.black : Colors.white,
                                  side: isFav ? null : const BorderSide(color: Colors.white, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  favoritesCubit.toggleFavorite(movie);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isFav ? 'Eliminado de favoritos' : 'Añadido a favoritos',
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      backgroundColor: Colors.white,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  isFav ? Icons.bookmark : Icons.bookmark_border,
                                ),
                                label: Text(
                                  isFav ? "GUARDADO" : "FAVORITOS",
                                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  final key = movie.trailerKey;
                                  if (key == null || key.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("No hay tráiler disponible"),
                                        backgroundColor: Colors.grey,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TrailerPage(
                                          youtubeKey: key,
                                          title: movie.title,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text(
                                  "TRAILER",
                                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "SINOPSIS",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    movie.overview.isNotEmpty ? movie.overview : 'Sin sinopsis disponible.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Divider(color: _surfaceColor, thickness: 2),
                  const SizedBox(height: 20),
                  const Text(
                    "RESEÑAS DE LA COMUNIDAD",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Escribe tu opinión",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Tu nombre',
                            labelStyle: const TextStyle(color: _textSecondary),
                            filled: true,
                            fillColor: _inputFillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text("Tu nota:", style: TextStyle(color: _textSecondary)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.grey[800],
                                  thumbColor: Colors.white,
                                  overlayColor: Colors.white.withOpacity(0.2),
                                  valueIndicatorColor: Colors.white,
                                  valueIndicatorTextStyle: const TextStyle(color: Colors.black),
                                ),
                                child: Slider(
                                  value: _reviewRating,
                                  min: 0,
                                  max: 10,
                                  divisions: 20,
                                  label: _reviewRating.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setState(() {
                                      _reviewRating = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                _reviewRating.toStringAsFixed(1),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '¿Qué te pareció la película?',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: _inputFillColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _sendingReview ? null : () => _submitReview(movie),
                            child: _sendingReview
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                                : const Text("PUBLICAR RESEÑA", style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  StreamBuilder<List<Review>>(
                    stream: _reviewService.streamReviewsForMovie(movie.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) return const Text('Error al cargar reseñas', style: TextStyle(color: Colors.red));
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Sé el primero en opinar.', style: TextStyle(color: _textSecondary)),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final r = reviews[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: const Color(0xFF333333),
                                          child: Text(
                                            r.userName.isNotEmpty ? r.userName[0].toUpperCase() : '?',
                                            style: const TextStyle(color: Colors.white, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          r.userName,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 12),
                                          const SizedBox(width: 4),
                                          Text(
                                            r.rating.toStringAsFixed(1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  r.comment,
                                  style: TextStyle(color: Colors.grey[300], height: 1.4),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}