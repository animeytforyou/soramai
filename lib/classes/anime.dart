// ignore_for_file: constant_identifier_names

import 'dart:async';

enum AnimeType {
  Anime,
  TV,
  OVA,
  Movie,
  Special,
  ONA,
  Music,
  Manga,
  Unknown,
}

enum AnimeSearchType {
  ANIME,
  MANGA,
}

enum AnimeSource {
  Original,
  LightNovel,
  VisualNovel,
  Manga,
  LightNovelTranslation,
  VisualNovelTranslation,
  MangaTranslation,
  Music,
  Unknown,
}

enum AnimeStatus {
  Finished,
  Releasing,
  NotYetAired,
  Cancelled,
  Unknown,
}

enum AnimeRelationType {
  Alternative,
  Prequel,
  Sequel,
  SideStory,
  Summary,
  Adaptation,
  Character,
  SpinOff,
  Other,
  Unknown,
}

class AnimeEpisodeInfo {
  int episode;
  String title;
  String description;
  String thumbnail;

  AnimeEpisodeInfo({
    required this.episode,
    required this.title,
    required this.thumbnail,
    this.description = "",
  });
}

class AnimeTitle {
  String english;
  String romaji;
  String native;
  String userPreferred;
  List<String> synonyms;

  AnimeTitle({
    required this.english,
    required this.romaji,
    required this.native,
    required this.userPreferred,
    this.synonyms = const [],
  });

  factory AnimeTitle.fromJson(Map json) {
    return AnimeTitle(
      english: json["english"] ?? "",
      romaji: json["romaji"] ?? "",
      native: json["native"] ?? "",
      userPreferred: json["userPreferred"] ?? json["romaji"] ?? "",
    );
  }
}

class AnimeRelations {
  int relId;
  AnimeRelationType type;
  AnimeSearchResult anime;

  AnimeRelations({
    required this.relId,
    required this.type,
    required this.anime,
  });

  factory AnimeRelations.fromJson(Map json) {
    return AnimeRelations(
      relId: json["id"],
      type: AnimeRelationType.values.firstWhere((element) => element.name
          .toLowerCase()
          .contains(json["relationType"].toLowerCase().replaceAll("_", ""))),
      anime: AnimeSearchResult.fromJson(json["node"]),
    );
  }
}

class AnimeCover {
  String extraLarge;
  String large;
  String medium;
  String color;

  AnimeCover({
    required this.extraLarge,
    required this.large,
    required this.medium,
    required this.color,
  });

  factory AnimeCover.fromJson(Map json) {
    return AnimeCover(
      extraLarge: json["extraLarge"],
      large: json["large"],
      medium: json["medium"],
      color: json["color"] ?? "#ffffff",
    );
  }

  toJson() {
    return {
      "extraLarge": extraLarge,
      "large": large,
      "medium": medium,
      "color": color,
    };
  }
}

class AnimeTags {
  int id;
  String name;
  String category;
  bool isGeneralSpoiler;
  int rank;

  AnimeTags({
    required this.id,
    required this.name,
    required this.category,
    required this.isGeneralSpoiler,
    required this.rank,
  });

  factory AnimeTags.fromJson(Map json) {
    return AnimeTags(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        isGeneralSpoiler: json["isGeneralSpoiler"],
        rank: json["rank"]);
  }
}

class CharacterName {
  String first;
  String middle;
  String last;
  String full;
  String native;
  String userPrefered;

  CharacterName({
    required this.first,
    required this.middle,
    required this.last,
    required this.full,
    required this.native,
    required this.userPrefered,
  });
}

class CharacterImage {
  String large;
  String medium;

  CharacterImage({
    required this.large,
    required this.medium,
  });
}

class AnimeCharacterResult {
  int id;
  CharacterName name;
  CharacterImage image;
  String gender;

  AnimeCharacterResult({
    required this.id,
    required this.name,
    required this.image,
    required this.gender,
  });

  factory AnimeCharacterResult.fromJson(Map json) {
    return AnimeCharacterResult(
      id: json["id"],
      name: CharacterName(
        first: json["name"]["first"] ?? "",
        middle: json["name"]["middle"] ?? "",
        last: json["name"]["last"] ?? "",
        full: json["name"]["full"],
        native: json["name"]["native"],
        userPrefered: json["name"]["userPreferred"] ?? "",
      ),
      image: CharacterImage(
        large: json["image"]["large"],
        medium: json["image"]["medium"],
      ),
      gender: json["gender"] ?? "no data",
    );
  }
}

class CharacterDateOfBirth {
  int year;
  int month;
  int day;

  CharacterDateOfBirth({
    required this.year,
    required this.month,
    required this.day,
  });

  factory CharacterDateOfBirth.fromJson(Map json) {
    return CharacterDateOfBirth(
      year: json["year"] ?? 0,
      month: json["month"] ?? 0,
      day: json["day"] ?? 0,
    );
  }
}

class AnimeCharacter {
  int id;
  CharacterName name;
  CharacterImage image;
  String description;
  CharacterDateOfBirth dateOfBirth;
  String age;
  String bloodType;
  String gender;
  List<AnimeSearchResult> includedIn;
  int favorites;

  AnimeCharacter({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.dateOfBirth,
    required this.age,
    required this.bloodType,
    required this.gender,
    required this.includedIn,
    required this.favorites,
  });

  factory AnimeCharacter.fromJson(Map json) {
    return AnimeCharacter(
      id: json["id"],
      name: CharacterName(
        first: json["name"]["first"] ?? "",
        middle: json["name"]["middle"] ?? "",
        last: json["name"]["last"] ?? "",
        full: json["name"]["full"],
        native: json["name"]["native"],
        userPrefered: json["name"]["userPreferred"] ?? "",
      ),
      description: json["description"] ?? "",
      image: CharacterImage(
        large: json["image"]["large"],
        medium: json["image"]["medium"],
      ),
      dateOfBirth: CharacterDateOfBirth.fromJson(json["dateOfBirth"]),
      age: json["age"] ?? "no data",
      bloodType: json["bloodType"] ?? "no data",
      gender: json["gender"] ?? "no data",
      favorites: json["favourites"] ?? 0,
      includedIn: json["media"]["edges"]
          .map<AnimeSearchResult>(
              (edge) => AnimeSearchResult.fromJson(edge["node"]))
          .toList() as List<AnimeSearchResult>,
    );
  }
}

class AnimeAiring {
  int id;
  int airingAt;
  int timeLeft;
  int episode;

  AnimeAiring({
    required this.id,
    required this.airingAt,
    required this.timeLeft,
    required this.episode,
  });

  DateTime get airingDateTime =>
      DateTime.fromMillisecondsSinceEpoch(airingAt * 1000);
  Stream<Duration> get durationLeft =>
      Stream.periodic(const Duration(seconds: 1), (count) {
        return airingDateTime.difference(DateTime.now());
      });

  factory AnimeAiring.fromJson(Map json) {
    return AnimeAiring(
      id: json["id"],
      airingAt: json["airingAt"],
      timeLeft: json["timeUntilAiring"],
      episode: json["episode"],
    );
  }
}

class AnimeDate {
  int year;
  int month;
  int day;

  AnimeDate({
    required this.year,
    required this.month,
    required this.day,
  });

  factory AnimeDate.fromJson(Map json) {
    return AnimeDate(
      year: json["year"] ?? 0,
      month: json["month"] ?? 1,
      day: json["day"] ?? 1,
    );
  }
}

class AnimeTrailer {
  String thumbnail;
  String site;
  String id;

  AnimeTrailer({
    required this.thumbnail,
    required this.site,
    required this.id,
  });

  factory AnimeTrailer.fromJson(Map json) {
    return AnimeTrailer(
      thumbnail: json["thumbnail"],
      site: json["site"],
      id: json["id"],
    );
  }
}

class AnimeSearchResult {
  int id;
  AnimeTitle title;
  AnimeCover cover;
  String banner;
  int episodes;
  double score;
  bool isAdult;
  AnimeType type;
  int chapters;
  int volumes;

  AnimeSearchResult({
    required this.id,
    required this.title,
    required this.cover,
    required this.banner,
    required this.episodes,
    required this.score,
    required this.isAdult,
    required this.type,
    required this.chapters,
    required this.volumes,
  });

  factory AnimeSearchResult.fromJson(Map json) {
    return AnimeSearchResult(
      id: json["id"],
      title: AnimeTitle.fromJson(json["title"]),
      cover: AnimeCover.fromJson(json["coverImage"]),
      banner: json["bannerImage"] ?? "",
      episodes: json["episodes"] ?? 0,
      score: (json["averageScore"] ?? 0) / 10,
      isAdult: json["isAdult"] ?? false,
      type: json["type"] != null
          ? AnimeType.values.firstWhere(
              (element) => element.name.toLowerCase().contains(
                    json["type"].toLowerCase().replaceAll("_", ""),
                  ),
            )
          : AnimeType.TV,
      chapters: json["chapters"] ?? 0,
      volumes: json["volumes"] ?? 0,
    );
  }
}

class Anime {
  int id;
  AnimeTitle title;
  String description;
  AnimeType type;
  List<AnimeEpisodeInfo> episodes;
  int episodeCount;
  Duration episodeDuration;
  AnimeCover cover;
  String banner;
  AnimeStatus status;
  AnimeSource source;
  double score;
  int popularity;
  int chapters;
  int volumes;
  bool isAdult;
  List<AnimeSearchResult> recommendations;
  List<AnimeRelations> relations;
  List<String> genres;
  List<AnimeTags> tags;
  List<AnimeCharacterResult> characters;
  AnimeAiring? nextEpisode;
  AnimeDate startDate;
  AnimeDate endDate;
  AnimeTrailer? trailer;

  Anime({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.episodes,
    required this.episodeCount,
    required this.episodeDuration,
    required this.cover,
    required this.banner,
    required this.status,
    required this.source,
    required this.score,
    required this.popularity,
    required this.chapters,
    required this.volumes,
    required this.isAdult,
    required this.recommendations,
    required this.relations,
    required this.genres,
    required this.tags,
    required this.characters,
    required this.nextEpisode,
    required this.startDate,
    required this.endDate,
    required this.trailer,
  });

  factory Anime.fromJson(Map json) {
    return Anime(
      id: json["id"] ?? 0,
      title: AnimeTitle.fromJson(json["title"]),
      description: json["description"]
          .replaceAll(RegExp(r"\<(\/)?\w+?\>"), "")
          .replaceAll(RegExp(r"\(Source(:)?[\w\s]+\)"), "")
          .replaceAll(RegExp(r"\s{2,}"), ""),
      type: AnimeType.values.firstWhere((element) =>
          element.name.toLowerCase().contains("${json["type"]}".toLowerCase())),
      episodes: [],
      episodeCount: json["episodes"] ?? 0,
      episodeDuration: Duration(minutes: json["duration"] ?? 0),
      cover: AnimeCover.fromJson(json["coverImage"]),
      banner: json["bannerImage"] ?? "",
      status: json["status"] != null
          ? AnimeStatus.values.firstWhere((element) => element.name
              .toLowerCase()
              .contains("${json["status"]}".toLowerCase()))
          : AnimeStatus.Unknown,
      source: AnimeSource.values.firstWhere((element) => element.name
          .toLowerCase()
          .contains("${json["source"]}".toLowerCase())),
      score: (json["averageScore"] ?? 0) / 10,
      popularity: json["popularity"] ?? 0,
      chapters: json["chapters"] ?? 0,
      volumes: json["volumes"] ?? 0,
      isAdult: json["isAdult"] ?? false,
      recommendations: (json["recommendations"]["edges"] ?? [])
          .map<AnimeSearchResult>((e) =>
              AnimeSearchResult.fromJson(e["node"]["mediaRecommendation"]))
          .toList() as List<AnimeSearchResult>,
      relations: (json["relations"]["edges"] ?? [])
          .map<AnimeRelations>((e) => AnimeRelations.fromJson(e))
          .toList() as List<AnimeRelations>,
      genres: json["genres"].map<String>((e) => "$e").toList(),
      tags: (json["tags"] ?? [])
          .map<AnimeTags>((e) => AnimeTags.fromJson(e))
          .toList(),
      characters: (json["characters"]["nodes"] ?? [])
          .map<AnimeCharacterResult>((e) => AnimeCharacterResult.fromJson(e))
          .toList(),
      nextEpisode: json["nextAiringEpisode"] != null
          ? AnimeAiring.fromJson(json["nextAiringEpisode"])
          : null,
      startDate: AnimeDate.fromJson(json["startDate"]),
      endDate: AnimeDate.fromJson(json["endDate"]),
      trailer: json["trailer"] != null
          ? AnimeTrailer.fromJson(json["trailer"])
          : null,
    );
  }
}
