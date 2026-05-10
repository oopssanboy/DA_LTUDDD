import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Thêm phim vào watchlist
  Future<void> addToWatchlist(String userId, Movie movie) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movie.id.toString())
        .set({
      'id': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'overview': movie.overview,
      'voteAverage': movie.voteAverage,
      'releaseDate': movie.releaseDate,
      'backdropPath': movie.backdropPath,
      'popularity': movie.popularity,
      'genreIds': movie.genreIds,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Xóa phim khỏi watchlist
  Future<void> removeFromWatchlist(String userId, int movieId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .delete();
  }

  // Lấy danh sách watchlist
  Stream<List<Movie>> getWatchlist(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Movie.fromJson(doc.data())).toList());
  }

  // Kiểm tra xem phim đã có trong watchlist chưa
  Future<bool> isInWatchlist(String userId, int movieId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('watchlist')
        .doc(movieId.toString())
        .get();
    return doc.exists;
  }
}