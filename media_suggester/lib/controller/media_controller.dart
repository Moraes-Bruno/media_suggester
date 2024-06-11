import 'package:flutter/material.dart';
import 'package:media_suggester/models/Media.dart';

class MediaController extends PageController {
  final Media _media = Media();

  dynamic searchMedia(String pesquisa) {
    return _media.searchMedia(pesquisa);
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
}
