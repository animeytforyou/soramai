import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/api/progress.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/src/anime/anime.dart';
import 'package:soramai/src/anime/character.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AnimeDetailsWidget extends StatefulWidget {
  const AnimeDetailsWidget(
      {super.key, required this.anime, required this.ambiantColor});

  final Anime anime;
  final Color ambiantColor;

  @override
  State<AnimeDetailsWidget> createState() => _AnimeDetailsWidgetState();
}

class _AnimeDetailsWidgetState extends State<AnimeDetailsWidget> {
  bool isDescriptionExpanded = false;
  bool showAllTags = false;

  @override
  Widget build(BuildContext context) {
    bool foundSequel = false;
    bool foundPrequel = false;
    final controller =
        YoutubePlayerController(initialVideoId: widget.anime.trailer?.id ?? "");

    return SliverList(
      delegate: SliverChildListDelegate([
        // Play/Resume Button
        FutureBuilder(
          future: UserAnimeProgress().getLatestEpisodeProgress(widget.anime.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final latestProgress = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: widget.ambiantColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(latestProgress?.watched == false
                              ? 'Resume Episode ${latestProgress!.episodeNumber}'
                              : latestProgress != null
                                  ? 'Resume Episode ${latestProgress.episodeNumber + 1}'
                                  : "Play Episode 1"),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: widget.ambiantColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child:
                              const Icon(CupertinoIcons.square_list, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
        // Description
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isDescriptionExpanded = !isDescriptionExpanded;
              });
            },
            onLongPress: () {
              Clipboard.setData(ClipboardData(
                text: widget.anime.description
                    .replaceAll(RegExp(r"\<(\/)?\w+?\>"), "")
                    .replaceAll(RegExp(r"\(Source(:)?[\w\s]+\)"), "")
                    .replaceAll(RegExp(r"\s{2,}"), ""),
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Description copied to clipboard'),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.anime.description
                      .replaceAll(RegExp(r"\<(\/)?\w+?\>"), "")
                      .replaceAll(RegExp(r"\(Source(:)?[\w\s]+\)"), "")
                      .replaceAll(RegExp(r"\s{2,}"), ""),
                  style: const TextStyle(fontSize: 16),
                  maxLines: isDescriptionExpanded ? null : 2,
                  overflow: isDescriptionExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // PillCards + Trailer
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Genres:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.anime.genres.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: Text(
                          widget.anime.genres[index] == ""
                              ? "loading"
                              : widget.anime.genres[index],
                          style: TextStyle(color: widget.ambiantColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Synonyms:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    widget.anime.title.synonyms.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Chip(
                        label: Text(
                          widget.anime.title.synonyms[index],
                          style: TextStyle(color: widget.ambiantColor),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tags:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    showAllTags ? widget.anime.tags.length : 5,
                    (index) => Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Chip(
                        label: Row(
                          children: [
                            Text(
                              "${widget.anime.tags[index].name}: ${widget.anime.tags[index].rank}% ",
                              style: TextStyle(color: widget.ambiantColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (!showAllTags)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showAllTags = true;
                      });
                    },
                    child: Text(
                      'Show All Tags',
                      style: TextStyle(color: widget.ambiantColor),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (widget.anime.trailer?.id != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trailer:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: !Platform.isWindows
                      ? YoutubePlayer(
                          controller: controller,
                          onReady: () {
                            controller.pause();
                            controller.mute();
                          },
                          onEnded: (metadata) {
                            controller.mute();
                            controller.pause();
                          },
                          showVideoProgressIndicator: true,
                          progressColors: ProgressBarColors(
                            playedColor: widget.ambiantColor,
                            handleColor: widget.ambiantColor,
                          ),
                        )
                      : Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            CachedNetworkImage(
                              height: 200,
                              fit: BoxFit.fitHeight,
                              imageUrl: widget.anime.cover.extraLarge,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      const Skeletonizer(
                                child: Bone.button(
                                  width: 75,
                                  height: 75 * 1.777777778,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Skeletonizer(
                                child: Bone.button(
                                  width: 75,
                                  height: 75 * 1.777777778,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withOpacity(.3),
                              ),
                            ),
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  launchUrl(Uri.parse(
                                      "https://youtube.com/watch?v=${widget.anime.trailer?.id}"));
                                },
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  size: 64,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.anime.relations.map((animeRel) {
              //PREQUEL

              if (animeRel.type == AnimeRelationType.Prequel &&
                  foundPrequel == false) {
                foundPrequel = true;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AnimeDetailsPage(animeRes: animeRel.anime);
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .3,
                      height: MediaQuery.of(context).size.width * .15,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.ambiantColor),
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: Image.network(
                            animeRel.anime.banner,
                          ).image,
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.5),
                                borderRadius: BorderRadius.circular(16)),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              child: Text(
                                animeRel.type.name,
                                style: TextStyle(color: widget.ambiantColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // SEQUEL

              if (animeRel.type == AnimeRelationType.Sequel &&
                  foundSequel == false) {
                foundSequel = true;
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AnimeDetailsPage(animeRes: animeRel.anime);
                      }));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * .3,
                      height: MediaQuery.of(context).size.width * .15,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.ambiantColor),
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: Image.network(
                            animeRel.anime.banner,
                          ).image,
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.5),
                                borderRadius: BorderRadius.circular(16)),
                          )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              child: Text(
                                animeRel.type.name,
                                style: TextStyle(color: widget.ambiantColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Relations:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.anime.relations.map((relation) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          controller.mute();
                          controller.pause();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AnimeDetailsPage(
                                  animeRes: relation.anime,
                                );
                              },
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                  height: 200,
                                  fit: BoxFit.fitHeight,
                                  imageUrl: relation.anime.cover.extraLarge,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  top: 8.0,
                                ),
                                child: SizedBox(
                                  width: 200 / 1.77777778,
                                  child: Text(
                                    relation.anime.title.romaji,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0, bottom: 8.0),
                                child: SizedBox(
                                  width: 200 / 1.77777778,
                                  child: Text(
                                    relation.type.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xff888888),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Text(
                'Characters:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.anime.characters.map((character) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          controller.mute();
                          controller.pause();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CharacterDetailsPage(
                                characterId: character.id);
                          }));
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                  height: 200,
                                  fit: BoxFit.fitHeight,
                                  imageUrl: character.image.large,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(character.name.full),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Text(
                'Recommendations:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.anime.recommendations.map((recommendation) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          controller.mute();
                          controller.pause();
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AnimeDetailsPage(
                              animeRes: recommendation,
                            );
                          }));
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CachedNetworkImage(
                                  height: 200,
                                  fit: BoxFit.fitHeight,
                                  imageUrl: recommendation.cover.extraLarge,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Skeletonizer(
                                    child: Bone.button(
                                      width: 200 / 1.77777778,
                                      height: 200,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 8.0,
                                  right: 8.0,
                                  bottom: 8.0,
                                ),
                                child: SizedBox(
                                  width: 200 / 1.77777778,
                                  child: Text(
                                    recommendation.title.romaji,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
