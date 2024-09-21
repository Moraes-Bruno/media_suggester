import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/models/Media.dart';

import '../widgets/CardWidget.dart';
import 'MediaSimplified.dart';
import 'SuggestionsByGenre.dart';

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
    return Suggestion(filmes, series);
  }

  Future<DocumentSnapshot?> GetSuggestions(userId) async {
    return FirebaseFirestore.instance
        .collection("suggestions")
        .doc(userId)
        .get();
  }

  Future<void> SetSuggestions(userId, filmes, series) async {
    FirebaseFirestore.instance.collection('suggestions').doc(userId).set({
      'filmes': filmes,
      'series': series,
    });
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
          print('Erro na requisição POST: ${resposta.statusCode}');
          print(resposta.body);
        }
      } catch (erro) {
        print('Erro ao fazer requisição POST: $erro');
      }
    }
    return null;
  }

  Future<List<SugestoesPorGenero>?>
      verificarSeApiPossuiDadosDasSugestoesGeradas(
          List<dynamic> sugestoesGeradas,
          List<Map<String, dynamic>> preferencias,
          String tipoMidia) async {
    Media _media = Media();
    List<SugestoesPorGenero>? sugestoesPorGeneroValidadas = [];
    final List<int?> midiasAdicionadas = [];
    try {
      List<SugestoesPorGenero> sugestoesPorGenero =
          SugestoesPorGenero.fromJsonList(sugestoesGeradas);

      for (SugestoesPorGenero listaSugestoes in sugestoesPorGenero) {
        List<Midia> midiasDoGenero = [];
        for (Midia midia in listaSugestoes.midias) {
          var midias = await _media.searchMedia(midia.titulo!);
          if (midias.isNotEmpty) {
            var m = midias.firstWhere(
                (m) =>
                    (m['title'] == midia.titulo ||
                        m['original_title'] == midia.titulo ||
                        m['name'] == midia.titulo ||
                        m['original_name'] == midia.titulo) &&
                    m['media_type'] == tipoMidia &&
                    !midiasAdicionadas
                        .contains(m["id"]) && //para não repetir mídias
                    m["poster_path"] != null,
                orElse: () => null);
            if (m != null) {
              midiasDoGenero.add(Midia(
                  titulo: m["title"] ?? m["name"] ?? m['original_name'] ?? '',
                  ondeAssistir: midia.ondeAssistir,
                  id: m["id"] ?? 0));
              midiasAdicionadas.add(m["id"]);
            }
          }
        }
        sugestoesPorGeneroValidadas.add(SugestoesPorGenero(
            idGenero: preferencias.firstWhere(
                (preferencia) =>
                    preferencia['name'] == listaSugestoes.nomeGenero,
                orElse: () => {'id': null})['id'],
            nomeGenero: listaSugestoes.nomeGenero,
            midias: midiasDoGenero));
      }

      return sugestoesPorGeneroValidadas;

    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> FormatarDadosParaFirestore(
      List<SugestoesPorGenero>? sugestoesPorGenero) async {
    List<Map<String, dynamic>> formattedSugestoes = [];
    try {
      if (sugestoesPorGenero == null) return [];

      Map<int, List<Midia>> meuMapa = {};

      for (SugestoesPorGenero genero in sugestoesPorGenero) {
        List<Midia> midiaRegistros = [];
        for (Midia midia in genero.midias) {
          midiaRegistros.add(
            Midia(
              id: midia.id as int,
              ondeAssistir: midia.ondeAssistir,
            ),
          );
        }
        meuMapa[genero.idGenero!] = midiaRegistros;
      }

      meuMapa.forEach((generoId, midias) {
        Map<String, dynamic> generoMap = {
          generoId.toString(): midias
              .map((midia) => {
                    'id': midia.id.toString(),
                    'ondeAssistir': midia.ondeAssistir,
                  })
              .toList(),
        };
        formattedSugestoes.add(generoMap);
      });

      return formattedSugestoes;

    } catch (e) {
      print(e);
      return formattedSugestoes;
    }
  }

  Future<Widget?> CarregarSugestoes(
      Suggestion? sugestoes, BuildContext context) async {
    CardWidget _card = CardWidget();
    Media _media = Media();
    try {
      if (sugestoes == null) return const SizedBox.shrink();
      int filmeIndex = 0;
      const int filmesBatchSize = 10;
      List<Map<String, dynamic>> postersFilmes = [];
      List<Future<List<dynamic>>> filmesBatch = [];
      while (filmeIndex < sugestoes.filmes!.length) {
        for (int i = 0;
            i < filmesBatchSize && filmeIndex < sugestoes.filmes!.length;
            i++) {
          Map<String, dynamic> generoMap = sugestoes.filmes![filmeIndex];
          generoMap.forEach((generoId, midias) {
            int i = 0;
            for (Map<String, dynamic> midia in midias) {
              filmesBatch.add(
                _media.getMidia(midia['id'].toString(), "movie").then((m) {
                  Map<String, dynamic> midiaCopia = {
                    'id': int.parse(m[i]['id'].toString()),
                    'poster_path': m[i]['poster_path'],
                    'vote_average': m[i]['vote_average'],
                    'overview': m[i]['overview'],
                    'genre_ids': m[i]['genres'].map((genre) {
                          return genre['id'];
                        }).toList() ??
                        [],
                    'title': m[i]['title'],
                    'release_date': m[i]['release_date'],
                    'onde_assistir': midia['ondeAssistir']
                  };
                  postersFilmes.add(midiaCopia);
                  return m;
                }),
              );
            }
          });
          filmeIndex++;
        }
        await Future.wait(filmesBatch);
        filmesBatch.clear();
      }

      int serieIndex = 0;
      const int seriesBatchSize = 10;
      List<Map<String, dynamic>> postersSeries = [];
      List<Future<List<dynamic>>> seriesBatch = [];
      while (serieIndex < sugestoes.series!.length) {
        for (int i = 0;
            i < seriesBatchSize && serieIndex < sugestoes.series!.length;
            i++) {
          Map<String, dynamic> generoMap = sugestoes.series![serieIndex];
          generoMap.forEach((generoId, midias) {
            int i = 0;
            for (Map<String, dynamic> midia in midias) {
              seriesBatch.add(
                _media.getMidia(midia['id'].toString(), "tv").then((m) {
                  Map<String, dynamic> midiaCopia = {
                    'id': int.parse(m[i]['id'].toString()),
                    'poster_path': m[i]['poster_path'],
                    'vote_average': m[i]['vote_average'],
                    'overview': m[i]['overview'],
                    'genre_ids': m[i]['genres'].map((genre) {
                          return genre['id'];
                        }).toList() ??
                        [],
                    'original_name': m[i]['original_name'],
                    'first_air_date': m[i]['first_air_date'],
                    'onde_assistir': midia['ondeAssistir']
                  };
                  postersSeries.add(midiaCopia);
                  return m;
                }),
              );
            }
          });
          serieIndex++;
        }
        await Future.wait(seriesBatch);
        seriesBatch.clear();
      }

      if (context.mounted) {
        List<Widget> filmesWidgets = [];
        List<Widget> seriesWidgets = [];

        var generosFilmes = await _media.fetchGeneros(firstAirDate: null);
        var generosSeries = await _media.fetchGeneros(firstAirDate: "123");

        for (var midiasDoGenero in sugestoes.filmes!) {
          midiasDoGenero.forEach((key, value) {
            List<Widget> midias = [];
            for (var midia in value) {
              String id = midia['id'];
              String posterPath = postersFilmes
                  .where((m) => m['id'].toString() == id)
                  .first['poster_path'];
              var card = _card.ObterCard(
                  context,
                  postersFilmes.where((m) => m['id'].toString() == id).first,
                  posterPath);
              midias.add(card);
            }

            var nomeGenero = generosFilmes[int.parse(key)];

            var carrouselFilme = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 0.0, top: 10.0),
                  child: Text(
                    "$nomeGenero",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                    ),
                  ),
                ),
                CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      viewportFraction: 1 / 3,
                      enlargeCenterPage: false,
                    ),
                    items: midias),
                const SizedBox(height: 20),
              ],
            );
            filmesWidgets.add(carrouselFilme);
          });
        }

        for (var midiasDoGenero in sugestoes.series!) {
          midiasDoGenero.forEach((key, value) {
            List<Widget> midias = [];
            for (var midia in value) {
              String? id = midia['id'];
              String? posterPath = postersSeries
                  .where((m) => m['id'].toString() == id)
                  .first['poster_path'];
              var card = _card.ObterCard(
                  context,
                  postersSeries.where((m) => m['id'].toString() == id).first,
                  posterPath!);
              midias.add(card);
            }

            var nomeGenero = generosSeries[int.parse(key)];

            var carrouselSerie = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 0.0, top: 10.0),
                  child: Text(
                    "$nomeGenero",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                    ),
                  ),
                ),
                CarouselSlider(
                    options: CarouselOptions(
                      aspectRatio: 16 / 9,
                      viewportFraction: 1 / 3,
                      enlargeCenterPage: false,
                    ),
                    items: midias),
                const SizedBox(height: 20),
              ],
            );
            seriesWidgets.add(carrouselSerie);
          });
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "FILMES",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              filmesWidgets.isNotEmpty
                  ? Column(children: filmesWidgets)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Não encontramos nada...",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                              ),
                            ),
                            Image(
                                image: AssetImage(
                                    'assets/images/nenhum-dado-encontrado.png'),
                                height: 300,
                                width: 300)
                          ],
                        ),
                      ],
                    ),
              //...filmesWidgets,
              const SizedBox(height: 64.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("SÉRIES",
                      style: TextStyle(
                        fontSize: 50,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      )),
                ],
              ),
              const SizedBox(height: 16.0),
              seriesWidgets.isNotEmpty
                  ? Column(children: seriesWidgets)
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              "Não encontramos nada...",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 20,
                              ),
                            ),
                            Image(
                                image: AssetImage(
                                    'assets/images/nenhum-dado-encontrado.png'),
                                height: 300,
                                width: 300)
                          ],
                        ),
                      ],
                    ),
              //...seriesWidgets,
              const SizedBox(height: 32.0),
            ],
          ),
        );

      } else {
        return const SizedBox.shrink();
      }
    } catch (e) {
      print('Erro ao carregar dados das recomendações: $e');
      return const SizedBox.shrink();
    }
  }
}
