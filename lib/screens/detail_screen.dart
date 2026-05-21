import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/media_provider.dart';
import '../models/media_item.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
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
  ReviewModel? _existingReview; 

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
          _userRatingValue = review.rating;
          _reviewCtrl.text = review.comment;
        }
      });
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    var userProfile = await _firestoreService.getUserProfile(user.uid);
    String userName = (userProfile != null && userProfile.displayName.isNotEmpty) 
        ? userProfile.displayName 
        : (user.email?.split('@')[0] ?? 'Ẩn danh');
    
    String userAvatar = userProfile?.avatarUrl ?? '';
    if (userAvatar.isEmpty || !userAvatar.startsWith('http')) {
      userAvatar = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=random';
    }

    await _firestoreService.submitReview(
      userId: user.uid,
      userName: userName,
      userAvatar: userAvatar,
      mediaId: widget.id,
      mediaType: widget.mediaType,
      rating: _userRatingValue,
      comment: _reviewCtrl.text.trim(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đánh giá đã được lưu!')));
    _loadUserReview();
    final prov = Provider.of<MediaProvider>(context, listen: false);
    prov.fetchDetail(widget.id, widget.mediaType);
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  // KHÔI PHỤC HÀM XÓA CỦA BẠN
  Future<void> _deleteReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgColor,
        title: const Text('Xóa đánh giá?', style: TextStyle(color: Colors.white)),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy', style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      )
    ) ?? false;

    if (confirm) {
      await _firestoreService.deleteReview(user.uid, widget.id);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa đánh giá!')));
      setState(() {
        _existingReview = null;
        _reviewCtrl.clear();
        _userRatingValue = 5.0;
      });
      _loadUserReview();
      final prov = Provider.of<MediaProvider>(context, listen: false);
      prov.fetchDetail(widget.id, widget.mediaType);
    }
  }

  void _showReviewModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: GlassContainer(
            borderRadius: 30,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đánh giá của bạn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) => IconButton(
                        icon: Icon(i < _userRatingValue ? Icons.star : Icons.star_border, color: Colors.amber, size: 40),
                        onPressed: () {
                          setStateSB(() => _userRatingValue = i + 1.0);
                          setState(() => _userRatingValue = i + 1.0);
                        },
                      )),
                    );
                  }
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reviewCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cảm nhận của bạn về phim...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _submitReview,
                    child: Text(_existingReview != null ? 'Cập nhật đánh giá' : 'Gửi đánh giá', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Chi tiết', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: NeonBackground(
        child: prov.loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.neonPink))
            : prov.error != null
                ? Center(child: Text('Lỗi: ${prov.error}', style: const TextStyle(color: Colors.white)))
                : item == null
                    ? const Center(child: Text('Không tìm thấy', style: TextStyle(color: Colors.white)))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  height: 280,
                                  width: double.infinity,
                                  child: ShaderMask(
                                    shaderCallback: (rect) {
                                      return const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.black, Colors.transparent],
                                      ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                                    },
                                    blendMode: BlendMode.dstIn,
                                    child: CachedNetworkImage(
                                      imageUrl: item.backdropPath.isNotEmpty && !item.backdropPath.startsWith('http')
                                          ? 'https://image.tmdb.org/t/p/w780${item.backdropPath}'
                                          : (item.backdropPath.isNotEmpty ? item.backdropPath : item.posterUrl),
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: Colors.black26),
                                      errorWidget: (_, __, ___) => const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 140,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      height: 240,
                                      width: 160,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.neonBlue.withOpacity(0.4),
                                            blurRadius: 25,
                                            spreadRadius: 2,
                                          )
                                        ],
                                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: CachedNetworkImage(
                                          imageUrl: item.posterUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 110),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: GlassContainer(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                                    if (tagline.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(tagline, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), fontStyle: FontStyle.italic)),
                                    ],
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8, runSpacing: 8,
                                      children: genres.map((g) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.neonPink.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: AppTheme.neonPink.withOpacity(0.4))
                                        ),
                                        child: Text(g, style: const TextStyle(fontSize: 12, color: Colors.white)),
                                      )).toList(),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 24),
                                        const SizedBox(width: 4),
                                        Text(combinedRating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                        const SizedBox(width: 8),
                                        Text('(${tmdbVotes + userVotes} đánh giá)', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                        const Spacer(),
                                        if (trailerKey.isNotEmpty)
                                          IconButton(
                                            icon: const Icon(Icons.play_circle_fill, size: 36, color: AppTheme.neonBlue),
                                            tooltip: 'Xem Trailer',
                                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TrailerScreen(videoKey: trailerKey, title: item.title))),
                                          ),
                                        IconButton(
                                          icon: Icon(isInWatchlist ? Icons.bookmark : Icons.bookmark_border, size: 32, color: isInWatchlist ? AppTheme.neonPink : Colors.white),
                                          tooltip: 'Watchlist',
                                          onPressed: () async {
                                            await prov.toggleWatchlist(item);
                                            bool inList = await prov.isInWatchlist(item.id);
                                            setState(() => isInWatchlist = inList);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(Icons.timer, size: 18, color: Colors.white54),
                                        const SizedBox(width: 4),
                                        Text('$runtime phút', style: const TextStyle(fontSize: 14, color: Colors.white)),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.calendar_today, size: 18, color: Colors.white54),
                                        const SizedBox(width: 4),
                                        Text(_formatDate(item.releaseDate), style: const TextStyle(fontSize: 14, color: Colors.white)),
                                      ],
                                    ),
                                    const Divider(height: 32, color: Colors.white24),
                                    const Text('Tóm tắt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                    const SizedBox(height: 8),
                                    Text(item.overview.isEmpty ? 'Chưa có mô tả' : item.overview, style: TextStyle(height: 1.5, color: Colors.white.withOpacity(0.8))),
                                    
                                    if (cast.isNotEmpty) ...[
                                      const SizedBox(height: 20),
                                      const Text('Diễn viên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 110,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: cast.length > 6 ? 6 : cast.length,
                                          itemBuilder: (context, index) {
                                            final actor = cast[index];
                                            final profile = actor['profile_path'];
                                            return Padding(
                                              padding: const EdgeInsets.only(right: 14),
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 32,
                                                    backgroundColor: Colors.white12,
                                                    backgroundImage: profile != null ? NetworkImage('https://image.tmdb.org/t/p/w185$profile') : null,
                                                    child: profile == null ? const Icon(Icons.person, size: 30, color: Colors.white) : null,
                                                  ),
                                                  const SizedBox(height: 6),
                                                  SizedBox(
                                                    width: 70,
                                                    child: Text(actor['name'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.white), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                                  ),
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
                            ),
                            const SizedBox(height: 24),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Đánh giá cộng đồng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                                  Row(
                                    children: [
                                      // NÚT XÓA BÌNH LUẬN ĐÃ ĐƯỢC KHÔI PHỤC
                                      if (_existingReview != null)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                          tooltip: "Xóa đánh giá",
                                          onPressed: _deleteReview,
                                        ),
                                      ElevatedButton.icon(
                                        icon: Icon(_existingReview != null ? Icons.edit : Icons.add_comment, size: 16, color: Colors.white),
                                        label: Text(_existingReview != null ? "Sửa" : "Viết", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.neonPink,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        ),
                                        onPressed: _showReviewModal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: StreamBuilder<List<ReviewModel>>(
                                stream: _firestoreService.getReviews(widget.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue));
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return const Text('Chưa có đánh giá nào. Hãy là người đầu tiên!', style: TextStyle(color: Colors.white54));
                                  }

                                  final reviews = snapshot.data!;

                                  int totalLocalReviews = reviews.length;
                                  List<int> starCounts = [0, 0, 0, 0, 0]; 
                                  double sumRating = 0;

                                  for (var r in reviews) {
                                    double rVal = r.rating;
                                    sumRating += rVal;
                                    int starIdx = rVal.round().clamp(1, 5) - 1;
                                    starCounts[starIdx]++;
                                  }
                                  double avgLocalRating = totalLocalReviews > 0 ? (sumRating / totalLocalReviews) : 0.0;

                                  return Column(
                                    children: [
                                      GlassContainer(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Text(avgLocalRating.toStringAsFixed(1), style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                                                const SizedBox(height: 4),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: List.generate(5, (index) => Icon(
                                                    index < avgLocalRating.round() ? Icons.star : Icons.star_border,
                                                    color: Colors.amber,
                                                    size: 14,
                                                  )),
                                                ),
                                                const SizedBox(height: 4),
                                                Text('$totalLocalReviews bài viết', style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                              ],
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              child: Column(
                                                children: List.generate(5, (index) {
                                                  int starLevel = 5 - index; // Đảo chiều hiển thị: 5, 4, 3, 2, 1
                                                  double percent = totalLocalReviews > 0 ? (starCounts[starLevel - 1] / totalLocalReviews) : 0;
                                                  return Padding(
                                                    padding: const EdgeInsets.only(bottom: 6.0),
                                                    child: Row(
                                                      children: [
                                                        Text('$starLevel', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                                                        const SizedBox(width: 2),
                                                        const Icon(Icons.star, color: Colors.white54, size: 10),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: ClipRRect(
                                                            borderRadius: BorderRadius.circular(4),
                                                            child: LinearProgressIndicator(
                                                              value: percent,
                                                              backgroundColor: Colors.white12,
                                                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonPink),
                                                              minHeight: 5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      ...reviews.map((review) {
                                        String displayName = review.userName.isNotEmpty ? review.userName : 'Người dùng';
                                        String displayAvatar = review.userAvatar;
                                        
                                        if (displayAvatar.isEmpty || !displayAvatar.startsWith('http')) {
                                          displayAvatar = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(displayName)}&background=random';
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: GlassContainer(
                                            color: Colors.white.withOpacity(0.02),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: 40, height: 40,
                                                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white12),
                                                  child: ClipOval(
                                                    child: CachedNetworkImage(
                                                      imageUrl: displayAvatar, fit: BoxFit.cover,
                                                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                                      errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.white70),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(child: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15), overflow: TextOverflow.ellipsis)),
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.star, color: Colors.amber, size: 14),
                                                              const SizedBox(width: 4),
                                                              Text((review.rating).toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      const SizedBox(height: 6),
                                                      if (review.comment.isNotEmpty)
                                                        Text(review.comment, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8), height: 1.4)),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ],
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
      ),
    );
  }
}