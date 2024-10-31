import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  String chaveApi = "68df955e186472a00f82954f57d23073";

  final String urlBase = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> getMediaGenre(int generoId, String tipoMedia) async {
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

  Future<List<dynamic>> searchMedia(String pesquisa) async {
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

  Future<List<dynamic>> getMidia(String id, String endpoint) async {
    try {
      final String url =
          '$urlBase/$endpoint/$id?api_key=$chaveApi&language=pt-BR';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return [jsonData];
      } else {
        var stts = response.statusCode;
        print(url);
        throw Exception(
            'Falha ao carregar os dados da mídia. Status Code: $stts');
      }
    } catch (e) {
      print('Erro ao carregar os dados da mídia: $e');
      return Future.error('Erro ao carregar os dados da mídia');
    }
  }

  Future<Map<int, String>> fetchGeneros({String? firstAirDate}) async {
    final bool tv = firstAirDate != null;

    final response = await http.get(
      //se a media for series adiciona "tv" a url se não for adiciona "media" a mesma
      Uri.parse(
          '$urlBase/genre/${tv ? 'tv' : 'movie'}/list?api_key=$chaveApi&language=pt-BR'),
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

  //-----------------------Movie---------------------------------
  Future<List<dynamic>> fetchGenres_movie() async {
    final url =
        'https://api.themoviedb.org/3/genre/movie/list?api_key=$chaveApi&language=pt-BR';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body)['genres'];
    } else {
      throw Exception('Failed to load genres');
    }
  }

  //---------------------serie-----------------------------------
  Future<List<dynamic>> fetchGenres_serie() async {
    final url =
        'https://api.themoviedb.org/3/genre/tv/list?api_key=$chaveApi&language=pt-BR';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body)['genres'];
    } else {
      throw Exception('Failed to load genres');
    }
  }

  //---------------Detalhes.dart-------------------//
  Future<QuerySnapshot<Map<String, dynamic>>> fetchReviews(int mediaId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    return firestore
        .collection('reviews')
        .limit(10)
        .where('filmeId', isEqualTo: mediaId.toString())
        .get();
  }

  // Função para retornar a nota media da media de acordo com a nota dos usuarios
  Future<String> getNotaMedia(int filmeId) async {
  double valorTotal = 0;
  int totalReviews = 0;

  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('filmeId', isEqualTo: filmeId.toString())
        .get();

    if (snapshot.docs.isNotEmpty) {
      totalReviews = snapshot.docs.length;

      for (var doc in snapshot.docs) {
        var nota = doc.get('nota') as num;
        
        valorTotal += nota.toDouble(); 
      }
    }

    return (totalReviews > 0) 
      ? (valorTotal / totalReviews).toStringAsFixed(1) 
      : '0';
  } catch (e) {
    return '0';
  }
}

//função que vai "gerar as recomendações" padrão a partir de agora
  Future<List<dynamic>?> getBestMediasOfTheGenre(int generoId, String tipoMidia) async {

    final String url =
    '$urlBase/discover/$tipoMidia?api_key=$chaveApi&language=pt-BR&sort_by=popularity.desc&vote_average.gte=7&vote_count.gte=1000&with_genres=$generoId';

    final resposta = await http.get(Uri.parse(url));

    if (resposta.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(resposta.body);
      return data['results'];
    } else {
      throw Exception('Falha ao buscar Conteudo');
    }
  }
}
