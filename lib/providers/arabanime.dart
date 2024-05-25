// ignore_for_file: overridden_fields

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:soramai/classes/arabanime.dart';
import 'package:soramai/providers/anime_provider.dart';

class ArabAnime extends AnimeProvider {
  String site = "https://www.arabanime.net";

  @override
  String lang = "ar";
  @override
  String mode = "sub";

  Future<Map> getAnimeDetails(String url) async {
    final uri = Uri.parse(url);
    final request = await http.get(uri);
    final bs = BeautifulSoup(request.body);
    final data = jsonDecode(String.fromCharCodes(
        base64Decode(bs.find("div", selector: "#data")!.text)));
    final show = data["show"][0];
    final result = {
      "id": show["anime_id"],
      "url": url,
      "title": show["anime_name"],
      "score": show["anime_score"],
      "status": show["anime_status"],
      "type": show["anime_type"],
      "release_date": show["anime_release_date"],
      "description": show["anime_description"],
      "genres": show["anime_genres"].split(", "),
      "cover": show["anime_cover_image_url"],
      "slug": show["anime_slug"],
      "episode_count": show["show_episode_count"],
    };

    return result;
  }

  @override
  Future<List<ArabAnimeSearchResult>> search(String query,
      {int page = 1}) async {
    final body = {"searchq": query};
    final uri = Uri.parse("$site/searchq");
    final request = await http.post(uri, body: body);
    final bs = BeautifulSoup(request.body);
    final searchResults = bs.findAll("div", selector: ".show");
    if (searchResults.isEmpty) {
      return [];
    }
    final List<ArabAnimeSearchResult> results = [];
    for (var result in searchResults) {
      final link = result.find("a")!.getAttrValue("href");
      final title = result.find("h3")!.text;
      final thumbnail = result.find("img")!.getAttrValue("src");
      final details = await getAnimeDetails(link!);
      final episodes = details["episode_count"];
      results.add(ArabAnimeSearchResult(
        id: link,
        title: title,
        episodeCount: episodes,
        cover: thumbnail,
      ));
    }
    return results;
  }

  // @override
  Future<List<ArabAnimeStreams>> getEpisodeStream(String url,
      {int episode = 1}) async {
    final uri = Uri.parse(getEpisodePageLink(url, episode: episode));
    final request = await http.get(uri);
    final bs = BeautifulSoup(request.body);
    final data = jsonDecode(String.fromCharCodes(
        base64Decode(bs.find("div", selector: "#datawatch")!.text)));
    final server = String.fromCharCodes(
        base64Decode(data["ep_info"][0]["stream_servers"][0]));
    final request2 = await http.get(Uri.parse(server));
    final bs2 = BeautifulSoup(request2.body);
    final List<ArabAnimeStreams> options = [];
    for (var option in bs2.findAll("", selector: "option")) {
      final result = {
        "name": option.text,
        "link": String.fromCharCodes(
            base64Decode(option.getAttrValue("data-src")!)),
      };
      options.add(ArabAnimeStreams(
          arabAnimeEndPoint: url,
          url: result["link"]!,
          episode: episode,
          provider: result["name"]!));
    }
    return options;
  }

  String getEpisodePageLink(String url, {int episode = 1}) {
    if (url.contains("https://www.arabanime.net/show-")) {
      return "${url.replaceAll("show", "watch")}/$episode";
    } else {
      return url;
    }
  }

  @override
  Future<ArabAnimeStreams?> play(String id, int episode) async {
    return (await getEpisodeStream(id, episode: episode)).first;
  }

  @override
  String toString() {
    return "ArabAnime";
  }
}
