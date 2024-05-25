import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/src/anime/anime.dart';
import 'package:soramai/widgets/description_widget.dart';

class CharacterDetailsWidget extends StatefulWidget {
  const CharacterDetailsWidget(
      {super.key, required this.character, required this.ambiantColor});

  final AnimeCharacter character;
  final Color ambiantColor;

  @override
  State<CharacterDetailsWidget> createState() => _CharacterDetailsWidgetState();
}

class _CharacterDetailsWidgetState extends State<CharacterDetailsWidget> {
  bool isDescriptionExpanded = false;
  bool showAllTags = false;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate([
        // Play/Resume Button
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
                text: widget.character.description
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
                CharacterDescription(
                  description: widget.character.description
                      .replaceAll(RegExp(r"\_+"), ""),
                ),
                // Text(
                //   widget.character.description
                //       .replaceAll(RegExp(r"\<(\/)?\w+?\>"), "")
                //       .replaceAll(RegExp(r"\(Source(:)?[\w\s]+\)"), "")
                //       .replaceAll(RegExp(r"\s{2,}"), ""),
                //   style: const TextStyle(fontSize: 16),
                //   maxLines: isDescriptionExpanded ? null : 2,
                //   overflow: isDescriptionExpanded
                //       ? TextOverflow.visible
                //       : TextOverflow.ellipsis,
                // ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Included In:',
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
                  children: widget.character.includedIn.map((animeRes) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AnimeDetailsPage(
                              animeRes: animeRes,
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
                                  imageUrl: animeRes.cover.extraLarge,
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
                                    animeRes.title.romaji,
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
