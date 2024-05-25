// ignore_for_file: overridden_fields

import 'package:soramai/providers/anime_provider.dart';

class AllAnimeSearchResult extends ProviderAnimeSearchResult {
  @override
  String id;
  @override
  String title;
  @override
  int episodeCount;
  @override
  String? cover;

  AllAnimeSearchResult({
    required this.id,
    required this.title,
    required this.episodeCount,
    required this.cover,
  });
}

class AllAnimeStreams {
  String sourceUrl;
  String sourceName;
  int priority;

  AllAnimeStreams({
    required this.sourceUrl,
    required this.sourceName,
    required this.priority,
  });
}

class AllAnimeVideoLink {
  String link;
  bool hls;
  bool mp4;
  String resolution;
  String src;
  Map rawUrls;

  AllAnimeVideoLink({
    required this.link,
    required this.hls,
    required this.mp4,
    required this.resolution,
    required this.src,
    this.rawUrls = const {},
  });
}

class AllAnimeEpisodeStream extends AnimeEpisodeStream {
  String allanimeId;
  @override
  String url;
  @override
  int episode;

  AllAnimeEpisodeStream({
    required this.allanimeId,
    required this.url,
    required this.episode,
    super.provider = "AllAnime",
  });
}
