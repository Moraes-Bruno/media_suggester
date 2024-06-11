import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/controller/suggestion_controller.dart';
import 'package:media_suggester/controller/user_controller.dart';
import 'package:media_suggester/models/Suggestion.dart';
import 'package:media_suggester/views/genre_movie.dart';
import 'package:media_suggester/views/perfil.dart';
import 'package:media_suggester/views/pesquisa.dart';
import 'package:media_suggester/views/reviews.dart';
import 'package:media_suggester/models/Media.dart';

import '../models/SuggestionsByGenre.dart';

class Home extends StatefulWidget {
  Home(this.user, {super.key});

  User user;

  @override
  State<Home> createState() => _HomeState(user);
}

class _HomeState extends State<Home> {
  final Media _media = Media();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Widget? _body;
  Image _carregandoImagem = const Image(
      image: AssetImage("assets/images/carregando-dados.png"),
      height: 400,
      width: 200);
  String _carregandoTexto = "Carregando dados, por favor aguarde...";
  UserController _userController = UserController();
  SuggestionController _suggestionController = SuggestionController();

  _HomeState(this.user);

  User user;

  @override
  void initState() {
    super.initState();

    //Verificando se usuário já tem preferências, para poder redirecionar
    // no caso de não ter e ter entrado direto na home por algum motivo
    _userController.HasPreferences(user.uid).then((hasPreferences) {
      if (!hasPreferences) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Genre_movie()));
      }
    });

    carregarSugestoes(user);
  }

  Future<void> carregarSugestoes(User? user) async {
    try {
      Suggestion sugestoes;
      _userController.HasSuggestions(user!.uid).then((hasSuggestions) async {
        if (!hasSuggestions) {
          setState(() {
            _carregandoImagem = const Image(
                image: AssetImage("assets/images/carregando-sugestoes.png"),
                height: 500,
                width: 400);
            _carregandoTexto =
                "Por favor aguarde enquanto geramos recomendações especiais para você...";
          });

          //aqui eu trago do banco as preferencias
          DocumentSnapshot? preferences =
              await _userController.GetPreferences(user.uid);

          List<Map<String, dynamic>> preferencias_filmes =
              List<Map<String, dynamic>>.from(
                  preferences!.get('genders_movie') ?? []);
          List<Map<String, dynamic>> preferencias_series =
              List<Map<String, dynamic>>.from(
                  preferences!.get('genders_serie') ?? []);

          List<dynamic> sugestoes_series =
              await _suggestionController.GerarSugestoes(
                      "series",
                      preferencias_series
                          .map((serie) => serie['name'])
                          .join(', ')) ??
                  [];
          print(sugestoes_series);

          List<dynamic> sugestoes_filmes =
              await _suggestionController.GerarSugestoes(
                      "filmes",
                      preferencias_filmes
                          .map((filme) => filme['name'])
                          .join(', ')) ??
                  [];
          print(sugestoes_filmes);

          //verificando se as mídias recomendadas existem na api do themoviedb

          List<SugestoesPorGenero>? sugestoesSeriesValidadas =
              await _suggestionController
                  .VerificarSeApiPossuiDadosDasSugestoesGeradas(
                      sugestoes_series, preferencias_series, "tv");

          List<SugestoesPorGenero>? sugestoesFilmesValidadas =
              await _suggestionController
                  .VerificarSeApiPossuiDadosDasSugestoesGeradas(
                      sugestoes_filmes, preferencias_filmes, "movie");

          setState(() {
            _carregandoTexto = "Quase lá...";
          });

          List<Map<String, dynamic>> sugestoesFilmesFormatadasParaRegistro =
              await _suggestionController.FormatarDadosParaFirestore(
                  sugestoesFilmesValidadas);
          print(sugestoesFilmesFormatadasParaRegistro);

          List<Map<String, dynamic>> sugestoesSeriesFormatadasParaRegistro =
              await _suggestionController.FormatarDadosParaFirestore(
                  sugestoesSeriesValidadas);
          print(sugestoesSeriesFormatadasParaRegistro);

          try {
            //Salvando recomendações validadas no firebase
            await _suggestionController.SetSuggestions(
                user.uid,
                sugestoesFilmesFormatadasParaRegistro,
                sugestoesSeriesFormatadasParaRegistro);
          } catch (e) {
            print(e);
          }
          sugestoes = Suggestion.fromGeneratedInput(
              sugestoesFilmesFormatadasParaRegistro,
              sugestoesSeriesFormatadasParaRegistro);
        } else {
          DocumentSnapshot? suggestionSnapshot =
              await _suggestionController.GetSuggestions(user.uid);

          sugestoes = Suggestion.fromDocumentSnapshot(suggestionSnapshot!);
        }
        setState(() {
          _suggestionController.CarregarSugestoes(sugestoes, context)
              .then((response) {
            _body = response;
            setState(() {}); //refresh
          });
        });
      });
    } catch (e) {
      print(e);
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
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height -
            kToolbarHeight -
            kBottomNavigationBarHeight,
        child: _body ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _carregandoImagem,
                Text(
                  _carregandoTexto,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 10, left: 25, right: 25),
                  child: LinearProgressIndicator(minHeight: 15),
                )
              ],
            ),
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
}
