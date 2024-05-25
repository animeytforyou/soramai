import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soramai/classes/anime.dart';

class AniList {
  AniList();

  Future<List<AnimeSearchResult>> search(
      String searchTerm, AnimeSearchType type, bool isAdult) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "search_results_${searchTerm}_type_${type.name}";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "[]") as List;

    if (cacheDataString != null) {
      if (kDebugMode) {
        print("cache data: $cacheDataString");
      }
      return cacheData.map((e) => AnimeSearchResult.fromJson(e)).toList();
    }

    var query = r"""
      query ($id: Int, $page: Int, $perPage: Int, $search: String, $type: MediaType) {
        Page (page: $page, perPage: $perPage) {
          pageInfo {
            total
            currentPage
            lastPage
            hasNextPage
            perPage
          }
          media (id: $id, search: $search, type: $type, sort: POPULARITY_DESC) {
            id
            title {
              english
              romaji
              native
            }
            averageScore
            episodes
            bannerImage
            coverImage {
                extraLarge
                large
                medium
                color
                  }
            isAdult
            type
            chapters
            volumes
          }
        }
      }
  """;
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var variables = {
      "search": searchTerm,
      "type": type.name,
      "page": 1,
      "perPage": 50
    };
    var url = "https://graphql.anilist.co";

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(
        {
          "query": query,
          "variables": variables,
        },
      ),
    );
    // print(jsonDecode(res.body)["data"]["Page"]["media"]);
    List medium = jsonDecode(res.body)["data"]["Page"]["media"];

    await sp.setString(cacheKey, jsonEncode(medium));

    return medium.map((e) => AnimeSearchResult.fromJson(e)).toList();
  }

  Future<Anime> details(int id) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "anime_details_$id";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "{}");

    if (cacheDataString != null) {
      return Anime.fromJson(cacheData);
    }

    var query = r"""
    query ($id: Int) {
      Media(id: $id) {
        id
        idMal
        title {
          romaji
          english
          native
          userPreferred
        }
        description
        episodes
        bannerImage
        coverImage {
          extraLarge
          large
          medium
          color
        }
        type
        format
        trailer {
          thumbnail
          site
          id
        }
        synonyms
        popularity
        duration
        chapters
        volumes
        isAdult
        source
        season
        status
        recommendations {
          edges {
            node {
              id
              mediaRecommendation {
                id
                title {
                  romaji
                  english
                  native
                  userPreferred
                }
                averageScore
                episodes
                bannerImage
                coverImage {
                  extraLarge
                  large
                  medium
                  color
                }
                isAdult
                type
                chapters
                volumes
              }
            }
          }
        }
        relations {
          edges {
            id
            relationType
            node {
              id
              title {
                romaji
                english
                native
                userPreferred
              }
              averageScore
              episodes
              bannerImage
              coverImage {
                extraLarge
                large
                medium
                color
              }
              isAdult
              type
              chapters
              volumes
            }
          }
        }
        averageScore
        genres
        tags {
          id
          name
          category
          isGeneralSpoiler
          rank
        }
        characters {
          edges {
            id
          }
          nodes {
            id
            name {
              first
              middle
              last
              full
              native
              userPreferred
            }
            image {
              large
              medium
            }
            gender
          }
          pageInfo {
            total
            perPage
            currentPage
            lastPage
            hasNextPage
          }
        }
        nextAiringEpisode {
          id
          airingAt
          timeUntilAiring
          episode
        }
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
      }
    }
  """;
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var variables = {"id": id, "page": 1, "perPage": 50};
    var url = "https://graphql.anilist.co";

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(
        {
          "query": query,
          "variables": variables,
        },
      ),
    );

    final details = jsonDecode(res.body)["data"]["Media"];

    await sp.setString(cacheKey, jsonEncode(details));

    return Anime.fromJson(details);
  }

  Future<AnimeCharacter> characterDetails(int id) async {
    final sp = await SharedPreferences.getInstance();
    final cacheKey = "character_$id";
    final cacheDataString = sp.getString(cacheKey);
    final cacheData = jsonDecode(cacheDataString ?? "{}");

    if (cacheDataString != null) {
      return AnimeCharacter.fromJson(cacheData);
    }

    var query = r"""
      query ($id: Int) {
        Character(id: $id) {
          id
          name {
            first
            middle
            last
            full
            native
            userPreferred
          }
          image {
            large
            medium
          }
          description
          gender
          dateOfBirth {
            year
            month
            day
          }
          age
          bloodType
          media {
            edges {
              id
              relationType
              node {
                id
                title {
                  english
                  romaji
                  native
                }
                averageScore
                episodes
                bannerImage
                coverImage {
                  extraLarge
                  large
                  medium
                  color
                }
                isAdult
                type
                chapters
                volumes
              }
            }
          }
          favourites
        }
      }
    """;
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    var variables = {"id": id, "page": 1, "perPage": 50};
    var url = "https://graphql.anilist.co";

    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(
        {
          "query": query,
          "variables": variables,
        },
      ),
    );
    final details = jsonDecode(res.body)["data"]["Character"];

    await sp.setString(cacheKey, jsonEncode(details));

    return AnimeCharacter.fromJson(details);
  }
}

void main(List<String> args) {
  AniList().details(30011).then((value) {
    if (kDebugMode) {
      print(value.isAdult);
    }
  });
}
