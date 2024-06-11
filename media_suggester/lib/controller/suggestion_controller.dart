import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/models/Suggestion.dart';
import '../models/SuggestionsByGenre.dart';

class SuggestionController extends PageController {
  final Suggestion _suggestion = Suggestion(null, null);

  Future<List<dynamic>?> GerarSugestoes(
      String tipoMidia, String generos) async {
    return _suggestion.GerarSugestoes(tipoMidia, generos);
  }

  Future<DocumentSnapshot?> GetSuggestions(userId) async {
    return _suggestion.GetSuggestions(userId);
  }

  Future<DocumentSnapshot?> SetSuggestions(userId, filmes, series) async {
    return _suggestion.SetSuggestions(userId, filmes, series);
  }

  Future<List<SugestoesPorGenero>?>
      VerificarSeApiPossuiDadosDasSugestoesGeradas(
          List<dynamic> sugestoesGeradas,
          List<Map<String, dynamic>> preferencias,
          String tipoMidia) async {
    return _suggestion.verificarSeApiPossuiDadosDasSugestoesGeradas(
        sugestoesGeradas, preferencias, tipoMidia);
  }

  Future<List<Map<String, dynamic>>> FormatarDadosParaFirestore(
      List<SugestoesPorGenero>? sugestoesPorGenero) async {
    return _suggestion.FormatarDadosParaFirestore(sugestoesPorGenero);
  }

  Future<Widget?> CarregarSugestoes(
      Suggestion? sugestoes, BuildContext context) async {
    _suggestion.CarregarSugestoes(sugestoes, context);
  }
}
