import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_suggester/repository/media_repository.dart';

class ReviewUnica extends StatefulWidget {
  final dynamic review;

  const ReviewUnica(this.review, {super.key});

  @override
  State<ReviewUnica> createState() => _ReviewUnicaState();
}

class _ReviewUnicaState extends State<ReviewUnica> {
  final MediaRepository _mediaRepository = MediaRepository();
  _carregarFilme(String filmeId) async {
    Map<String, dynamic> filme = await _mediaRepository.getFilme(filmeId);
    return filme;
  }

  @override
  Widget build(BuildContext context) {
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
                      child: CircularProgressIndicator(
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
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          (snapshot.data as DocumentSnapshot).get("name"),
                          style: TextStyle(fontSize: 25),
                        ),
                        Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            widget.review['descricao'],
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        SizedBox(
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
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image(
                                        image: NetworkImage(
                                            'https://image.tmdb.org/t/p/w200/' +
                                                (snapshot.data as Map<String,
                                                    dynamic>)["poster_path"]),
                                        height: 200,
                                        width: 150,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              child: Text(
                                                (snapshot.data as Map<String,
                                                    dynamic>)["title"],
                                                style: TextStyle(fontSize: 20),
                                                maxLines: 3,
                                                softWrap: true,
                                              ),
                                              width: 340,
                                            ),
                                            Text(
                                              "Genero 1",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              "Genero 2",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              "Genero 3",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            SizedBox(
                                              height: 40,
                                            ),
                                            Text(
                                              /*DateFormat('dd/MM/yy').format(
                                                  ((snapshot.data as Map<String,
                                                          dynamic>)[
                                                      "release_date"])),*/
                                              "Data Lançamento",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            Text(
                                              ((snapshot.data as Map<String,
                                                          dynamic>)["runtime"])
                                                      .toString() +
                                                  " Minutos",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                              }
                            }),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 18, top: 10, bottom: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Criticos: ",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    "★★★★☆",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Text(
                                    "Usuarios: ",
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    "★★★★★",
                                    style: TextStyle(fontSize: 20),
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
        ),
      ),
    );
  }
}
