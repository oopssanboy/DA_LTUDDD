import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class TVsScreen extends StatefulWidget {
  @override
  _TVsScreenState createState() => _TVsScreenState();
}

class _TVsScreenState extends State<TVsScreen> {
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
    final genres = prov.tvGenres;
    final selectedGenre = prov.selectedTVGenre;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            itemCount: genres.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: selectedGenre == null,
                    onSelected: (val) => prov.fetchPopularTVShows(genreId: null),
                    selectedColor: const Color(0xFFd97706).withOpacity(0.2),
                    labelStyle: TextStyle(color: selectedGenre == null ? const Color(0xFFd97706) : Colors.black),
                  ),
                );
              }
              final genreId = genres.keys.elementAt(index - 1);
              final genreName = genres[genreId] ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(genreName),
                  selected: selectedGenre == genreId,
                  onSelected: (val) => prov.fetchPopularTVShows(genreId: genreId),
                  selectedColor: const Color(0xFFd97706).withOpacity(0.2),
                  labelStyle: TextStyle(color: selectedGenre == genreId ? const Color(0xFFd97706) : Colors.black),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: prov.loading
              ? const Center(child: CircularProgressIndicator())
              : prov.error != null
                  ? Center(child: Text('Lỗi: ${prov.error}'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12,
                      ),
                      itemCount: tvs.length,
                      itemBuilder: (context, index) {
                        final item = tvs[index];
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