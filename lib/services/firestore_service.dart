import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== USER PROFILE ==========
  Future<void> updateUserProfile(String userId, String displayName, String bio, String avatarUrl) async {
    await _db.collection('users').doc(userId).set({
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  // ========== WATCHLIST ==========
  Future<void> addToWatchlist(String userId, MediaItem item) async {
    await _db.collection('users').doc(userId).collection('watchlist').doc(item.id.toString())
        .set(item.toMap()..['addedAt'] = FieldValue.serverTimestamp());
  }

  Future<void> removeFromWatchlist(String userId, int mediaId) async {
    await _db.collection('users').doc(userId).collection('watchlist').doc(mediaId.toString()).delete();
  }

  Stream<List<MediaItem>> getWatchlist(String userId) {
    return _db.collection('users').doc(userId).collection('watchlist')
        .orderBy('addedAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return MediaItem(
                id: data['id'], title: data['title'], overview: data['overview'] ?? '',
                posterPath: data['posterPath'] ?? '', backdropPath: data['backdropPath'] ?? '',
                voteAverage: (data['voteAverage'] ?? 0).toDouble(), releaseDate: data['releaseDate'] ?? '',
                genreIds: List<int>.from(data['genreIds'] ?? []), popularity: (data['popularity'] ?? 0).toDouble(),
                mediaType: data['mediaType'] ?? 'movie',
              );
            }).toList());
  }

  Future<bool> isInWatchlist(String userId, int mediaId) async {
    final doc = await _db.collection('users').doc(userId).collection('watchlist').doc(mediaId.toString()).get();
    return doc.exists;
  }

  // ========== REVIEWS ==========
  Future<void> submitReview({
    required String userId,
    required String userName,
    required String userAvatar,
    required int mediaId,
    required String mediaType,
    required double rating,
    required String comment,
  }) async {
    final docRef = _db.collection('reviews').doc('${mediaId}_$userId');
    await docRef.set({
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'mediaId': mediaId,
      'mediaType': mediaType,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserReview(String userId, int mediaId) async {
    final doc = await _db.collection('reviews').doc('${mediaId}_$userId').get();
    return doc.exists ? doc.data() : null;
  }

  Stream<List<Map<String, dynamic>>> getReviews(int mediaId) {
    return _db.collection('reviews').where('mediaId', isEqualTo: mediaId)
        .orderBy('createdAt', descending: true).snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Future<double> getAverageUserRating(int mediaId) async {
    final snapshot = await _db.collection('reviews').where('mediaId', isEqualTo: mediaId).get();
    if (snapshot.docs.isEmpty) return 0.0;
    double total = 0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['rating'] as num?)?.toDouble() ?? 0;
    }
    return total / snapshot.docs.length;
  }
}