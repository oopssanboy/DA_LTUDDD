import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/movie_provider.dart';
import '../models/movie.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;
  DetailScreen({required this.movieId});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isInWatchlist = false;
  String _formatDate(String dateStr) {
  if (dateStr.isEmpty) return 'N/A';
  try {
    // OMDb thường dùng định dạng "DD Mon YYYY"
    final date = DateFormat('dd MMM yyyy').parse(dateStr);
    return DateFormat('dd/MM/yyyy').format(date);
  } catch (e) {
    // Nếu không parse được, trả về chuỗi gốc
    return dateStr;
  }
}

  @override
  void initState() {
    super.initState();
    // Đợi build xong rồi mới fetch để tránh lỗi setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final movieProv = Provider.of<MovieProvider>(context, listen: false);
      movieProv.fetchMovieDetail(widget.movieId);
      _checkWatchlist();
    });
  }

  Future<void> _checkWatchlist() async {
    final movieProv = Provider.of<MovieProvider>(context, listen: false);
    bool inList = await movieProv.isMovieInWatchlist(widget.movieId);
    if (mounted) {
      setState(() {
        isInWatchlist = inList;
      });
    }
  }

  Future<void> _launchYouTube(String videoId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở trình duyệt')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProv = Provider.of<MovieProvider>(context);
    final bool isLoading = movieProv.loading;
    final String? error = movieProv.error;
    final detail = movieProv.currentMovieDetail;
    Movie? movie = detail['movie'];
    String trailerKey = detail['trailerKey'] ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lỗi: $error',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          movieProv.fetchMovieDetail(widget.movieId);
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : movie == null
                  ? const Center(
                      child: Text('Không tìm thấy phim',
                          style: TextStyle(color: Colors.white)))
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 400,
                          pinned: true,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Image.network(
                              movie.posterUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[900]),
                            ),
                          ),
                          leading: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(movie.title,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    Text(
                                        ' ${movie.voteAverage.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                            color: Colors.white70)),
                                    const SizedBox(width: 20),
                                    const Icon(Icons.calendar_today,
                                        color: Colors.grey, size: 16),
                                    Text(' ${_formatDate(movie.releaseDate)}',
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text('Tóm tắt',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white)),
                                const SizedBox(height: 8),
                                Text(
                                    movie.overview.isEmpty
                                        ? 'Chưa có mô tả'
                                        : movie.overview,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        height: 1.5)),
                                const SizedBox(height: 20),
                                if (trailerKey.isNotEmpty)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                      ),
                                      icon: const Icon(Icons.play_circle,
                                          color: Colors.white),
                                      label: const Text('Xem Trailer',
                                          style:
                                              TextStyle(fontSize: 16)),
                                      onPressed: () =>
                                          _launchYouTube(trailerKey),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isInWatchlist
                                          ? Colors.grey
                                          : Colors.red,
                                      padding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12),
                                    ),
                                    icon: Icon(
                                        isInWatchlist
                                            ? Icons.bookmark_remove
                                            : Icons.bookmark_add,
                                        color: Colors.white),
                                    label: Text(
                                        isInWatchlist
                                            ? 'Xóa khỏi Watchlist'
                                            : 'Thêm vào Watchlist',
                                        style: const TextStyle(
                                            fontSize: 16)),
                                    onPressed: () async {
                                      await movieProv.toggleWatchlist(movie);
                                      bool currently =
                                          await movieProv.isMovieInWatchlist(
                                              movie.id);
                                      setState(() {
                                        isInWatchlist = currently;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}