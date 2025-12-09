import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _reviewsRef(String movieId) {
    return _db
        .collection('movies')
        .doc(movieId)
        .collection('reviews');
  }

  Stream<List<Review>> streamReviewsForMovie(String movieId) {
    return _reviewsRef(movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Review.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addReview({
    required String movieId,
    required double rating,
    required String comment,
    required String userName,
  }) async {
    final review = Review(
      id: '',
      movieId: movieId,
      userName: userName,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _reviewsRef(movieId).add(review.toMap());
  }
}
