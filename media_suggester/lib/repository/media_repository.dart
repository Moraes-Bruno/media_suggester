import 'dart:convert';
import 'package:http/http.dart' as http;

class MediaRepository {
  String chaveApi = "68df955e186472a00f82954f57d23073";
  final String urlBase = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> getMediaGenero(int generoId, String tipoMedia) async {
    final String url =
        '$urlBase/discover/$tipoMedia?api_key=$chaveApi&language=pt-BR&with_genres=$generoId';

    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resposta.body);
      return data['results'];
    } else {
      throw Exception('Falha ao buscar Conteudo');
    }
  }

   Future<List<dynamic>> pesquisarMedia(String pesquisa) async {
    final String url =
        '$urlBase/search/multi?api_key=$chaveApi&language=pt-BR&query=$pesquisa';

    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resposta.body);
      return data['results'];
    } else {
      throw Exception('Falha ao buscar Conteudo');
    }
  }

  
}
