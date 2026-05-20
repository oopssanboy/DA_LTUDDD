import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import '../theme/app_theme.dart';
import 'detail_screen.dart';

class MoviesScreen extends StatefulWidget {
  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaProvider>(context, listen: false).fetchPopularMovies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    final movies = prov.popularMovies;
    final genres = prov.movieGenres;
    final selectedGenre = prov.selectedMovieGenre;

    return NeonBackground(
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: genres.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: const Text('Tất cả'),
                      selected: selectedGenre == null,
                      onSelected: (val) => prov.fetchPopularMovies(genreId: null),
                      selectedColor: AppTheme.neonPink,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      labelStyle: TextStyle(color: selectedGenre == null ? Colors.black : Colors.black),
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
                    onSelected: (val) => prov.fetchPopularMovies(genreId: genreId),
                    selectedColor: AppTheme.neonBlue,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    labelStyle: TextStyle(color: selectedGenre == genreId ? Colors.black : Colors.black),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.neonPink))
                : prov.error != null
                    ? Center(child: Text('Lỗi: ${prov.error}', style: const TextStyle(color: Colors.white)))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 16, mainAxisSpacing: 16,
                        ),
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          final item = movies[index];
                          return MediaCard(
                            item: item,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: item.id, mediaType: item.mediaType))),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}