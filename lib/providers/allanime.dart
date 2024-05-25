// ignore_for_file: overridden_fields

import "dart:convert";
// ignore: depend_on_referenced_packages
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";
import "package:soramai/classes/allanime.dart";
import "package:soramai/providers/anime_provider.dart";

class AllAnime extends AnimeProvider {
  String allanimeApi = "https://api.allanime.day/";
  String site = "https://allanime.to";
  @override
  String lang = "en";
  @override
  String mode = "sub";
  List<String> internalLinks = [
    "Luf-mp4",
    "Sak",
    "Default",
    "S-mp4",
  ];

  String endpoint = "";
  @override
  String cacheFileName = "aniwatch.cache.srx";

  // Queries

  String popularQuery = r"""
            query(
                $type: VaildPopularTypeEnumType!
                $size: Int!
                $page: Int
                $dateRange: Int
            ) {
                queryPopular(
                    type: $type
                    size: $size
                    dateRange: $dateRange
                    page: $page
                ) {
                    total
                    recommendations {
                        anyCard {
                            _id
                            name
                            thumbnail
                            englishName
                            slugTime
                        }
                    }
                }
            }
        """;

  String searchQuery = r"""
            query(
                $search: SearchInput
                $limit: Int
                $page: Int
                $translationType: VaildTranslationTypeEnumType
                $countryOrigin: VaildCountryOriginEnumType
            ) {
                shows(
                    search: $search
                    limit: $limit
                    page: $page
                    translationType: $translationType
                    countryOrigin: $countryOrigin
                ) {
                    pageInfo {
                        total
                    }
                    edges {
                        _id
                        name
                        thumbnail
                        englishName
                        episodeCount
                        score
                        genres
                        slugTime
                        __typename
                    }
                }
            }
        """;

  String detailsQuery = r"""
            query ($_id: String!) {
                show(
                    _id: $_id
                ) {
                    thumbnail
                    description
                    type
                    season
                    score
                    genres
                    status
                    studios
                }
            }
        """;

  String episodesQuery = r"""
            query ($_id: String!) {
                show(
                    _id: $_id
                ) {
                    _id
                    availableEpisodesDetail
                }
            }
        """;

  String streamsQuery = r"""
            query(
                $showId: String!,
                $translationType: VaildTranslationTypeEnumType!,
                $episodeString: String!
            ) {
                episode(
                    showId: $showId
                    translationType: $translationType
                    episodeString: $episodeString
                ) {
                    sourceUrls
                }
            }
        """;

  // Functions

  String decryptAllanime(String providerId) {
    String decrypted = '';
    for (int i = 0; i < providerId.length; i += 2) {
      String hexValue = providerId.substring(i, i + 2);
      int dec = int.parse(hexValue, radix: 16);
      int xor = dec ^ 56;
      String octValue = xor.toRadixString(8).padLeft(3, '0');
      decrypted += String.fromCharCode(int.parse(octValue, radix: 8));
    }
    return decrypted;
  }

  bool isInternal(String link) {
    return internalLinks.contains(link);
  }

  @override
  popular({int page = 1}) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "popular_page_$page";
    final cachedDataString = sp.getString(cacheKey);
    final cachedData = jsonDecode(cachedDataString ?? "[]");

    if (cachedDataString != null) {
      if (DateTime.now().millisecondsSinceEpoch - cachedData["timestamp"] <=
          60 * 60 * 24) {
        List res = cachedData["results"];
        return res.map(
          (e) {
            return e["anyCard"];
          },
        ).toList();
      }
    }

    final res = await http.post(
      Uri.parse("$allanimeApi/api").replace(
        queryParameters: {
          "variables": jsonEncode(
            {
              "type": "anime",
              "size": 26,
              "dateRange": 7,
              "page": page,
            },
          ),
          "query": popularQuery
        },
      ),
      headers: {
        "Referer": site,
        "User-Agent": agent,
      },
    );

    List results =
        jsonDecode(res.body)["data"]["queryPopular"]["recommendations"];

    final data = {
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "results": results,
    };

    sp.setString(cacheKey, jsonEncode(data));

    return results.map((e) => e["anyCard"]).toList();
  }

  @override
  Future<List<AllAnimeSearchResult>> search(String query,
      {int page = 1}) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "search_${query}_$page";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "{}");

    if (cacheDataString != null) {
      final List<AllAnimeSearchResult> animeList = [];
      for (var edge in cacheData) {
        animeList.add(AllAnimeSearchResult(
            id: edge["_id"],
            title: edge["name"],
            episodeCount: int.parse(edge?["episodeCount"] ?? "0"),
            cover: edge["thumbnail"]));
      }
    }

    final params = {
      "variables": jsonEncode({
        "search": {
          "query": query,
          "allowAdult": false,
          "allowUnknown": false,
        },
        "limit": 26,
        "page": page,
        "translationType": mode,
        "countryOrigin": "ALL",
      }),
      "query": searchQuery,
    };

    final headers = {
      "Referer": site,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    final data = jsonDecode(response.body)["data"]["shows"]["edges"];

    // cache data
    sp.setString(cacheKey, jsonEncode(data));

    final List<AllAnimeSearchResult> animeList = [];
    for (var edge in data) {
      animeList.add(AllAnimeSearchResult(
        id: edge["_id"],
        title: edge["name"],
        episodeCount: int.parse(edge?["episodeCount"] ?? "0"),
        cover: edge["thumbnail"],
      ));
    }

    return animeList;
  }

  Future<List<AllAnimeStreams>> getEpisodeStreams(
      String id, int episode) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "stream_${id}_episode_${episode}_$mode";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "{}");

    if (cacheDataString != null) {
      return cacheData
          .map<AllAnimeStreams>(
            (e) => AllAnimeStreams(
              sourceUrl: e["sourceUrl"],
              sourceName: e["sourceName"],
              priority: double.parse("${e["priority"]}").round(),
            ),
          )
          .toList();
    }

    final params = {
      "variables": jsonEncode({
        "showId": id,
        "translationType": mode,
        "episodeString": "$episode",
      }),
      "query": streamsQuery,
    };

    final headers = {
      "Referer": site,
      "User-Agent": agent,
    };

    final uri = Uri.parse("$allanimeApi/api").replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    final List data =
        jsonDecode(response.body)["data"]["episode"]["sourceUrls"];

    //save to cache
    sp.setString(cacheKey, jsonEncode(data));

    return data
        .map(
          (e) => AllAnimeStreams(
            sourceUrl: e["sourceUrl"],
            sourceName: e["sourceName"],
            priority: double.parse("${e["priority"]}").round(),
          ),
        )
        .toList();
  }

  Future<List> getVideoFromUrl(String url, String name) async {
    final decryptedUrl = decryptAllanime(url.replaceAll("--", ""));
    if (endpoint == "") {
      endpoint =
          jsonDecode((await http.get(Uri.parse("$site/getVersion"))).body)[
              "episodeIframeHead"];
    }
    final response = await http.get(Uri.parse(
        "$endpoint${decryptedUrl.replaceAll('/clock?', '/clock.json?')}"));
    if (response.statusCode != 200) {
      return [];
    }
    return jsonDecode(response.body)["links"];
  }

  Future<List<AllAnimeVideoLink>> getVideoList(
      String animeId, int episodeNum) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "videoList_${animeId}_episode_${episodeNum}_$mode";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "[]") as List;

    if (cacheDataString != "") {
      // print("cache data: $cacheData");

      final results = [];
      for (var video in cacheData) {
        // print(
        //     "the video in the videoList When fetching the videoList is $video");
        video = video.first;
        if (video == []) {
          continue;
        }
        // print(video);
        final link = video["link"];
        final hls =
            video["hls"] ?? (video["mp4"] != null ? !video["mp4"] : false);
        final mp4 =
            video["mp4"] ?? (video["hls"] != null ? !video["hls"] : false);
        final resolution = video["resolutionStr"];
        final src = video["rawUrls"] ?? "";
        final rawUrls = video["rawUrls"] ?? {};
        results.add(AllAnimeVideoLink(
          link: link,
          hls: hls,
          mp4: mp4,
          resolution: resolution,
          src: src,
          rawUrls: rawUrls,
        ));
      }
    }

    final episodesStreams = await getEpisodeStreams(animeId, episodeNum);
    var videoList = [];
    for (var stream in episodesStreams) {
      if (isInternal(stream.sourceName)) {
        final links =
            await getVideoFromUrl(stream.sourceUrl, stream.sourceName);
        videoList.add(links);
      }
    }
    videoList = videoList.where((list) => list.isNotEmpty).toList();

    // cache videoList
    sp.setString(cacheKey, jsonEncode(videoList));

    final List<AllAnimeVideoLink> videoLinks = videoList.map((video) {
      // print("the video in the videoList When fetching the videoList is $video");
      video = video.first;
      // print(video);
      final link = video["link"];
      final hls =
          video["hls"] ?? (video["mp4"] != null ? !video["mp4"] : false);
      final mp4 =
          video["mp4"] ?? (video["hls"] != null ? !video["hls"] : false);
      final resolution = video["resolutionStr"];
      final src = video["rawUrls"] ?? "";
      final rawUrls = video["rawUrls"] ?? {};
      return AllAnimeVideoLink(
        link: link,
        hls: hls,
        mp4: mp4,
        resolution: resolution,
        src: src,
        rawUrls: rawUrls,
      );
    }).toList();

    return videoLinks;
  }

  @override
  Future<AllAnimeEpisodeStream?> play(String id, int episode) async {
    final streams = await getVideoList(id, episode);
    return AllAnimeEpisodeStream(
      allanimeId: id,
      episode: episode,
      url: streams.first.link,
    );
  }

  @override
  String toString() {
    return "AllAnime";
  }
}
