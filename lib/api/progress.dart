import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EpisodeProgress {
  final int id;
  final String animeName;
  final int episodeNumber;
  final String episodeUrl;
  final Duration progress;
  final bool watched;
  final String? episodeTitle;
  final String? synopsis;
  final String? thumbnail;

  EpisodeProgress({
    required this.id,
    required this.animeName,
    required this.episodeNumber,
    required this.episodeUrl,
    required this.progress,
    required this.watched,
    this.episodeTitle,
    this.synopsis,
    this.thumbnail,
  });

  factory EpisodeProgress.fromJson(Map<String, dynamic> json) {
    return EpisodeProgress(
      id: json["id"],
      animeName: json["animeName"] as String,
      episodeNumber: json['episodeNumber'] as int,
      episodeUrl: json['episodeUrl'] as String,
      progress: Duration(seconds: json["progress"]),
      watched: json['watched'] as bool,
      episodeTitle: json['episodeTitle'] as String?,
      synopsis: json['synopsis'] as String?,
      thumbnail: json["thumbnail"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animeName': animeName,
      'episodeNumber': episodeNumber,
      'episodeUrl': episodeUrl,
      'progress': progress.inSeconds,
      'watched': watched,
      'episodeTitle': episodeTitle ?? "",
      'synopsis': synopsis ?? "",
      'thumbnail': thumbnail ?? "",
    };
  }
}

class UserAnimeProgress {
  final String _progressKey = "user_progress";

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> saveProgress({
    required int id,
    required String animeName,
    required String episodeUrl,
    required int episodeNumber,
    required Duration progress,
    required bool watched,
    String? thumb,
    String? episodeTitle,
  }) async {
    try {
      final SharedPreferences prefs = await _prefs;
      List<String> progressList = prefs.getStringList(_progressKey) ?? [];
      List<EpisodeProgress> episodes = progressList.map((String jsonStr) {
        return EpisodeProgress.fromJson(jsonDecode(jsonStr));
      }).toList();

      bool found = false;
      for (int i = 0; i < episodes.length; i++) {
        if (episodes[i].id == id) {
          episodes[i] = EpisodeProgress(
            id: id,
            animeName: animeName,
            episodeNumber: episodeNumber,
            episodeUrl: episodeUrl,
            progress: progress,
            watched: watched,
            episodeTitle: episodeTitle ?? episodes[i].episodeTitle,
            synopsis: episodes[i].synopsis,
            thumbnail: thumb ?? episodes[i].thumbnail,
          );
          found = true;
          break;
        }
      }

      if (!found) {
        episodes.add(EpisodeProgress(
          id: id,
          animeName: animeName,
          episodeNumber: episodeNumber,
          episodeUrl: episodeUrl,
          progress: progress,
          watched: watched,
          episodeTitle: episodeTitle,
          synopsis: null,
          thumbnail: thumb,
        ));
      }

      List<String> updatedProgressList =
          episodes.map((ep) => jsonEncode(ep.toJson())).toList();
      await prefs.setStringList(_progressKey, updatedProgressList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user progress: $e');
      }
    }
  }

  Future<List<EpisodeProgress>> getWatchList() async {
    try {
      final SharedPreferences prefs = await _prefs;
      List<String> progressList = prefs.getStringList(_progressKey) ?? [];
      return progressList.map((String jsonStr) {
        return EpisodeProgress.fromJson(jsonDecode(jsonStr));
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user progress: $e');
      }
      return [];
    }
  }

  Future<EpisodeProgress?> getLatestEpisodeProgress(int id) async {
    try {
      final SharedPreferences prefs = await _prefs;
      List<String> progressList = prefs.getStringList(_progressKey) ?? [];
      for (String jsonStr in progressList.reversed) {
        Map<String, dynamic> json = jsonDecode(jsonStr);
        if (json['id'] == id &&
            (json['watched'] as bool || json["progress"] != 0)) {
          return EpisodeProgress.fromJson(json);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user progress: $e');
      }
    }
    return null;
  }
}
