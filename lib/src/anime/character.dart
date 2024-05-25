import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:soramai/api/anilist.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/classes/custom_navbar_controller.dart';
import 'package:soramai/src/anime/character_details.dart';

class CharacterDetailsPage extends StatefulWidget {
  const CharacterDetailsPage({super.key, required this.characterId});
  final int characterId;

  static const routeName = "/character";

  @override
  State<CharacterDetailsPage> createState() => _CharacterDetailsPageState();
}

class _CharacterDetailsPageState extends State<CharacterDetailsPage> {
  CustomNavBarController navBarController =
      CustomNavBarController(screenCount: 2);
  int page = 0;
  Color? color;
  Timer? timer;

  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  void _colorFetch(String imageUrl) async {
    final colorRes = (await PaletteGenerator.fromImageProvider(
            Image.network(imageUrl).image))
        .dominantColor
        ?.color;
    setState(() {
      color = colorRes;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AniList().characterDetails(widget.characterId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final character = snapshot.data as AnimeCharacter;
          if (color == null) {
            _colorFetch(character.image.large);
          }
          final ambientColor = color ?? const Color(0xffbdbddd);
          return Scaffold(
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
                          ClipboardData(text: character.name.full),
                        );
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),
                        ));
                      },
                      child: Text(
                        character.name.full,
                      ),
                    ),
                    // Anime Banner
                    background: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            child: CachedNetworkImage(
                              imageUrl: character.includedIn.first.banner,
                              fit: BoxFit.cover,
                              imageBuilder: (context, imageProvider) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      Skeletonizer(
                                child: Bone.button(
                                  width: MediaQuery.of(context).size.width,
                                  height: 200,
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Skeletonizer(
                                child: Bone.button(
                                    width:
                                        MediaQuery.of(context).size.width - 32,
                                    height: (MediaQuery.of(context).size.width -
                                            32) /
                                        1.7),
                              ),
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
                                end: Alignment.topCenter,
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
                        CachedNetworkImage(
                          height: 200,
                          fit: BoxFit.fitHeight,
                          imageUrl: character.image.large,
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
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.bloodtype, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      character.bloodType,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      character.age,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.cake, size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      character.dateOfBirth.month != 0
                                          ? "${character.dateOfBirth.day} ${months[character.dateOfBirth.month - 1]}"
                                          : "no data",
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                        character.gender == "Male"
                                            ? Icons.male
                                            : character.gender == "Female"
                                                ? Icons.female
                                                : Icons.question_mark,
                                        size: 18),
                                    const SizedBox(width: 5),
                                    Text(
                                      character.gender,
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
                CharacterDetailsWidget(
                    character: character, ambiantColor: ambientColor),
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
