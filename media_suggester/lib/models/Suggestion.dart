import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/models/Media.dart';
import 'package:media_suggester/models/PersonalizedSuggestion.dart';

import '../controller/media_controller.dart';
import '../widgets/CardWidget.dart';
import 'MediaSimplified.dart';
import 'SuggestionsByGenre.dart';

class Suggestion {
  List<dynamic>? filmes;
  List<dynamic>? series;

  MediaController? _mediaController = new MediaController();

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

  Future<void> SetSuggestions(userId, List<Map<String, dynamic>>? filmes,
      List<Map<String, dynamic>>? series) async {
    await FirebaseFirestore.instance.collection('suggestions').doc(userId).set({
      'filmes': filmes,
      'series': series,
    });
  }

  Future<Map<int, List<dynamic>>?> GerarSugestoes(
      String tipoMidia, List<int> generos) async {
    Map<int, List<int>> sugestoes = new Map<int, List<int>>();
    for (int genero in generos) {
      List<dynamic>? midiasDoGenero =
          await _mediaController?.getBestMediasOfTheGenre(genero, tipoMidia);

      sugestoes[genero] =
          midiasDoGenero!.map((midia) => midia["id"] as int).toList();
    }

    return sugestoes;
  }

  Future<List<Map<String, dynamic>>> FormatarDadosParaFirestore(
      Map<int, List<dynamic>>? sugestoesPorGenero) async {
    List<Map<String, dynamic>> formattedSugestoes = [];
    try {
      if (sugestoesPorGenero!.isEmpty) {
        print("Nenhuma sugestão disponível.");
        return [];
      }

      sugestoesPorGenero.forEach((generoId, midias) {
        String generoIdStr = generoId.toString();

        List<Map<String, dynamic>> midiaRegistros = midias.map((midia) {
          return {
            'id': midia.toString(),
          };
        }).toList();

        formattedSugestoes.add({
          generoIdStr: midiaRegistros,
        });
      });

      print("Sugestões formatadas: $formattedSugestoes");
      return formattedSugestoes;
    } catch (e) {
      print("Erro ao formatar sugestões: $e");
      return formattedSugestoes;
    }
  }

  Future<Widget?> CarregarSugestoes(
      Suggestion? sugestoes,
      List<PersonalizedSuggestion>? sugestoesPersonalizadas,
      BuildContext context) async {
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
        List<Widget> sugestoesPersonalizadasWidgets = [];

        var generosFilmes = await _media.fetchGeneros(firstAirDate: null);
        var generosSeries = await _media.fetchGeneros(firstAirDate: "123");

        //Suggestões Personalizadas
        if (sugestoesPersonalizadas != null &&
            sugestoesPersonalizadas.isNotEmpty) {
          for (var sugestao in sugestoesPersonalizadas) {
            Map<String, dynamic> mediaInfo = (await _media.getMidia(
                sugestao.likedMediaId.toString(),
                sugestao.typeOfLikedMedia!))[0] as Map<String, dynamic>;
            String? likedMediaTitle = sugestao.typeOfLikedMedia == "movie"
                ? mediaInfo['title']
                : mediaInfo['original_name'];

            List<Map<String, dynamic>> sugestoesTranformadasEmMidia = [];

            for (int midiaId in sugestao.suggestionIds!) {
              var dicionarioMidia = (await _media.getMidia(
                      midiaId.toString(), sugestao.typeOfLikedMedia!))[0]
                  as Map<String, dynamic>;
              Map<String, dynamic> midia = {
                'id': int.parse(dicionarioMidia['id'].toString()),
                'poster_path': dicionarioMidia['poster_path'],
                'vote_average': dicionarioMidia['vote_average'],
                'overview': dicionarioMidia['overview'],
                'genre_ids': dicionarioMidia['genres']
                        .map((genre) => genre['id'])
                        .toList() ??
                    [],
                'original_name': dicionarioMidia['original_name'],
                'first_air_date': dicionarioMidia['first_air_date'],
              };
              sugestoesTranformadasEmMidia.add(midia);
            }

            // Gerar carrossel para as sugestões personalizadas
            List<Widget> midiasWidgets = [];
            for (var midia in sugestoesTranformadasEmMidia) {
              var card = _card.ObterCard(
                context,
                midia,
                midia['poster_path'],
              );
              midiasWidgets.add(card);
            }

            var carrouselSugestao = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 8.0, bottom: 0.0, top: 10.0),
                  child: Text(
                    "Porque você gostou de '$likedMediaTitle'",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    aspectRatio: 16 / 9,
                    viewportFraction: 1 / 3,
                    enlargeCenterPage: false,
                  ),
                  items: midiasWidgets,
                ),
                const SizedBox(height: 20),
              ],
            );

            sugestoesPersonalizadasWidgets.add(carrouselSugestao);
          }
        }

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
              if (sugestoesPersonalizadas!.isNotEmpty) ...[
                const SizedBox(height: 32.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Divider(
                      height: 20,
                      thickness: 5,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.white60,
                    ),
                    const SizedBox(height: 32.0),
                    Text("PARA VOCÊ",
                        style: TextStyle(
                          fontSize: 50,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        )),
                  ],
                ),
                const SizedBox(height: 16.0),
                Column(children: sugestoesPersonalizadasWidgets),
              ],
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
