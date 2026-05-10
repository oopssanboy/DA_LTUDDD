import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/omdb_api_service.dart';
import '../services/firestore_service.dart';

class MovieProvider with ChangeNotifier {
  final OMDBApiService _omdbService = OMDBApiService();
  final FirestoreService _firestoreService = FirestoreService();

  List<Movie> _popularMovies = [];
  List<Movie> _searchResults = [];
  Map<String, dynamic> _currentMovieDetail = {};
  bool _loading = false;
  String? _error;

  List<Movie> _watchlist = [];
  String? _userId;

  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get searchResults => _searchResults;
  Map<String, dynamic> get currentMovieDetail => _currentMovieDetail;
  bool get loading => _loading;
  String? get error => _error;
  List<Movie> get watchlist => _watchlist;

  void setUserId(String? uid) {
    _userId = uid;
    if (uid != null) {
      _listenToWatchlist(uid);
    } else {
      _watchlist = [];
      notifyListeners();
    }
  }

  void _listenToWatchlist(String userId) {
    _firestoreService.getWatchlist(userId).listen((movies) {
      _watchlist = movies;
      notifyListeners();
    });
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> fetchPopularMovies() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Từ khóa mặc định cho trang chủ
      _popularMovies = await _omdbService.searchMovies('Doraemon');
    } catch (e) {
      _error = e.toString();
      print('Lỗi fetchPopularMovies: $e');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> searchMovies(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _searchResults = await _omdbService.searchMovies(query);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchMovieDetail(int movieId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Chuyển id thành imdbID (tt + 7 chữ số)
      String imdbID = 'tt${movieId.toString().padLeft(7, '0')}';
      _currentMovieDetail = await _omdbService.getMovieDetails(imdbID);
    } catch (e) {
      _error = e.toString();
      print('Lỗi fetchMovieDetail: $e');
      _currentMovieDetail = {}; // đảm bảo không giữ detail cũ
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> isMovieInWatchlist(int movieId) async {
    if (_userId == null) return false;
    return await _firestoreService.isInWatchlist(_userId!, movieId);
  }

  Future<void> toggleWatchlist(Movie movie) async {
    if (_userId == null) return;
    bool already = await isMovieInWatchlist(movie.id);
    if (already) {
      await _firestoreService.removeFromWatchlist(_userId!, movie.id);
    } else {
      await _firestoreService.addToWatchlist(_userId!, movie);
    }
    // Stream sẽ tự cập nhật, không cần notify thêm
  }
}