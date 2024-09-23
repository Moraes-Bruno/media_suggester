import 'package:flutter/material.dart';
import 'package:media_suggester/models/Media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MediaController extends PageController {
  final Media _media = Media();

  //-------------------pesquisar.dart--------------------\\
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

  //-------------------detalhes.dart--------------------\\
  Future<Map<int, String>> fetchGeneros({String? firstAirDate}) async {
    return _media.fetchGeneros(firstAirDate: firstAirDate);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchReviews(int mediaId){
    return _media.fetchReviews(mediaId);
  }

  //-----Relativo as preferencias do usuario-----\\
  Future<List<dynamic>> fetchGenres_movie() async {
    return _media.fetchGenres_movie();
  }

  Future<List<dynamic>> fetchGenres_serie() async {
    return _media.fetchGenres_serie();
  }

  //-------Relativo a Nota Media do conteudo---------\\

  Future<String> getNotaMedia(int filmeId) async {
    return _media.getNotaMedia(filmeId);
  }
}
