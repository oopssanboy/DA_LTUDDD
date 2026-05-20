import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class TvsScreen extends StatefulWidget {
  @override
  _TvsScreenState createState() => _TvsScreenState();
}

class _TvsScreenState extends State<TvsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaProvider>(context, listen: false).fetchPopularTVShows();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    final tvs = prov.popularTVShows;

    return prov.loading
        ? const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue))
        : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
            ),
            itemCount: tvs.length,
            itemBuilder: (context, index) {
              final item = tvs[index];
              return MediaCard(
                item: item,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: item.id, mediaType: 'tv'))),
              );
            },
          );
  }
}