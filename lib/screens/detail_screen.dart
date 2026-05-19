import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/media_provider.dart';
import '../models/media_item.dart';
import '../services/firestore_service.dart';
import 'trailer_screen.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String mediaType;
  DetailScreen({required this.id, required this.mediaType});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isInWatchlist = false;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reviewCtrl = TextEditingController();
  double _userRatingValue = 5.0;
  Map<String, dynamic>? _existingReview;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<MediaProvider>(context, listen: false);
      prov.fetchDetail(widget.id, widget.mediaType);
      _checkWatchlist();
      _loadUserReview();
    });
  }

  Future<void> _checkWatchlist() async {
    final prov = Provider.of<MediaProvider>(context, listen: false);
    bool inList = await prov.isInWatchlist(widget.id);
    if (mounted) setState(() => isInWatchlist = inList);
  }

  Future<void> _loadUserReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final review = await _firestoreService.getUserReview(user.uid, widget.id);
    if (mounted) {
      setState(() {
        _existingReview = review;
        if (review != null) {
          _userRatingValue = (review['rating'] as num).toDouble();
          _reviewCtrl.text = review['comment'] ?? '';
        }
      });
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firestoreService.submitReview(
      userId: user.uid,
      mediaId: widget.id,
      mediaType: widget.mediaType,
      rating: _userRatingValue,
      comment: _reviewCtrl.text.trim(),
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đánh giá đã được lưu!')));
    _loadUserReview();
    final prov = Provider.of<MediaProvider>(context, listen: false);
    prov.fetchDetail(widget.id, widget.mediaType);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    final detail = prov.currentDetail;
    final MediaItem? item = detail['media'];
    final String trailerKey = detail['trailerKey'] ?? '';
    final List<String> genres = (detail['genres'] as List?)?.cast<String>() ?? [];
    final int runtime = detail['runtime'] ?? 0;
    final String tagline = detail['tagline'] ?? '';
    final List cast = (detail['cast'] as List?) ?? [];
    final double combinedRating = prov.combinedRating;
    final int tmdbVotes = prov.tmdbVoteCount;
    final int userVotes = prov.userReviewCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết')),
      backgroundColor: const Color(0xFFf0f2f5),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.error != null
              ? Center(child: Text('Lỗi: ${prov.error}'))
              : item == null
                  ? const Center(child: Text('Không tìm thấy'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Poster
                          Center(
                            child: Container(
                              height: 300,
                              width: 200,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: item.posterUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                                if (tagline.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(tagline, style: const TextStyle(fontSize: 14, color: Colors.grey, fontStyle: FontStyle.italic)),
                                ],
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: genres.map((g) => Chip(
                                    label: Text(g, style: const TextStyle(fontSize: 12)),
                                    backgroundColor: const Color(0xFFd97706).withOpacity(0.1),
                                    labelStyle: const TextStyle(color: Color(0xFFd97706)),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                  )).toList(),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(combinedRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                    const SizedBox(width: 8),
                                    Text('(${tmdbVotes + userVotes} đánh giá)', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                    const Spacer(),
                                    if (trailerKey.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(Icons.play_circle_outline, size: 28, color: Color(0xFFd97706)),
                                        tooltip: 'Xem Trailer',
                                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrailerScreen(videoKey: trailerKey, title: item.title))),
                                      ),
                                    IconButton(
                                      icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border, size: 28, color: isInWatchlist ? const Color(0xFFd97706) : Colors.grey),
                                      tooltip: 'Watchlist',
                                      onPressed: () async {
                                        await prov.toggleWatchlist(item);
                                        bool inList = await prov.isInWatchlist(item.id);
                                        setState(() => isInWatchlist = inList);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer, size: 18, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('$runtime phút', style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(_formatDate(item.releaseDate), style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const Divider(height: 24),
                                const Text('Tóm tắt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(item.overview.isEmpty ? 'Chưa có mô tả' : item.overview, style: const TextStyle(height: 1.5, color: Color(0xFF555555))),
                                if (cast.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  const Text('Diễn viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: cast.length > 6 ? 6 : cast.length,
                                      itemBuilder: (context, index) {
                                        final actor = cast[index];
                                        final profile = actor['profile_path'];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundImage: profile != null ? NetworkImage('https://image.tmdb.org/t/p/w185$profile') : null,
                                                child: profile == null ? const Icon(Icons.person, size: 30, color: Colors.grey) : null,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(actor['name'] ?? '', style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
                                              Text(actor['character'] ?? '', style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Đánh giá của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(
                                  children: List.generate(5, (i) => IconButton(
                                    icon: Icon(i < _userRatingValue ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
                                    onPressed: () => setState(() => _userRatingValue = i + 1.0),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                                  )),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _reviewCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Viết bình luận...',
                                    border: OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Color(0xFFf5f5f5),
                                  ),
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _submitReview,
                                    child: Text(_existingReview != null ? 'Cập nhật đánh giá' : 'Gửi đánh giá'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          StreamBuilder<List<Map<String, dynamic>>>(
                            stream: _firestoreService.getReviews(widget.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();
                              final reviews = snapshot.data!;
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Bình luận', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 8),
                                    ...reviews.map((review) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              ...List.generate(5, (i) => Icon(
                                                i < (review['rating'] as num).toDouble() ? Icons.star : Icons.star_border,
                                                size: 16, color: Colors.amber,
                                              )),
                                              const SizedBox(width: 8),
                                              Text(review['userId'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                            ],
                                          ),
                                          if (review['comment'] != null && review['comment'].toString().isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Text(review['comment'], style: const TextStyle(fontSize: 14)),
                                            ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }
}