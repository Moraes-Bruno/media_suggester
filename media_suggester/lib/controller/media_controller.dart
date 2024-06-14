import 'package:flutter/material.dart';
import 'package:media_suggester/models/Media.dart';

class MediaController extends PageController {
  final Media _media = Media();

   Future<List<dynamic>> searchMedia(String pesquisa) async {
    final result = await _media.searchMedia(pesquisa);
    return result
        .where((media) =>
            (media['title'] != null || media['original_name'] != null) &&
            media['overview'] != null &&
            media['poster_path'] != null)
        .toList();
  }


  Future<List<dynamic>> getMediaGenre(int generoId, String tipoMedia) async {
    return _media.getMediaGenre(generoId, tipoMedia);
  }

  Future<List<dynamic>> getMidia(String id, String endpoint) async {
    return _media.getMidia(id, endpoint);
  }

  Future<Map<int, String>> fetchGeneros({String? firstAirDate}) async {
    return _media.fetchGeneros(firstAirDate: firstAirDate);
  }
  Future <List<dynamic>> fetchGenres_movie() async{
     return _media.fetchGenres_movie();
  }
  Future <List<dynamic>> fetchGenres_serie() async{
    return _media.fetchGenres_serie();
  }
}
