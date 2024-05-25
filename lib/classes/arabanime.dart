// ignore_for_file: overridden_fields

import 'package:soramai/providers/anime_provider.dart';

class ArabAnimeSearchResult extends ProviderAnimeSearchResult {
  @override
  String id;
  @override
  String title;
  @override
  String? cover;
  @override
  int episodeCount;

  ArabAnimeSearchResult({
    required this.id,
    required this.title,
    required this.episodeCount,
    required this.cover,
  });
}

class ArabAnimeStreams extends AnimeEpisodeStream {
  String arabAnimeEndPoint;
  @override
  String url;
  @override
  int episode;

  ArabAnimeStreams({
    required this.arabAnimeEndPoint,
    required this.url,
    required this.episode,
    super.provider = "ArabAnime",
  });
}
