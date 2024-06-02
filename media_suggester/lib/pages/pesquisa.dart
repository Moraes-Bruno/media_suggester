import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_suggester/pages/Detalhes.dart';
import 'dart:convert';
import 'package:media_suggester/pages/review_unica.dart';
import 'package:media_suggester/repository/media_repository.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  List<dynamic> media = [];
  MediaRepository mediaRepository = MediaRepository();

  @override
  void initState() {
    super.initState();
  }

  Future<void> procurarMedia(String query) async {
    try {
      final result = await mediaRepository.searchMedia(query);
      setState(() {
        media = result
            .where((movie) =>
                (movie['title'] != null || movie['original_name'] != null) &&
                movie['overview'] != null &&
                movie['poster_path'] != null)
            .toList();
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
            child: media.length > 0
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: media.length,
                    itemBuilder: (context, index) {
                      final movie = media[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Detalhes(movie),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            movie['title'] ?? movie['original_name'],
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            movie['overview'],
                            maxLines: 3,
                            style: const TextStyle(fontSize: 15),
                          ),
                          leading: Image.network(
                            'https://image.tmdb.org/t/p/w200/${movie['poster_path']}',
                          ),
                        ),
                      );
                    },
                  )
                : Column(
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
