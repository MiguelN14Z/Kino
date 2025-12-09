import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrailerPage extends StatelessWidget {
  final String youtubeKey;
  final String title;

  const TrailerPage({
    super.key,
    required this.youtubeKey,
    required this.title,
  });

  // Paleta de colores de la app
  static const Color _backgroundColor = Color(0xFF050816);
  static const Color _cardColor = Color(0xFF0B1020);
  static const Color _accentSoftBlue = Color(0xFF38BDF8);

  Future<void> _openTrailer() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=$youtubeKey');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String thumbnailUrl =
        'https://img.youtube.com/vi/$youtubeKey/hqdefault.jpg';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ver tráiler en YouTube',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(
                            Icons.play_circle_outline,
                            color: Colors.white70,
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentSoftBlue,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onPressed: _openTrailer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Reproducir en YouTube'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
