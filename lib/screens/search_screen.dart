import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    final results = prov.searchResults;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassContainer(
            borderRadius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Tìm phim, diễn viên...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white70),
              ),
              onChanged: (val) => prov.searchMulti(val),
            ),
          ),
        ),
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.neonBlue))
              : results.isEmpty
                  ? const Center(child: Text('Khám phá những bộ phim hay', style: TextStyle(color: Colors.white54)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
                      ),
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final item = results[index];
                        return MediaCard(
                          item: item,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: item.id, mediaType: item.mediaType))),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}