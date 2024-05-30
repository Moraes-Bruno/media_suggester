import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:media_suggester/models/Suggestion.dart';
import 'package:media_suggester/pages/Detalhes.dart';
import 'package:media_suggester/pages/perfil.dart';
import 'package:media_suggester/pages/pesquisa.dart';
import 'package:media_suggester/pages/reviews.dart';
import 'package:media_suggester/repository/media_repository.dart';
import 'package:media_suggester/repository/suggestion_repository.dart';

import '../models/SugestoesPorGenero.dart';
import '../models/Midia.dart';

class Home extends StatefulWidget {
  Home(this.user, {super.key});

  User? user;

  @override
  State<Home> createState() => _HomeState(user);
}

class _HomeState extends State<Home> {
  final MediaRepository _mediaRepository = MediaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget? _body;

  _HomeState(this.user);

  User? user;

  @override
  void initState() {
    super.initState();
    carregarSugestoes(user);
  }

  Future<void> carregarSugestoes(User? user) async {
    try {
      Suggestion sugestoes;
      verificarExisteRecomendacoes(user!.uid).then((value) async {
        if (!value) {
          //aqui eu trago do banco as preferencias
          DocumentSnapshot preferences = await FirebaseFirestore.instance
              .collection("preferences")
              .doc(user.uid)
              .get();

          List<Map<String, dynamic>> preferencias_filmes =
              List<Map<String, dynamic>>.from(
                  preferences.get('genders_movie') ?? []);
          List<Map<String, dynamic>> preferencias_series =
              List<Map<String, dynamic>>.from(
                  preferences.get('genders_serie') ?? []);

          SuggestionRepository suggestionRepository =
              new SuggestionRepository();

          List<dynamic>? sugestoes_series =
              await suggestionRepository.GerarSugestoes("series",
                  preferencias_series.map((serie) => serie['name']).join(', '));
          print(sugestoes_series);

          List<dynamic>? sugestoes_filmes =
              await suggestionRepository.GerarSugestoes("filmes",
                  preferencias_filmes.map((filme) => filme['name']).join(', '));
          print(sugestoes_filmes);

          //verificando se as mídias recomendadas existem na api do themoviedb

          List<SugestoesPorGenero>? sugestoesSeriesValidadas =
              await verificarSeApiPossuiDadosDasSugestoesGeradas(
                  sugestoes_series!, preferencias_series, "tv");

          List<SugestoesPorGenero>? sugestoesFilmesValidadas =
              await verificarSeApiPossuiDadosDasSugestoesGeradas(
                  sugestoes_filmes!, preferencias_filmes, "movie");

          List<Map<String, dynamic>> sugestoesFilmesFormatadasParaRegistro =
              await formatarParaFirestore(sugestoesFilmesValidadas);
          print(sugestoesFilmesFormatadasParaRegistro);

          List<Map<String, dynamic>> sugestoesSeriesFormatadasParaRegistro =
              await formatarParaFirestore(sugestoesSeriesValidadas);
          print(sugestoesSeriesFormatadasParaRegistro);

          try {
            //Salvando recomendações validadas no firebase
            await _firestore.collection('suggestions').doc(user.uid).set({
              'filmes': sugestoesFilmesFormatadasParaRegistro,
              'series': sugestoesSeriesFormatadasParaRegistro,
            });
          } catch (e) {
            print(e);
          }
          print(5);
          sugestoes = Suggestion.fromGeneratedInput(
              sugestoesFilmesFormatadasParaRegistro,
              sugestoesSeriesFormatadasParaRegistro);
        } else {
          DocumentSnapshot suggestionSnapshot = await FirebaseFirestore.instance
              .collection("suggestions")
              .doc(user!.uid)
              .get();

          sugestoes = Suggestion.fromDocumentSnapshot(suggestionSnapshot);
        }

        setState(() async {
          _carregarMedias(sugestoes).then((response) {
            _body = response;
            setState(() {}); //refresh
          }); // Carregue os dados da API ao inicializar a tela
        });
      });
    } catch (e) {
      print(e);
    }
  }

  Future<List<SugestoesPorGenero>?>
      verificarSeApiPossuiDadosDasSugestoesGeradas(
          List<dynamic> sugestoesGeradas,
          List<Map<String, dynamic>> preferencias,
          String tipoMidia) async {
    List<SugestoesPorGenero>? sugestoesPorGeneroValidadas = [];
    try {
      List<SugestoesPorGenero> sugestoesPorGenero =
          SugestoesPorGenero.fromJsonList(sugestoesGeradas);

      for (SugestoesPorGenero listaSugestoes in sugestoesPorGenero) {
        List<Midia> midiasDoGenero = []; // Inicialize a lista aqui
        for (Midia midia in listaSugestoes.midias) {
          var midias = await _mediaRepository.searchMedia(midia.titulo!);
          if (midias.isNotEmpty) {
            var m = midias.firstWhere(
                (m) =>
                    (m['title'] == midia.titulo || m['name'] == midia.titulo) &&
                    m['media_type'] == tipoMidia,
                orElse: () => null);
            if (m != null) {
              midiasDoGenero.add(Midia(
                  titulo: m["title"] ?? m["name"] ?? '',
                  ondeAssistir: midia.ondeAssistir,
                  id: m["id"] ?? 0));
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

  Future<List<Map<String, dynamic>>> formatarParaFirestore(
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

  Future<Widget?> _carregarMedias(Suggestion? sugestoes) async {
    try {
      if (sugestoes == null) return SizedBox.shrink();
      print("carregando dados...");
      print(sugestoes.filmes);
      print(sugestoes.series);
      // Carrega os filmes em lotes
      int filmeIndex = 0;
      const int filmesBatchSize = 10;
      List<Map<String, dynamic>> postersFilmes = [];
      List<Future<List<dynamic>>> filmesBatch = [];
      while (filmeIndex < sugestoes.filmes.length) {
        for (int i = 0;
            i < filmesBatchSize && filmeIndex < sugestoes.filmes.length;
            i++) {
          Map<String, dynamic> generoMap = sugestoes.filmes[filmeIndex];
          generoMap.forEach((generoId, midias) {
            int i = 0;
            for (Map<String, dynamic> midia in midias) {
              filmesBatch.add(
                _mediaRepository
                    .getMidia(midia['id'].toString(), "movie")
                    .then((m) {
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

      // Carrega as séries em lotes
      int serieIndex = 0;
      const int seriesBatchSize = 10;
      List<Map<String, dynamic>> postersSeries = [];
      List<Future<List<dynamic>>> seriesBatch = [];
      while (serieIndex < sugestoes.series.length) {
        for (int i = 0;
            i < seriesBatchSize && serieIndex < sugestoes.series.length;
            i++) {
          Map<String, dynamic> generoMap = sugestoes.series[serieIndex];
          generoMap.forEach((generoId, midias) {
            int i = 0;
            for (Map<String, dynamic> midia in midias) {
              seriesBatch.add(
                _mediaRepository
                    .getMidia(midia['id'].toString(), "tv")
                    .then((m) {
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

      if (mounted) {
        print("depois das variáveis future");
        List<Widget> filmesWidgets = [];
        List<Widget> seriesWidgets = [];

        var generosFilmes =
            await _mediaRepository.fetchGeneros(firstAirDate: null);
        var generosSeries =
            await _mediaRepository.fetchGeneros(firstAirDate: "123");

        // Iterar sobre os mapas de gêneros
        for (var midiasDoGenero in sugestoes.filmes) {
          midiasDoGenero.forEach((key, value) {
            List<Widget> midias = [];
            for (var midia in value) {
              String id = midia['id'];
              String posterPath = postersFilmes
                  .where((m) => m['id'].toString() == id)
                  .first['poster_path'];
              var card = _ObterCard(
                  context,
                  postersFilmes.where((m) => m['id'].toString() == id).first,
                  posterPath);
              midias.add(card);
            }

            var nomeGenero = generosFilmes[int.parse(key)];

            //Criar um carrousel para as mídias do gênero
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
                SizedBox(height: 20),
              ],
            );
            filmesWidgets.add(carrouselFilme);
          });
        }

        for (var midiasDoGenero in sugestoes.series) {
          midiasDoGenero.forEach((key, value) {
            List<Widget> midias = [];
            for (var midia in value) {
              String id = midia['id'];
              //String ondeAssistir = midia['ondeAssistir'];
              String posterPath = postersSeries
                  .where((m) => m['id'].toString() == id)
                  .first['poster_path'];
              var card = _ObterCard(
                  context,
                  postersSeries.where((m) => m['id'].toString() == id).first,
                  posterPath);
              midias.add(card);
            }

            var nomeGenero = generosSeries[int.parse(key)];

            //Criar um carrousel para as mídias do gênero
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
                SizedBox(height: 20),
              ],
            );
            seriesWidgets.add(carrouselSerie);
          });
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seção de Filmes
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
              SizedBox(height: 16.0),
              ...filmesWidgets,
              SizedBox(height: 64.0),
              // Seção de Séries
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
              SizedBox(height: 16.0),
              ...seriesWidgets,
            ],
          ),
        );
      } else {
        return SizedBox.shrink();
      }
    } catch (e) {
      print('Erro ao carregar dados das recomendações: $e');
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "HOME",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Perfil(),
                        ),
                      );
                    },
                    icon: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30),
                    padding: const EdgeInsetsDirectional.all(8.0),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight,
        child: _body == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              )
            : _body,
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Pesquisa(),
            ),
          );
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.search),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        color: Theme.of(context).colorScheme.secondary,
        notchMargin: 5,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 45,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.event_note_sharp,
                color: Colors.white,
                size: 45,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Reviews(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ObterCard(
      BuildContext context, Map<String, dynamic> midia, String posterPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Detalhes(midia)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            'https://image.tmdb.org/t/p/w200/${posterPath}',
          ),
        ),
      ),
    );
  }

  Future<bool> verificarExisteRecomendacoes(String userId) async {
    try {
      DocumentSnapshot suggestions = await FirebaseFirestore.instance
          .collection("suggestions")
          .doc(userId)
          .get();
      return suggestions.exists;
    } catch (e) {
      return false;
    }
  }

  _carregarMidia(String id, String endpoint) async {
    Map<String, dynamic> midia =
        await _mediaRepository.getMidia(id, endpoint) as Map<String, dynamic>;
    return midia;
  }
}
