import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/models/PersonalizedSuggestion.dart';
import 'package:media_suggester/models/Suggestion.dart';
import '../models/SuggestionsByGenre.dart';

class SuggestionController extends PageController {
  final Suggestion _suggestion = Suggestion(null, null);

  Future<Map<int, List<dynamic>>?> GerarSugestoes(
      String tipoMidia, List<int> generos) async {
    return _suggestion.GerarSugestoes(tipoMidia, generos);
  }

  Future<DocumentSnapshot?> GetSuggestions(userId) async {
    return _suggestion.GetSuggestions(userId);
  }

  Future<void> SetSuggestions(userId,  List<Map<String, dynamic>>? filmes, List<Map<String, dynamic>>? series) async {
    _suggestion.SetSuggestions(userId, filmes, series);
  }

  Future<List<Map<String, dynamic>>> FormatarDadosParaFirestore(
      Map<int,List<dynamic>>? sugestoesPorGenero) async {
    return _suggestion.FormatarDadosParaFirestore(sugestoesPorGenero);
  }

  Future<Widget?> CarregarSugestoes(
      Suggestion? sugestoes, List<PersonalizedSuggestion>? sugestoesPersonalizadas, BuildContext context) async {
    return _suggestion.CarregarSugestoes(sugestoes, sugestoesPersonalizadas, context);
  }
}
