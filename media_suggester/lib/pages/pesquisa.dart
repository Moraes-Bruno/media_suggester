import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:media_suggester/pages/review_unica.dart';

class Pesquisa extends StatefulWidget {
  const Pesquisa({super.key});

  @override
  State<Pesquisa> createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  List<dynamic> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    TextEditingController _searchController = TextEditingController();

    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=MY_API_KEY&language=pt-BR'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        movies = data['results'];
      });
    } else {
      throw Exception('Nenhum filme encontrado');
    }
  }

  Future<void> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://api.themoviedb.org/3/search/movie?query=' + query + '&api_key=MY_API_KEY&language=pt-BR'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        movies = data['results'];
      });
    } else {
      throw Exception('Nenhum filme encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title:  TextField(
          decoration: InputDecoration(
            hintText: 'PESQUISAR...',
            border: InputBorder.none,
          ),
          onChanged: searchMovies(),
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
      body: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextField(
                    style: const TextStyle(fontSize: 20),
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
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return ListTile(
                  title: Text(movie['title']),
                  subtitle: Text(movie['overview']),
                  leading: Image.network(
                    'https://image.tmdb.org/t/p/w200/${movie['poster_path']}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
