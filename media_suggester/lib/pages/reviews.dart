import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_suggester/pages/review_unica.dart';
import 'package:media_suggester/repository/media_repository.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final MediaRepository _mediaRepository = MediaRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<QuerySnapshot<Map<String, dynamic>>> listReviews;

  carregarReviews(String busca) {
    if (busca.isNotEmpty) {
      setState(() {
        listReviews = _firestore
            .collection('reviews')
            .limit(10)
            .where('descricao', isEqualTo: busca)
            .get();
      });
    } else {
      setState(() {
        listReviews = _firestore.collection('reviews').limit(10).get();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    carregarReviews("");
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "REVIEWS",
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                onSubmitted: (value) {
                  carregarReviews(value);
                },
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.inversePrimary,
                    hintText: "Procurar Review",
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)),
              ),
            ),
            //tres pontos(...) expande a lista de widgets em uma lista de argumentos
            Padding(
              padding: EdgeInsets.all(0),
              child: FutureBuilder(
                future: listReviews,
                builder: (context, snapshot) {
                  print(snapshot.data!.docs);
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Container(
                        width: 200.0,
                        height: 200.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 5.0,
                        ),
                      );
                    default:
                      return Column(
                        children: _obterComentarios(context, snapshot),
                      );
                  }
                },
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  /*_carregarFilme(String filmeId) async {
    await _mediaRepository.getFilme(filmeId);
  }*/

  _obterComentarios(BuildContext context, AsyncSnapshot snapshot) {
    List<dynamic> listReviewsTemp =
        snapshot.data.docs; //.map((doc) => doc.data()).toList();
    List<Widget> widgets = [];
    for (final review in listReviewsTemp) {
      //_carregarFilme(review["filmeId"]);
      String nota = "";
      for (var i = 0; i < review['nota']; i++) {
        nota += "★";
      }
      nota = nota.padRight(5, "☆");

      widgets.add(GestureDetector(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ReviewUnica()));
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
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage(
                              "assets/images/profile_placeholder.png"),
                          height: 45,
                          width: 45,
                        ),
                        SizedBox(
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
                                      return Text(
                                          (snapshot.data as DocumentSnapshot)
                                              .get("name"),
                                          style: TextStyle(fontSize: 20));
                                  }
                                }),
                            Text(
                              nota,
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                        Spacer(), // Adiciona um espaçamento flexível
                        Text(
                          DateFormat('dd/MM/yyyy HH:mm').format(
                              DateTime.fromMicrosecondsSinceEpoch(
                                  review['criacao'].microsecondsSinceEpoch)),
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Text(
                      review['descricao'],
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ));
    }
    ;
    return widgets;
  }
}
