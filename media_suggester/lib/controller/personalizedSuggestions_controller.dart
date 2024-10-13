import 'package:flutter/material.dart';
import 'package:media_suggester/models/PersonalizedSuggestion.dart';

class PersonalizedSuggestionController extends PageController {
  final PersonalizedSuggestion _pesonalizedSuggestion =
      PersonalizedSuggestion(null, null, null, null);

  Future<List<PersonalizedSuggestion>?> GetPersonalizedSuggestions(
      userId) async {
    return await _pesonalizedSuggestion.GetPersonalizedSuggestions(userId);
  }

  Future<void> GerarSugestoesPersonalizadasParaReview(String tipoMidia, String likedMediaId,
      String userId, String reviewText) async {
    return _pesonalizedSuggestion.GerarSugestoesPersonalizadasParaReview(
        tipoMidia, likedMediaId, userId, reviewText);
  }

  Future<void> GerarSugestoesPersonalizadasParaFavorito(String tipoMidia, int likedMediaId,
      String userId) async {
    return _pesonalizedSuggestion.GerarSugestoesPersonalizadasParaFavorito(
        tipoMidia, likedMediaId, userId);
  }

  Future<void> DeletePersonalizedSuggestion(
      int likedMediaId, String userId) async {
    await _pesonalizedSuggestion.DeletePersonalizedSuggestion(
        likedMediaId, userId);
  }
}
