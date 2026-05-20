class VsMovie {
  final int id;
  final String name;
  final String originName;
  final String slug;
  final String content;
  final String type;
  final String status;
  final String posterUrl;
  final String thumbUrl;
  final String trailerUrl;  // có thể null trong JSON nhưng sẽ thành ''
  final String time;
  final String episodeCurrent;
  final String episodeTotal;
  final String quality;
  final String lang;
  final int year;
  final List<String> actor;
  final List<String> director;
  final List<Map<String, dynamic>> category;
  final List<Map<String, dynamic>> country;
  final String? linkEmbed;
  final double voteAverage;
  final int voteCount;

  VsMovie({
    required this.id,
    required this.name,
    required this.originName,
    required this.slug,
    required this.content,
    required this.type,
    required this.status,
    required this.posterUrl,
    required this.thumbUrl,
    required this.trailerUrl,
    required this.time,
    required this.episodeCurrent,
    required this.episodeTotal,
    required this.quality,
    required this.lang,
    required this.year,
    required this.actor,
    required this.director,
    required this.category,
    required this.country,
    this.linkEmbed,
    required this.voteAverage,
    required this.voteCount,
  });

  factory VsMovie.fromJson(Map<String, dynamic> json) {
    // Parse link_embed
    String? linkEmbed;
    
    // In JSON để debug
    print('🔍 Parsing detail for: ${json['name']}');
    print('📦 episodes-----: ${json['link_embed']}');
    
    final episodes = json['episodes'] as List<dynamic>?;
    print('📦 episodes11111: $episodes');
    if (episodes != null && episodes.isNotEmpty) {
      final firstEpisode = episodes[0] as Map<String, dynamic>?;
      if (firstEpisode != null) {
        final serverData = firstEpisode['server_data'] as List<dynamic>?;
        if (serverData != null && serverData.isNotEmpty) {
          // Lấy phần tử đầu tiên trong server_data
          final firstServer = serverData[0];
          if (firstServer is Map<String, dynamic>) {
            linkEmbed = firstServer['link_embed']?.toString();
                print('📦 episodes-----1111: $linkEmbed');

          }
        }
      }
    }
    
    // Nếu không có, thử lấy trực tiếp từ json['link_embed'] (phòng hờ)
    if (linkEmbed == null || linkEmbed!.isEmpty) {
      linkEmbed = json['link_embed']?.toString();
    }
    
    // Chuẩn hóa
    if (linkEmbed != null && linkEmbed!.trim().isEmpty) {
      linkEmbed = null;
    }

    print('🔗 Final linkEmbed: $linkEmbed');

    // Helper parse list
    List<String> parseStringList(dynamic data) {
      if (data is List) return data.map((e) => e.toString()).toList();
      return [];
    }
    List<Map<String, dynamic>> parseMapList(dynamic data) {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    }

    return VsMovie(
      id: json['_id'] ?? 0,
      name: json['name'] ?? '',
      originName: json['origin_name'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      posterUrl: json['poster_url'] ?? '',
      thumbUrl: json['thumb_url'] ?? '',
      trailerUrl: json['trailer_url'] ?? '',
      time: json['time'] ?? '',
      episodeCurrent: json['episode_current'] ?? '',
      episodeTotal: json['episode_total'] ?? '',
      quality: json['quality'] ?? '',
      lang: json['lang'] ?? '',
      year: (json['year'] is int) ? json['year'] : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
      actor: parseStringList(json['actor']),
      director: parseStringList(json['director']),
      category: parseMapList(json['category']),
      country: parseMapList(json['country']),
      linkEmbed: linkEmbed,
      voteAverage: double.tryParse(json['tmdb']?['vote_average']?.toString() ?? '0') ?? 0.0,
      voteCount: json['tmdb']?['vote_count'] ?? 0,
    );
  }

  String get trailerVideoId {
    if (trailerUrl.isEmpty) return '';
    final uri = Uri.tryParse(trailerUrl);
    if (uri == null) return '';
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'] ?? '';
    }
    if (uri.host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    }
    return '';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'poster_url': posterUrl,
      'thumb_url': thumbUrl,
      'quality': quality,
      'year': year,
      'time': time,
      'lang': lang,
      'type': type,
      'status': status,
    };
  }
}