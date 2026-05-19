import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/media_item.dart';

class TMDBApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = '84441b9e8c4183d8b3bcfe738f14b53b';

  // --- Danh sách phim / TV phổ biến ---
  Future<List<MediaItem>> getPopularMovies({int page = 1}) async {
    return _fetchList('movie/popular', 'movie', page: page);
  }
  Future<List<MediaItem>> getPopularTVShows({int page = 1}) async {
    return _fetchList('tv/popular', 'tv', page: page);
  }

  // --- Khám phá với bộ lọc ---
  Future<List<MediaItem>> discoverMovies({
    int? withGenres,
    int page = 1,
  }) async {
    Map<String, String> query = {'page': page.toString()};
    if (withGenres != null) query['with_genres'] = withGenres.toString();
    return _fetchList('discover/movie', 'movie', queryParams: query);
  }

  Future<List<MediaItem>> discoverTVShows({
    int? withGenres,
    int page = 1,
  }) async {
    Map<String, String> query = {'page': page.toString()};
    if (withGenres != null) query['with_genres'] = withGenres.toString();
    return _fetchList('discover/tv', 'tv', queryParams: query);
  }

  // --- Tìm kiếm ---
  Future<List<MediaItem>> searchMulti(String query, {int page = 1}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&language=vi-VN&query=$query&page=$page'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results
          .where((item) => item['media_type'] == 'movie' || item['media_type'] == 'tv')
          .map((item) => MediaItem.fromJson(item, mediaType: item['media_type']))
          .toList();
    } else {
      throw Exception('Failed to search');
    }
  }

  // --- Credits (cast) ---
  Future<List<Map<String, dynamic>>> getCredits(int id, String mediaType) async {
    final endpoint = mediaType == 'movie' ? 'movie/$id/credits' : 'tv/$id/credits';
    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint?api_key=$_apiKey&language=vi-VN'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List cast = data['cast'] ?? [];
      return cast.map((c) => {
        'name': c['name'] ?? '',
        'character': c['character'] ?? '',
        'profile_path': c['profile_path'] ?? '',
      }).toList();
    }
    return [];
  }

  // --- Chi tiết phim ---
  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    final detailRes = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=vi-VN'),
    );
    final videoRes = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey'),
    );
    final credits = await getCredits(movieId, 'movie');
    if (detailRes.statusCode == 200) {
      final data = json.decode(detailRes.body);
      String trailerKey = '';
      if (videoRes.statusCode == 200) {
        final vData = json.decode(videoRes.body);
        if (vData['results'].isNotEmpty) trailerKey = vData['results'][0]['key'] ?? '';
      }
      return {
        'media': MediaItem.fromJson(data, mediaType: 'movie'),
        'trailerKey': trailerKey,
        'runtime': data['runtime'] ?? 0,
        'genres': (data['genres'] as List?)?.map((g) => g['name']).toList() ?? [],
        'tagline': data['tagline'] ?? '',
        'cast': credits,
        'voteCount': data['vote_count'] ?? 0,
      };
    }
    throw Exception('Failed to load movie details');
  }

  // --- Chi tiết TV ---
  Future<Map<String, dynamic>> getTVDetails(int tvId) async {
    final detailRes = await http.get(
      Uri.parse('$_baseUrl/tv/$tvId?api_key=$_apiKey&language=vi-VN'),
    );
    final videoRes = await http.get(
      Uri.parse('$_baseUrl/tv/$tvId/videos?api_key=$_apiKey'),
    );
    final credits = await getCredits(tvId, 'tv');
    if (detailRes.statusCode == 200) {
      final data = json.decode(detailRes.body);
      String trailerKey = '';
      if (videoRes.statusCode == 200) {
        final vData = json.decode(videoRes.body);
        if (vData['results'].isNotEmpty) trailerKey = vData['results'][0]['key'] ?? '';
      }
      return {
        'media': MediaItem.fromJson(data, mediaType: 'tv'),
        'trailerKey': trailerKey,
        'runtime': (data['episode_run_time'] is List && (data['episode_run_time'] as List).isNotEmpty)
            ? data['episode_run_time'][0] : 0,
        'genres': (data['genres'] as List?)?.map((g) => g['name']).toList() ?? [],
        'tagline': data['tagline'] ?? '',
        'cast': credits,
        'voteCount': data['vote_count'] ?? 0,
      };
    }
    throw Exception('Failed to load TV details');
  }

  // --- Genres ---
  Future<Map<int, String>> getMovieGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=vi-VN'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<int, String> genres = {};
      for (var g in data['genres']) { genres[g['id']] = g['name']; }
      return genres;
    }
    return {};
  }

  Future<Map<int, String>> getTVGenres() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/genre/tv/list?api_key=$_apiKey&language=vi-VN'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<int, String> genres = {};
      for (var g in data['genres']) { genres[g['id']] = g['name']; }
      return genres;
    }
    return {};
  }

  // --- Helper ---
  Future<List<MediaItem>> _fetchList(
    String endpoint,
    String mediaType, {
    Map<String, String>? queryParams,
    int page = 1,
  }) async {
    Map<String, String> query = {
      'api_key': _apiKey,
      'language': 'vi-VN',
      'page': page.toString(),
    };
    if (queryParams != null) query.addAll(queryParams);
    final uri = Uri.parse('$_baseUrl/$endpoint').replace(queryParameters: query);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((item) => MediaItem.fromJson(item, mediaType: mediaType)).toList();
    } else {
      throw Exception('Failed to load $endpoint');
    }
  }
}