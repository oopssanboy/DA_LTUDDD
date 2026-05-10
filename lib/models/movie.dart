class Movie {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final double popularity;

  Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    required this.popularity,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      backdropPath: json['backdrop_path'] ?? '',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
      popularity: (json['popularity'] ?? 0).toDouble(),
    );
  }

  String get posterUrl {
  if (posterPath.isEmpty || posterPath == 'N/A') {
    return 'https://via.placeholder.com/500x750?text=No+Image';
  }
  // OMDb thường trả về URL đầy đủ (VD: https://m.media-amazon.com/...)
  if (posterPath.startsWith('http')) {
    return posterPath;
  }
  // Dự phòng nếu là path TMDB cũ
  return 'https://image.tmdb.org/t/p/w500$posterPath';
}
  String get backdropUrl {
  if (backdropPath.isEmpty || backdropPath == 'N/A') {
    return 'https://via.placeholder.com/780x400?text=No+Image';
  }
  if (backdropPath.startsWith('http')) {
    return backdropPath;
  }
  return 'https://image.tmdb.org/t/p/w780$backdropPath';
}
}