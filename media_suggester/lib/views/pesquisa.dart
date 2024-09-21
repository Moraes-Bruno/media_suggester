import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_suggester/controller/media_controller.dart';
import 'package:media_suggester/views/Detalhes.dart';
import 'package:media_suggester/views/review_unica.dart';
import 'package:media_suggester/models/Media.dart';
import 'package:media_suggester/widgets/searchWidget.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  List<dynamic> media = [];
  final MediaController _mediaController = MediaController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> procurarMedia(String query) async {
    try {
      final result = await _mediaController.searchMedia(query);
      setState(() {
        media = result;
      });
    } catch (error) {
      // Lidar com erros
      print('Erro ao pesquisar filmes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text(
            "PESQUISAR",
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
                    onSubmitted: procurarMedia,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.inversePrimary,
                        hintText: "Pesquisar...",
                        hintStyle: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: media.isNotEmpty
                ? Searchcardwidget(media: media)
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        image: AssetImage("assets/images/pesquisa.png"),
                        height: 400,
                        width: 400,
                      ),
                      Text(
                        "Não encontramos nenhum registro...",
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
