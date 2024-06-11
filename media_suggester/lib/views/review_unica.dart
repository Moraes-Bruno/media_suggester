import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_suggester/models/Media.dart';

class ReviewUnica extends StatefulWidget {
  final dynamic review;

  const ReviewUnica(this.review, {super.key});

  @override
  State<ReviewUnica> createState() => _ReviewUnicaState();
}

class _ReviewUnicaState extends State<ReviewUnica> {
  final Media _media = Media();
  _carregarFilme(String filmeId) async {
    Map<String, dynamic> filme = (await _media.getMidia(
        filmeId, "movie"))[0] as Map<String, dynamic>;
    return filme;
  }

  Map<int, String> _generos = {};

  @override
  void initState() {
    super.initState();
    _fetchGeneros();
    print(widget.review['filmeId']);
  }

  Future<void> _fetchGeneros() async {
    final genres = await _media.fetchGeneros();
    setState(() {
      _generos = genres;
    });
  }

  @override
  Widget build(BuildContext context) {
    String nota = "";
    for (var i = 0; i < widget.review['nota']; i++) {
      nota += "★";
    }
    nota = nota.padRight(5, "☆");

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "REVIEW",
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
                    onPressed: () {},
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
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 25),
          //width: reviewQuery.of(context).size.width,
          child: FutureBuilder(
              future: widget.review['user'].get(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                      width: 200.0,
                      height: 200.0,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        strokeWidth: 5.0,
                      ),
                    );
                  default:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: NetworkImage(
                              (snapshot.data as DocumentSnapshot)
                                  .get("photoUrl")),
                          height: 200,
                          width: 200,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          (snapshot.data as DocumentSnapshot).get("name"),
                          style: const TextStyle(fontSize: 25),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            widget.review['descricao'],
                            style: const TextStyle(fontSize: 20),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        FutureBuilder(
                            future: _carregarFilme(widget.review["filmeId"]),
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
                                  DateFormat dateFormat =
                                      DateFormat('dd/MM/yyyy');
                                  DateTime dateTime = DateTime.parse(
                                      (snapshot.data as Map<String, dynamic>)[
                                              'release_date'] ??
                                          (snapshot.data as Map<String,
                                              dynamic>)['first_air_date']);
                                  String dataFormatada =
                                      dateFormat.format(dateTime);
                                  return Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image(
                                            image: NetworkImage(
                                                'https://image.tmdb.org/t/p/w200/' +
                                                    (snapshot.data as Map<
                                                            String, dynamic>)[
                                                        "poster_path"]),
                                            height: 200,
                                            width: 150,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  child: Text(
                                                    (snapshot.data as Map<
                                                        String,
                                                        dynamic>)["title"],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 3,
                                                    softWrap: true,
                                                  ),
                                                  width: 340,
                                                ),
                                                for (var genero
                                                    in ((snapshot.data as Map<
                                                                    String,
                                                                    dynamic>)[
                                                                'genres']
                                                            .map((genre) {
                                                          return genre['id'];
                                                        }).toList() ??
                                                        []))
                                                  Text(
                                                    _generos[genero] ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                const SizedBox(
                                                  height: 40,
                                                ),
                                                Text(
                                                  dataFormatada,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                                Text(
                                                  ((snapshot.data as Map<String,
                                                                  dynamic>)[
                                                              "runtime"])
                                                          .toString() +
                                                      " Minutos",
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 18, top: 10, bottom: 15),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Text(
                                                  "Criticos: ",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                Text(
                                                  (snapshot.data as Map<String,
                                                                  dynamic>)[
                                                              'vote_average']
                                                          .toStringAsFixed(1) +
                                                      '/10',
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "Usuário: ",
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                Text(
                                                  nota,
                                                  style: const TextStyle(
                                                      fontSize: 20),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  );
                              }
                            }),
                      ],
                    );
                }
              }),
        ),
      ),
    );
  }
}
