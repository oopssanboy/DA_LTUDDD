import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/movie_card.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Chỉ fetch lần đầu hoặc khi danh sách rỗng
    final movieProv = Provider.of<MovieProvider>(context, listen: false);
    if (!_hasFetched || movieProv.popularMovies.isEmpty) {
      _hasFetched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        movieProv.fetchPopularMovies();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieProv = Provider.of<MovieProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('MoveTime',
            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => SearchScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark, color: Colors.white),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => WatchlistScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await auth.signOut();
            },
          ),
        ],
      ),
      body: movieProv.loading
          ? const Center(child: CircularProgressIndicator())
          : movieProv.error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Lỗi: ${movieProv.error}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => movieProv.fetchPopularMovies(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => movieProv.fetchPopularMovies(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: movieProv.popularMovies.length,
                    itemBuilder: (context, index) {
                      final movie = movieProv.popularMovies[index];
                      return MovieCard(
                        movie: movie,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    DetailScreen(movieId: movie.id)),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}