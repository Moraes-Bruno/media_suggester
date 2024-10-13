import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../controller/personalizedSuggestions_controller.dart';

class EscreverReview extends StatefulWidget {
  final Map<String, dynamic> media;

  const EscreverReview(this.media, {super.key});

  @override
  State<EscreverReview> createState() => _EscreverReviewState();
}

class _EscreverReviewState extends State<EscreverReview> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  TextEditingController controller = TextEditingController();
  final PersonalizedSuggestionController _personalizedSuggestionController =
  new PersonalizedSuggestionController();
  int _nota = 0;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  _setNota(int index) {
    setState(() {
      _nota = index + 1;
    });
  }

  void _salvarReview(BuildContext context) {
    Map<String, dynamic> review = {};

    if (controller.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro ao Publicar Review'),
            content: const Text('Informe a descrição!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Código a ser executado quando o botão for pressionado
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Fechar',
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .inversePrimary),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    if (_nota <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Erro ao Publicar Review'),
            content: const Text('Informe a nota!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  // Código a ser executado quando o botão for pressionado
                  Navigator.of(context).pop(); // Fecha o diálogo
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme
                      .of(context)
                      .colorScheme
                      .secondary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Fechar',
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme
                          .of(context)
                          .colorScheme
                          .inversePrimary),
                ),
              ),
            ],
          );
        },
      );
      return;
    }

    review["nota"] = _nota;
    review["descricao"] = controller.text;
    review["criacao"] = DateTime.now();
    review["filmeId"] = widget.media["id"].toString();
    review["user"] = _firestore.collection("users").doc(user!.uid);
    _firestore.collection("reviews").add(review).then((snapshot) {
      if (snapshot.id.isNotEmpty) {
        _personalizedSuggestionController
            .GerarSugestoesPersonalizadasParaReview(
            widget.media['title'] == "" ||
                widget.media['title'] == null
                ? 'tv'
                : 'movie', review["filmeId"], user!.uid, controller.text);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Review publicada com sucesso!'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Código a ser executado quando o botão for pressionado
                    Navigator.of(context).pop(); // Fecha o diálogo
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Theme
                        .of(context)
                        .colorScheme
                        .secondary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                        fontSize: 20,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary),
                  ),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .primary,
        title: const Text(
          "ESCREVER REVIEW",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(top: 30),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 450,
                height: 260,
                child: Image(
                  image: NetworkImage(
                      'https://image.tmdb.org/t/p/w400/${widget
                          .media['poster_path']}'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                widget.media['title'] ?? widget.media['original_name'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 30,
                margin: const EdgeInsets.only(top: 30),
                decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 42, 42, 42),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const Text(
                        "Escreva a sua review",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                              onPressed: () => _setNota(index),
                              icon: Icon(
                                index < _nota ? Icons.star : Icons.star_border,
                                color: Colors.yellow,
                              ));
                        }),
                      ),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.multiline,
                        minLines: 5,
                        maxLines: 10,
                        style: const TextStyle(fontSize: 20),
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            filled: true,
                            /*Theme.of(context).colorScheme:utilizado para acessar as cores do tema,
                      a unica parte que se altera é o final*/
                            fillColor:
                            Theme
                                .of(context)
                                .colorScheme
                                .inversePrimary,
                            hintText: "Escreva sua review aqui",
                            hintStyle: const TextStyle(color: Colors.black38)),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width - 30,
                margin: const EdgeInsets.only(top: 15, bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme
                            .of(context)
                            .colorScheme
                            .tertiary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                              Theme
                                  .of(context)
                                  .colorScheme
                                  .inversePrimary),
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _salvarReview(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme
                              .of(context)
                              .colorScheme
                              .secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            "Publicar",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .inversePrimary),
                          ),
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
