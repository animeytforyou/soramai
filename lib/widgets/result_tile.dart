import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/src/anime/anime.dart';

class ResultTile extends StatelessWidget {
  const ResultTile({super.key, required this.anime});
  final AnimeSearchResult anime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AnimeDetailsPage(animeRes: anime);
          }));
        },
        child: Card(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                  image: Image.network(anime.banner).image, fit: BoxFit.fill),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withOpacity(.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              height: MediaQuery.of(context).size.width * .2,
                              imageUrl: anime.cover.extraLarge,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      Skeletonizer(
                                child: Bone.button(
                                  width:
                                      (MediaQuery.of(context).size.width * .2) /
                                          1.77777778,
                                  height:
                                      MediaQuery.of(context).size.width * .2,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Skeletonizer(
                                child: Bone.button(
                                  width:
                                      (MediaQuery.of(context).size.width * .2) /
                                          1.77777778,
                                  height:
                                      MediaQuery.of(context).size.width * .2,
                                ),
                              ),
                            ),
                          ),
                        )),
                    const SizedBox(
                      width: 16,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * .25,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            anime.title.romaji,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xffcdcdcd),
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            anime.title.english,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xff888888), fontSize: 10),
                            textAlign: TextAlign.left,
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          anime.type == AnimeType.Anime
                              ? Text(
                                  "${anime.episodes} Episodes",
                                  style: const TextStyle(
                                    color: Color(0xffcdcdcd),
                                  ),
                                )
                              : anime.chapters != 0
                                  ? Text(
                                      "${anime.chapters} Chapters",
                                      style: const TextStyle(
                                        color: Color(0xffcdcdcd),
                                      ),
                                    )
                                  : anime.volumes != 0
                                      ? Text(
                                          "${anime.volumes} Volumes",
                                          style: const TextStyle(
                                            color: Color(0xffcdcdcd),
                                          ),
                                        )
                                      : const Text(
                                          "?? Chapters",
                                          style: TextStyle(
                                            color: Color(0xffcdcdcd),
                                          ),
                                        ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
