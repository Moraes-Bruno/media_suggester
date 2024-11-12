import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalizedSuggestion {
  String apiUrl = "https://mediasuggesterapiv2api20241112195901.azurewebsites.net";
  String? userId;
  int? likedMediaId;
  String? typeOfLikedMedia;
  List<int>? suggestionIds;

  PersonalizedSuggestion(this.userId, this.likedMediaId, this.typeOfLikedMedia,
      this.suggestionIds);

  factory PersonalizedSuggestion.fromDocumentSnapshot(
      DocumentSnapshot snapshot) {
    return PersonalizedSuggestion(
        snapshot.get('user_id') as String,
        snapshot.get('liked_media_id') as int,
        snapshot.get('typeof_liked_media') as String,
        List<int>.from(snapshot.get('suggestions')) as List<int>?);
  }

  Future<List<PersonalizedSuggestion>?> GetPersonalizedSuggestions(
      userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("personalized_suggestions")
        .where('user_id', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => PersonalizedSuggestion.fromDocumentSnapshot(doc))
        .toList();
  }

  Future<void> AddPersonalizedSuggestion(String userId, int likedMediaId,
      String typeOfLikedMedia, List<int> suggestionIds) async {
    await FirebaseFirestore.instance
        .collection('personalized_suggestions')
        .doc()
        .set({
      'user_id': userId,
      'liked_media_id': likedMediaId,
      'typeof_liked_media': typeOfLikedMedia,
      'suggestions': suggestionIds,
    });
  }

  Future<void> DeletePersonalizedSuggestion(
      int likedMediaId, String userId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("personalized_suggestions")
        .where('liked_media_id', isEqualTo: likedMediaId)
        .where('user_id', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }
  }

  Future<void> GerarSugestoesPersonalizadasParaFavorito(
      String tipoMidia, int likedMediaId, String userId) async {

    var url = Uri.parse("$apiUrl/api/Suggestion/SavePersonalizedSuggestionForFavorite");

    var request = {
      "UserId": userId,
      "MediaType": tipoMidia,
      "MediaId": likedMediaId,
    };

    print("Tentando gerar sugestões personalizadas para o favorito...");
    bool sugestoesForamGeradas = false;
    while (!sugestoesForamGeradas) {
      try {
        var resposta = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          },
          body: jsonEncode(request),
        );

        if (resposta.statusCode == 200) {
          sugestoesForamGeradas = true;
          print("Sugestões personalizadas gravadas no banco com sucesso.");
        } else {
          print('Erro na requisição POST. Código: ${resposta.statusCode}');
          print(resposta.body);
        }
      } catch (erro) {
        print('Erro tentar gerar sugestões personalizadas: $erro');
      }
    }
  }

  Future<void> GerarSugestoesPersonalizadasParaReview(String tipoMidia,
      String likedMediaId, String userId, String reviewText) async {
    var url = Uri.parse("$apiUrl/api/Suggestion/GeneratePersonalizedSuggestion");

    var request = {
      "MediaType": tipoMidia,
      "MediaId": likedMediaId,
      "UserId": userId,
      "ReviewText": reviewText
    };

    print("Tentando gerar sugestões personalizadas para a review...");
    bool sugestoesForamGeradas = false;
    while (!sugestoesForamGeradas) {
      try {
        var resposta = await http.post(
          url,
          headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
          },
          body: jsonEncode(request),
        );

        if (resposta.statusCode == 200) {
          sugestoesForamGeradas = true;
          print("A review foi processada com sucesso.");
        } else {
          print('Erro na requisição POST. Código: ${resposta.statusCode}');
          print(resposta.body);
        }
      } catch (erro) {
        print('Erro ao tentar processar a review: $erro');
      }
    }
  }
}
