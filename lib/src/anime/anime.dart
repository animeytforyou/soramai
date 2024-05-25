import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/api/anilist.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/classes/custom_navbar_controller.dart';
import 'package:soramai/src/anime/anime_details.dart';
import 'package:soramai/src/anime/episodes.dart';
import 'package:soramai/widgets/anime_cover.dart';
import 'package:soramai/widgets/nav_bar.dart';

class AnimeDetailsPage extends StatefulWidget {
  const AnimeDetailsPage({super.key, required this.animeRes});
  final AnimeSearchResult animeRes;

  static const routeName = "/anime";

  @override
  State<AnimeDetailsPage> createState() => _AnimeDetailsPageState();
}

class _AnimeDetailsPageState extends State<AnimeDetailsPage> {
  CustomNavBarController navBarController =
      CustomNavBarController(screenCount: 2);
  int page = 0;
  Color _hexToColor(String hexColor) {
    if (hexColor == "") {
      return const Color(0xffcdcdcd);
    }
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.substring(1);
    }
    int colorValue = int.parse(hexColor, radix: 16);
    return Color(colorValue).withOpacity(1.0);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AniList().details(widget.animeRes.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final anime = snapshot.data as Anime;
          final ambientColor = _hexToColor(anime.cover.color);
          return Scaffold(
            bottomNavigationBar: CustomBottomNavBar(
              anime: anime,
              navBarController: navBarController,
              animeRes: widget.animeRes,
            ),
            body: CustomScrollView(
              slivers: [
                //App Bar
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  surfaceTintColor: ambientColor,
                  // Title
                  flexibleSpace: FlexibleSpaceBar(
                    title: GestureDetector(
                      onLongPress: () async {
                        await Clipboard.setData(
                          ClipboardData(text: anime.title.romaji),
                        );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),
                        ));
                      },
                      child: Text(
                        anime.title.romaji,
                      ),
                    ),
                    // Anime Banner
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: widget.animeRes.banner,
                            fit: BoxFit.cover,
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    Skeletonizer(
                              child: Bone.button(
                                width: MediaQuery.of(context).size.width,
                                height: 200,
                              ),
                            ),
                            errorWidget: (context, url, error) => Skeletonizer(
                              child: Bone.button(
                                  width: MediaQuery.of(context).size.width - 32,
                                  height:
                                      (MediaQuery.of(context).size.width - 32) /
                                          1.7),
                            ),
                          ),
                        ),
                        // Fade Out
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  const Color(0xff1e1e23),
                                  ambientColor.withOpacity(.05),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Ambiant Color Fade
                SliverToBoxAdapter(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ambientColor,
                          spreadRadius: 15,
                          blurRadius: 500,
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 10,
                    ),
                  ),
                ),
                // Anime Heading Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        AnimeCoverWidget(
                          anime: anime,
                          coverVisible: true,
                          ambiantColor: ambientColor,
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                        anime.type == AnimeType.Anime
                                            ? Icons.tv
                                            : Icons.book,
                                        size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      anime.type == AnimeType.Anime
                                          ? "${anime.episodeCount}"
                                          : "${anime.volumes} vol, ${anime.chapters} ch",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                if (anime.status == AnimeStatus.Releasing)
                                  Row(
                                    children: [
                                      const Icon(Icons.timer, size: 18),
                                      const SizedBox(width: 5),
                                      StreamBuilder(
                                        stream: anime.nextEpisode?.durationLeft,
                                        builder:
                                            (context, nextReleaseDuration) {
                                          if (nextReleaseDuration.hasError ||
                                              nextReleaseDuration
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                            return const Text(
                                              "Next Episode In: Unknown",
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            );
                                          }
                                          final duration =
                                              nextReleaseDuration.data!;
                                          final days = duration.inDays;
                                          final hours = (duration.inHours % 24);
                                          final minutes =
                                              (duration.inMinutes % 60);
                                          final seconds =
                                              (duration.inSeconds % 60);
                                          return Text(
                                            "Episode ${anime.nextEpisode!.episode} Releasing in: \n$days days, $hours hrs, $minutes mins, $seconds secs",
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    const Icon(Icons.timer, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      "${anime.episodeDuration.inMinutes} min",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.source, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      anime.source.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.info, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      anime.status.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: navBarController.currentScreenStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data! == 1) {
                        return EpisodesPage(
                          anime: anime,
                          ambientColor: ambientColor,
                        );
                      }
                    }
                    return AnimeDetailsWidget(
                      anime: anime,
                      ambiantColor: ambientColor,
                    );
                  },
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print(snapshot.error);
            throw snapshot.error!;
          }
          return const Placeholder();
        } else {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}
