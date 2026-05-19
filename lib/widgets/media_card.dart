import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  const MediaCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: item.posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFf39c12), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        item.voteAverage.toStringAsFixed(1),
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        item.mediaType == 'movie' ? 'Phim' : 'TV',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}