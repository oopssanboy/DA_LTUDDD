import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../widgets/media_card.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<MediaProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(hintText: 'Tìm kiếm phim hoặc TV show...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none),
          onSubmitted: (value) { if (value.isNotEmpty) prov.searchMulti(value); },
        ),
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.error != null
              ? Center(child: Text('Lỗi: ${prov.error}'))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  ),
                  itemCount: prov.searchResults.length,
                  itemBuilder: (context, index) {
                    final item = prov.searchResults[index];
                    return MediaCard(
                      item: item,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: item.id, mediaType: item.mediaType))),
                    );
                  },
                ),
    );
  }
}