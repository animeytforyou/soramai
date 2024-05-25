import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/classes/anime.dart';

class AnimeCoverWidget extends StatelessWidget {
  const AnimeCoverWidget({
    super.key,
    required this.anime,
    this.ambiantColor = const Color(0xff303035),
    this.coverVisible = true,
  });

  final bool coverVisible;
  final Color ambiantColor;
  final Anime anime;

  _showImageOptions(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "${anime.title.english} [Cover]",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            height: 200,
                            fit: BoxFit.fitHeight,
                            imageUrl: anime.cover.extraLarge,
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
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith(
                                    (states) => ambiantColor),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.download),
                              label: const Text("Save"),
                            ),
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                foregroundColor: MaterialStateColor.resolveWith(
                                    (states) => ambiantColor),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.share),
                              label: const Text("Share"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AnimatedOpacity(
            opacity: coverVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Hero(
              tag: "${anime.id}#cover",
              child: GestureDetector(
                onLongPress: () => _showImageOptions(context),
                child: CachedNetworkImage(
                  height: 200,
                  fit: BoxFit.fitHeight,
                  imageUrl: anime.cover.extraLarge,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      const Skeletonizer(
                    child: Bone.button(
                      width: 75,
                      height: 75 * 1.777777778,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Skeletonizer(
                    child: Bone.button(
                      width: 75,
                      height: 75 * 1.777777778,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              color: ambiantColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  topRight: Radius.circular(12)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Row(
                children: [
                  Text("${anime.score} ",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Icon(
                    CupertinoIcons.star_fill,
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
