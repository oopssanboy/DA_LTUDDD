import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TMDBApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  // Thay bằng API Key của bạn
  static const String _apiKey = 'YOUR_TMDB_API_KEY';

  Future<List<Movie>> getPopularMovies() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&language=vi-VN&page=1'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&language=vi-VN&query=$query&page=1'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search movies');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(int movieId) async {
    // Lấy thông tin chi tiết và danh sách trailer
    final detailRes = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey&language=vi-VN'),
    );
    final videoRes = await http.get(
      Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US'),
    );
    if (detailRes.statusCode == 200 && videoRes.statusCode == 200) {
      final detailData = json.decode(detailRes.body);
      final videoData = json.decode(videoRes.body);
      // Lấy key trailer YouTube đầu tiên
      String trailerKey = '';
      if (videoData['results'].isNotEmpty) {
        trailerKey = videoData['results'][0]['key'] ?? '';
      }
      return {
        'movie': Movie.fromJson(detailData),
        'trailerKey': trailerKey,
      };
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}