// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:process_run/process_run.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/providers/allanime.dart';
import 'package:soramai/providers/anime_provider.dart';
import 'package:soramai/providers/arabanime.dart';
import 'package:soramai/src/anime/watch.dart';

class EpisodesPage extends StatefulWidget {
  const EpisodesPage(
      {super.key, required this.anime, required this.ambientColor});
  final Anime anime;
  final Color ambientColor;

  @override
  State<EpisodesPage> createState() => _EpisodesPageState();
}

class _EpisodesPageState extends State<EpisodesPage> {
  ProviderAnimeSearchResult? searchResult;
  AnimeProvider? provider;
  AnimeProvider? usedProvider;
  String queryTry = "";
  List servers = [];
  bool mode = true;
  final initialProvider = AllAnime();

  List<AnimeProvider> providers = [AllAnime(), ArabAnime()];

  void _launchMPV(BuildContext context, url) async {
    if (Platform.isWindows || Platform.isLinux) {
      final shell = Shell();
      try {
        //TODO: find a better way to parse the url without the quotes disapearing in the command
        await shell.runExecutableArguments("mpv", ["\"", url, "\""]);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('MPV launched successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to launch MPV: $e')),
        );
      }
      //TODO: Find a way to play embed videos for android apps other than webviews
      // } else if (Platform.isAndroid) {
      //   final intent = AndroidIntent(
      //     action: 'android.intent.action.VIEW',
      //     data: "$url",
      //     package: 'is.xyz.mpv',
      //     componentName: 'is.xyz.mpv.MPVActivity',
      //     flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      //   );
      //   intent.launch().catchError((e) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Failed to launch MPVActivity: $e')),
      //     );
      //   });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unsupported platform')),
      );
    }
  }

  void _showSearchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<ProviderAnimeSearchResult?> manualSearchResults = [];

            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .8,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: 'Search',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50)),
                            ),
                            onSubmitted: (query) async {
                              final res = await provider?.search(query);
                              if (res != null) {
                                setState(() {
                                  manualSearchResults = res;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16), // Add some spacing
                        manualSearchResults.isEmpty
                            ? const Text(
                                "No results found") // Handle empty state
                            : ListView.builder(
                                shrinkWrap: true, // Use shrinkWrap
                                itemCount: manualSearchResults.length,
                                itemBuilder: (context, index) {
                                  final result = manualSearchResults[index];
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: result?.cover ?? "",
                                            height: 50,
                                          ),
                                          Text(result?.title ?? ""),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
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
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return SliverList(
      delegate: SliverChildListDelegate([
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (queryTry != "" && searchResult == null)
                Text("Searching: $queryTry"),
              if (searchResult != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Found: ${searchResult?.title}",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: _showSearchSheet,
                        child: Text(
                          "Wrong title?",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                            color: widget.ambientColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomDropdown<AnimeProvider>(
                    hintText: 'Select provider',
                    hintBuilder: (context, hint) {
                      return Text(
                        hint,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      );
                    },
                    items: providers,
                    onChanged: (value) {
                      setState(() {
                        provider = value;
                      });
                      final queries = [
                        widget.anime.title.english,
                        widget.anime.title.romaji,
                      ];
                      queries.addAll(widget.anime.title.synonyms);

                      for (final query in queries) {
                        setState(() {
                          queryTry = query;
                        });
                        if (kDebugMode) {
                          print("trying $query");
                        }
                        provider?.search(query).then(
                          (results) {
                            if (kDebugMode) {
                              print("got ${results.length} results");
                            }
                            for (final result in results) {
                              if (kDebugMode) {
                                print("checking ${result.title}");
                              }
                              if (queries.contains(result.title)) {
                                if (kDebugMode) {
                                  print("found ${result.title}");
                                }
                                setState(() {
                                  searchResult = result;
                                  usedProvider = provider;
                                });
                              }
                            }
                          },
                        );
                      }
                    },
                    listItemBuilder:
                        (context, provider, isSelected, onItemSelect) {
                      return ListTile(
                        title: Text(
                          provider.toString(),
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                    decoration: CustomDropdownDecoration(
                      listItemStyle: TextStyle(
                        color: isDarkTheme ? Colors.white : Colors.black,
                      ),
                      closedFillColor: Theme.of(context).cardColor,
                      expandedFillColor: isDarkTheme
                          ? Colors.grey[850]
                          : Theme.of(context).cardColor,
                      closedBorderRadius: BorderRadius.circular(8),
                      expandedBorderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      closedBorder: Border.all(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              if (searchResult == null)
                Column(
                  children: [
                    const Text("No Result found"),
                    const Text("Try looking up for it yourself?"),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _showSearchSheet,
                    ),
                  ],
                ),
              if (provider.toString() == "AllAnime")
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider!.mode),
                    const SizedBox(
                      width: 16,
                    ),
                    Switch(
                      activeColor: widget.ambientColor,
                      value: mode,
                      onChanged: (value) {
                        mode = value;
                        if (value) {
                          provider?.mode = "sub";
                        } else {
                          provider?.mode = "dub";
                        }
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              if (searchResult != null && usedProvider == provider)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResult?.episodeCount ?? 0,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (provider.toString() == "ArabAnime" ||
                              usedProvider.toString() == "ArabAnime") {
                            print("the provider is ArabAnime");
                            final stream = await ArabAnime()
                                .play(searchResult!.id, index + 1);
                            _launchMPV(context, stream!.url);
                          }
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => WatchPage(
                          //       anime: widget.anime,
                          //       id: searchResult!.id,
                          //       episode: index + 1,
                          //       provider: provider!,
                          //     ),
                          //   ),
                          // );
                        },
                        child: Text("Episode ${index + 1}"),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ]),
    );
  }
}
