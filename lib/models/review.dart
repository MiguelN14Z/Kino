import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String movieId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.movieId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Review.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return Review(
      id: doc.id,
      movieId: data['movieId'] ?? '',
      userName: data['userName'] ?? 'Anónimo',
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : 0.0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}
