import 'dart:convert';
import 'package:http/http.dart' as http;

class MediaRepository {

  String chaveApi = "68df955e186472a00f82954f57d23073";
  final String urlBase = 'https://api.themoviedb.org/3';


  Future<List<dynamic>> getMediaGenero(int generoId, String tipoMedia) async {
    final String url =
        '$urlBase/discover/$tipoMedia?api_key=$chaveApi&language=pt-BR&with_genres=$generoId&append_to_response=genres';

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

  Future<Map<int, String>> fetchGeneros({String? firstAirDate}) async {
    final bool tv = firstAirDate != null;

    final response = await http.get(
      //se a media for series adiciona "tv" a url se não for adiciona "media" a mesma
      Uri.parse('$urlBase/genre/${tv ? 'tv' : 'movie'}/list?api_key=$chaveApi&language=pt-BR'),
    );

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final Map<int, String> genreMap = {};
      for (var genre in decodedResponse['genres']) {
        genreMap[genre['id']] = genre['name'];
      }
      return genreMap;
    } else {
      throw Exception('Failed to load genres');
    }
  }


}
