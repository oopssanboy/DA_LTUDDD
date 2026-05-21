class MediaItem {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final String releaseDate;
  final List<int> genreIds;
  final double popularity;
  final String mediaType; 

  MediaItem({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.releaseDate,
    required this.genreIds,
    required this.popularity,
    required this.mediaType,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json, {required String mediaType}) {
  return MediaItem(
    id: json['id'] ?? 0,
    title: json['title'] ?? json['name'] ?? '',
    overview: json['overview'] ?? '',
    posterPath: json['poster_path'] ?? json['posterPath'] ?? '',
    backdropPath: json['backdrop_path'] ?? json['backdropPath'] ?? '',
    voteAverage: (json['vote_average'] ?? json['voteAverage'] ?? 0).toDouble(),
    releaseDate: json['release_date'] ?? json['releaseDate'] ?? json['first_air_date'] ?? '',
    genreIds: List<int>.from(json['genre_ids'] ?? json['genreIds'] ?? []),
    popularity: (json['popularity'] ?? 0).toDouble(),
    mediaType: json['mediaType'] ?? mediaType,
  );
}

  String get posterUrl {
    if (posterPath.isEmpty || posterPath == 'N/A') {
      return 'https://via.placeholder.com/500x750?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w500$posterPath';
  }

  String get backdropUrl {
    if (backdropPath.isEmpty || backdropPath == 'N/A') {
      return 'https://via.placeholder.com/780x400?text=No+Image';
    }
    return 'https://image.tmdb.org/t/p/w780$backdropPath';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'genreIds': genreIds,
      'popularity': popularity,
      'mediaType': mediaType,
    };
  }
}