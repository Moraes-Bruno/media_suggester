import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/controller/media_controller.dart';
import 'package:media_suggester/controller/user_controller.dart';
import 'package:media_suggester/views/escrever_review.dart';
import 'package:media_suggester/views/review_unica.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class Detalhes extends StatefulWidget {
  final Map<String, dynamic> media;

  const Detalhes(this.media, {super.key});

  @override
  State<Detalhes> createState() => _DetalhesState();
}

class _DetalhesState extends State<Detalhes> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MediaController _mediaController = MediaController();
  final UserController _userController = UserController();
  late Future<QuerySnapshot<Map<String, dynamic>>> listReviews;

  Map<int, String> _generos = {};
  late Future<bool> isAdded;
  User? user;
  bool favoritado = false;
  String notaMedia = '';
  
  @override
  void initState() {
    super.initState();
    _fetchGeneros();
    user = _auth.currentUser;
    listReviews = _mediaController.fetchReviews(widget.media['id']);
    mudarIcone();
    mediaNota();
  }

  void mudarIcone() async{
    bool isfavoritado = await _userController.checkFavorito(widget.media['title'] ?? widget.media['original_name'],user!.uid);
    setState(() {
      favoritado = isfavoritado;
    });
  }


  Future<void> _fetchGeneros() async {
    final firstAirDate = widget.media['first_air_date'];
    final genres =
        await _mediaController.fetchGeneros(firstAirDate: firstAirDate);
    setState(() {
      _generos = genres;
    });
  }

  void mostrarMensagem(isAdded, BuildContext context) {
    if (isAdded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "${widget.media['title'] ?? widget.media['original_name']} foi adicionado com sucesso.",
                style: const TextStyle(fontSize: 19,fontWeight: FontWeight.bold),
              ),
            ),
          ),

          duration: const Duration(seconds: 2), // Define a duração do SnackBar
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                "${widget.media['title'] ?? widget.media['original_name']} foi removido com sucesso.",
                style: const TextStyle(fontSize: 19,fontWeight: FontWeight.bold),
              ),
            ),
          ),

          duration: const Duration(seconds: 2), // Define a duração do SnackBar
        ),
      );
    }
  }

  Future <void> mediaNota() async {
  String mediaNota = await _mediaController.getNotaMedia(widget.media['id']);
  setState(() {
    notaMedia = mediaNota;
  });
}

  @override
  Widget build(BuildContext context) {
    
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');

    DateTime dateTime = DateTime.parse(
        widget.media['release_date'] ?? widget.media['first_air_date']);

    String dataFormatada = dateFormat.format(dateTime);

    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: Text(
            widget.media['title'] ?? widget.media['original_name'] ?? '',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(children: [
                Container(
                  width: 450,
                  height: 260,
                  child: Image(
                    image: NetworkImage(
                        'https://image.tmdb.org/t/p/w400/${widget.media['poster_path']}'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(
                  height: 260,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(right: 10, left: 10, bottom: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              isAdded = _userController.Favoritar(
                                  widget.media['title'] ??
                                      widget.media['original_name'] ??
                                      '',
                                  user!.uid);
                              bool adicionado = await isAdded;
                              mudarIcone();
                              mostrarMensagem(adicionado, context);
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15)),
                            child: Icon(
                              // ignore: unrelated_type_equality_checks
                              favoritado == true ? Icons.favorite : Icons.favorite_border_outlined,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 25,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EscreverReview(widget.media)));
                            },
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(15),
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary),
                            child: Icon(
                              Icons.note_alt,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                              size: 25,
                            ),
                          ),
                        ]),
                  ),
                )
              ]),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      widget.media['title'] ??
                          widget.media['original_name'] ??
                          '',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dataFormatada,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6, // Espaçamento entre os gêneros
                      runSpacing: 8, // Espaçamento entre as linhas
                      children: [
                        for (var genero in widget.media['genre_ids'])
                          Text(
                            '| ${_generos[genero] ?? ''} |',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Críticos',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 16),
                              Text(
                                '|',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 16),
                              Text(
                                'Usuários',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.media['vote_average']
                                        .toStringAsFixed(1) +
                                    '/10',
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: 50),
                              Text(
                                '$notaMedia/5',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.media['overview'],
                        style: const TextStyle(fontSize: 20),
                        textAlign: TextAlign.justify,
                        maxLines: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                width: double.infinity,
                height: 180,
                color: const Color.fromARGB(255, 42, 42, 42),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Aonde Assistir:",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _procurarGoogle(widget.media['title'] ??
                                widget.media['original_name']);
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.transparent),
                            ),
                            child: Image.asset("assets/images/play-button.png",
                                width: 60, height: 60),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Ver Mais",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              FutureBuilder(
                future: listReviews,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      return  CarouselSlider(
                        items: _obterComentarios(context, snapshot),
                        options:  CarouselOptions(
                          aspectRatio: 2.0,
                          enlargeCenterPage: true,
                          pageViewKey:
                              const PageStorageKey<String>('carousel_slider'),
                        ),
                      );
                  }
                },
              ),
              const SizedBox(
                height: 15,
              )
            ],
          ),
        ));
  }

  Future<void> _procurarGoogle(String nomeFilme) async {
    //String mediaUri = Uri.encodeQueryComponent(nomeFilme);
    final Uri _url = Uri.parse('https://www.google.com/search?q=$nomeFilme');

    print(_url);

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  _obterComentarios(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> listReviewsTemp = [];
    List<Widget> widgets = [];
    try {
      listReviewsTemp = snapshot.data.docs;
    } catch (e) {
      widgets.add(Container());
      return widgets;
    }

    for (final review in listReviewsTemp) {
      String nota = "";
      for (var i = 0; i < review['nota']; i++) {
        nota += "★";
      }
      nota = nota.padRight(5, "☆");

      widgets.add(GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => ReviewUnica(review)));
        },
        child: Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width - 30,
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 42, 42, 42),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        FutureBuilder(
                            future: review['user'].get(),
                            builder: (context, snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                  return const Image(
                                    image: AssetImage(
                                        "assets/images/profile_placeholder.png"),
                                    height: 45,
                                    width: 45,
                                  );
                                default:
                                  return Container(
                                    width: 45,
                                    height: 45,
                                    child: Image(
                                      image: NetworkImage(
                                          (snapshot.data as DocumentSnapshot)
                                              .get("photoUrl")),
                                      height: 45,
                                      width: 45,
                                    ),
                                  );
                              }
                            }),

                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                                future: review['user'].get(),
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.none:
                                    case ConnectionState.waiting:
                                      return Container(
                                        color: Colors.white,
                                        height: 12,
                                        width: 50,
                                      );
                                    default:
                                      return SizedBox(
                                        width: 180,
                                        child: Text(
                                            (snapshot.data as DocumentSnapshot)
                                                .get("name"),
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      );
                                  }
                                }),
                            Text(
                              nota,
                              style: const TextStyle(fontSize: 20),
                            ),
                            SizedBox(
                              width: 180,
                              child: Text(
                                review['descricao'],
                                style: const TextStyle(
                                  fontSize: 20.0,
                                ),
                                textAlign: TextAlign.start,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(), // Adiciona um espaçamento flexível
                        Column(
                          children: [
                            Text(
                              DateFormat('dd/MM/yy\nHH:mm').format(
                                  DateTime.fromMicrosecondsSinceEpoch(
                                      review['criacao']
                                          .microsecondsSinceEpoch)),
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.end,
                            ),
                            const Text(""),
                            const Text(""),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ));
    }
    return widgets;
    
  }
}
