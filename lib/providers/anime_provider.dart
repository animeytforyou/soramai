class AnimeEpisodeStream {
  int episode;
  String url;
  String provider;
  String site;

  AnimeEpisodeStream({
    this.episode = 1,
    this.url = "",
    this.provider = "",
    this.site = "",
  });
}

class ProviderAnimeSearchResult {
  String id;
  String title;
  int episodeCount;
  String? cover;

  ProviderAnimeSearchResult({
    this.id = "",
    this.title = "",
    this.episodeCount = 1,
    this.cover,
  });
}

class AnimeProvider {
  String agent =
      "Mozilla/5.0 (Windows NT 6.1; Win64; rv:109.0) Gecko/20100101 Firefox/109.0";
  String lang = "";
  String mode = "";
  String cacheFileName;

  Future<AnimeEpisodeStream?> play(String id, int episode) async {
    return null;
  }

  servers() async {
    return "servers";
  }

  details() async {
    return "details";
  }

  Future<List<ProviderAnimeSearchResult>> search(String query,
      {int page = 1}) async {
    return [ProviderAnimeSearchResult()];
  }

  popular() async {
    return "popular";
  }

  recommandations() async {
    return "recommandations";
  }

  AnimeProvider({
    this.lang = "en",
    this.mode = "dub",
    this.cacheFileName = "aniwatch.cache.json",
  });
}
