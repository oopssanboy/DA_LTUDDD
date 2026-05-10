import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class OMDBApiService {
  static const String _baseUrl = 'http://www.omdbapi.com/';
  static const String _apiKey = '33485ac5'; // Thay bằng key mới nếu cần

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?s=$query&apikey=$_apiKey'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        final List results = data['Search'];
        List<Movie> movies = [];
        for (var item in results) {
          try {
            final detail = await getMovieDetails(item['imdbID']);
            movies.add(detail['movie']);
          } catch (e) {
            movies.add(Movie(
              id: int.tryParse(item['imdbID'].replaceAll('tt', '')) ?? 0,
              title: item['Title'] ?? '',
              overview: '',
              posterPath: item['Poster'] ?? '',
              backdropPath: '',
              voteAverage: 0,
              releaseDate: item['Year'] ?? '',
              genreIds: [],
              popularity: 0,
            ));
          }
        }
        return movies;
      } else {
        throw Exception(data['Error'] ?? 'No results found');
      }
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getMovieDetails(String imdbID) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?i=$imdbID&apikey=$_apiKey&plot=full'),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['Response'] == 'True') {
        final movie = Movie(
          id: int.tryParse(data['imdbID'].replaceAll('tt', '')) ?? 0,
          title: data['Title'] ?? '',
          overview: data['Plot'] ?? '',
          posterPath: data['Poster'] ?? '',
          backdropPath: '',
          voteAverage: double.tryParse(data['imdbRating'] ?? '0') ?? 0,
          releaseDate: data['Released'] ?? '',
          genreIds: [],
          popularity: 0,
        );
        return {
          'movie': movie,
          'trailerKey': '',
        };
      } else {
        throw Exception(data['Error'] ?? 'Movie not found');
      }
    } else {
      throw Exception('Network error: ${response.statusCode}');
    }
  }
}