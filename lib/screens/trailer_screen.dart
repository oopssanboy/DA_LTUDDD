import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TrailerScreen extends StatefulWidget {
  final String videoKey;
  final String title;
  TrailerScreen({required this.videoKey, required this.title});

  @override
  _TrailerScreenState createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoKey,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(controller: _controller, showVideoProgressIndicator: true),
          builder: (context, player) => player,
        ),
      ),
    );
  }
}