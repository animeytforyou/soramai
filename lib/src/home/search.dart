import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soramai/api/anilist.dart';
import 'package:soramai/classes/anime.dart';
import 'package:soramai/widgets/result_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key, this.query, this.type});

  final String? query;
  final AnimeSearchType? type;

  @override
  State<SearchPage> createState() => _SearchPageState();
  static const routeName = "/search";
}

class _SearchPageState extends State<SearchPage> {
  List<AnimeSearchResult> results = [];
  final searchController = TextEditingController();
  late AnimeSearchType type;
  bool isAdult = false;

  search() async {
    if (kDebugMode) {
      print(type);
    }
    final res = await AniList().search(searchController.text, type, isAdult);
    setState(() {
      results = res;
    });
  }

  @override
  void initState() {
    searchController.text = widget.query ?? "";
    type = widget.type ?? AnimeSearchType.ANIME;
    super.initState();
    if (searchController.text.isNotEmpty) {
      search();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = DefaultTextStyle.of(context).style;
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final textPainter = TextPainter(
      text: TextSpan(text: type.name, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .75,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50)),
                          labelText: 'Search',
                          hintText: 'Search for an anime',
                        ),
                        onEditingComplete: search,
                        onChanged: (v) => search,
                        onSubmitted: (v) => search,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: IconButton(
                        onPressed: search,
                        icon: const Icon(Icons.search),
                        tooltip: "Search",
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: textPainter.width,
                      height: textPainter.height,
                      child: CustomDropdown<String>(
                        hintText: 'Select provider',
                        hintBuilder: (context, hint) {
                          return Text(
                            hint,
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          );
                        },
                        initialItem: "Anime",
                        items: const [
                          "Anime",
                          "Manga",
                        ],
                        onChanged: (String? value) {
                          if (value != null) {
                            final tmpType = AnimeSearchType.values.firstWhere(
                                (element) =>
                                    element.name.toLowerCase() ==
                                    value.toLowerCase());
                            if (kDebugMode) {
                              print("tmpType: $tmpType");
                            }
                            type = tmpType;
                            setState(() {
                              type == tmpType;
                            });
                          }
                        },
                        listItemBuilder:
                            (context, provider, isSelected, onItemSelect) {
                          return ListTile(
                            title: Text(
                              provider.toString(),
                              style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black,
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
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Adult "),
                        Switch(
                          value: isAdult,
                          onChanged: (value) {
                            setState(() {
                              isAdult = value;
                            });
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Search Results: "),
              ),
              Visibility(
                visible: results.isNotEmpty,
                child: Expanded(
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    itemBuilder: ((context, index) {
                      final anime = results[index];
                      if (anime.isAdult != isAdult) {
                        return const SizedBox();
                      }
                      return ResultTile(anime: anime);
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
