import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/providers/anime_provider.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class WatchPage extends StatefulWidget {
  const WatchPage({
    super.key,
    required this.anime,
    required this.id,
    required this.episode,
    required this.provider,
  });
  final Anime anime;
  final String id;
  final int episode;
  final AnimeProvider provider;

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  late final VideoController controller;
  late final Player player;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    widget.provider.play(widget.id, widget.episode).then((stream) {
      if (kDebugMode) {
        print(stream!.url);
      }
      player.open(Media(stream!.url));
    });
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Video(
            controller: controller,
          ),
          IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left))
        ],
      ),
    );
  }
}
