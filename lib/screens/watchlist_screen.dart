import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class WatchlistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    final watchlist = prov.watchlist;
    return watchlist.isEmpty
        ? const Center(child: Text('Danh sách theo dõi trống'))
        : GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: watchlist.length,
            itemBuilder: (context, index) {
              final item = watchlist[index];
              return MediaCard(
                item: item,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: item.id, mediaType: item.mediaType))),
              );
            },
          );
  }
}