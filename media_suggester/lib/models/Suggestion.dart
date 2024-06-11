import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  List<dynamic>? filmes;
  List<dynamic>? series;

  Suggestion(this.filmes, this.series);

  factory Suggestion.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return Suggestion(
      snapshot.get('filmes') as List<dynamic>,
      snapshot.get('series') as List<dynamic>,
    );
  }

  factory Suggestion.fromGeneratedInput(
      List<dynamic> filmes, List<dynamic> series) {
    return Suggestion(
      filmes,
      series
    );
  }
  Future<List<dynamic>?> GerarSugestoes(
      String tipoMidia, String generos) async {
    var url = Uri.parse('https://mediasuggesterapi.azurewebsites.net/');

    var request = {"tipoMidia": tipoMidia, "generos": generos};

    print("Tentando gerar sugestões...");
    bool sugestoesNaoGeradas = true;
    while (sugestoesNaoGeradas) {
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
          sugestoesNaoGeradas = false;

          Map<String, dynamic> respostaMapa = json.decode(resposta.body);

          var midias = respostaMapa['midias'];
          return midias as List<dynamic>;
        } else {
          // Requisição falhou
          print('Erro na requisição POST: ${resposta.statusCode}');
          print(resposta.body);
        }
      } catch (erro) {
        // Tratar erros de requisição
        print('Erro ao fazer requisição POST: $erro');
      }
    }
  }
}
