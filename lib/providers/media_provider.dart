import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // THÊM THƯ VIỆN NÀY
import '../models/media_item.dart';
import '../services/tmdb_api_service.dart';
import '../services/firestore_service.dart';

class MediaProvider with ChangeNotifier {
  final TMDBApiService _tmdbService = TMDBApiService();
  final FirestoreService _firestoreService = FirestoreService();

  List<MediaItem> _popularMovies = [];
  List<MediaItem> _popularTVShows = [];
  List<MediaItem> _searchResults = [];
  Map<String, dynamic> _currentDetail = {};
  bool _loading = false;
  String? _error;

  List<MediaItem> _watchlist = [];
  String? _userId;

  Map<int, String> _movieGenres = {};
  Map<int, String> _tvGenres = {};

  int? _selectedMovieGenre;
  int? _selectedTVGenre;

  // Rating
  double _tmdbRating = 0;
  int _tmdbVoteCount = 0;
  double _userRating = 0;
  int _userReviewCount = 0;

  // ==========================================
  // THÊM CONSTRUCTOR ĐỂ TỰ ĐỘNG BẮT USER ID
  // ==========================================
  MediaProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      setUserId(user?.uid);
    });
  }

  // Getters
  List<MediaItem> get popularMovies => _popularMovies;
  List<MediaItem> get popularTVShows => _popularTVShows;
  List<MediaItem> get searchResults => _searchResults;
  Map<String, dynamic> get currentDetail => _currentDetail;
  bool get loading => _loading;
  String? get error => _error;
  List<MediaItem> get watchlist => _watchlist;
  Map<int, String> get movieGenres => _movieGenres;
  Map<int, String> get tvGenres => _tvGenres;
  int? get selectedMovieGenre => _selectedMovieGenre;
  int? get selectedTVGenre => _selectedTVGenre;

  double get tmdbRating => _tmdbRating;
  int get tmdbVoteCount => _tmdbVoteCount;
  double get userRating => _userRating;
  int get userReviewCount => _userReviewCount;
  double get combinedRating => (_userReviewCount > 0)
      ? (_tmdbRating * _tmdbVoteCount + _userRating * _userReviewCount) / (_tmdbVoteCount + _userReviewCount)
      : _tmdbRating;

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
    _firestoreService.getWatchlist(userId).listen((items) {
      _watchlist = items;
      notifyListeners();
    });
  }

  Future<void> fetchGenres() async {
    _movieGenres = await _tmdbService.getMovieGenres();
    _tvGenres = await _tmdbService.getTVGenres();
    notifyListeners();
  }

  Future<void> fetchPopularMovies({int? genreId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _popularMovies = await _tmdbService.discoverMovies(withGenres: genreId);
      _selectedMovieGenre = genreId;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchPopularTVShows({int? genreId}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _popularTVShows = await _tmdbService.discoverTVShows(withGenres: genreId);
      _selectedTVGenre = genreId;
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> searchMulti(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _searchResults = await _tmdbService.searchMulti(query);
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchDetail(int id, String mediaType) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      if (mediaType == 'movie') {
        _currentDetail = await _tmdbService.getMovieDetails(id);
      } else {
        _currentDetail = await _tmdbService.getTVDetails(id);
      }
      final media = _currentDetail['media'] as MediaItem?;
      if (media != null) {
        _tmdbRating = media.voteAverage;
        _tmdbVoteCount = _currentDetail['voteCount'] ?? 0;
        _userRating = await _firestoreService.getAverageUserRating(id);
        final reviewsSnapshot = await FirebaseFirestore.instance
            .collection('reviews')
            .where('mediaId', isEqualTo: id)
            .get();
        _userReviewCount = reviewsSnapshot.docs.length;
      }
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> isInWatchlist(int mediaId) async {
    if (_userId == null) return false;
    return await _firestoreService.isInWatchlist(_userId!, mediaId);
  }

  Future<void> toggleWatchlist(MediaItem item) async {
    if (_userId == null) return;
    bool already = await isInWatchlist(item.id);
    if (already) {
      await _firestoreService.removeFromWatchlist(_userId!, item.id);
    } else {
      await _firestoreService.addToWatchlist(_userId!, item);
    }
    // Stream tự cập nhật UI do có hàm notifyListeners() trong _listenToWatchlist
  }
}