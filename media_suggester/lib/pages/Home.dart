import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:media_suggester/pages/Detalhes.dart';
import 'package:media_suggester/pages/perfil.dart';
import 'package:media_suggester/pages/pesquisa.dart';
import 'package:media_suggester/pages/reviews.dart';
import 'package:media_suggester/repository/media_repository.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final MediaRepository _mediaRepository = MediaRepository();

  List<dynamic> _mediaPorGenero = [];

  @override
  void initState() {
    super.initState();
    _carregarMedia(); // Carregue os dados da API ao inicializar a tela
  }

  Future<void> _carregarMedia() async {
    try {
      final List<int> generos = [
        28,
        35,
        18,
        16
      ]; // Ação, Comédia, Drama, Animação

      // Carrega os filmes
      final List<Future<List<dynamic>>> futuresFilmes = generos.map((genreId) {
        return _mediaRepository.getMediaGenero(genreId, 'movie');
      }).toList();

      // Carrega as séries
      final List<Future<List<dynamic>>> futuresSeries = generos.map((genreId) {
        return _mediaRepository.getMediaGenero(genreId, 'tv');
      }).toList();

      final List<List<dynamic>> resultsFilmes =
          await Future.wait(futuresFilmes);
      final List<List<dynamic>> resultsSeries =
          await Future.wait(futuresSeries);

      // Combina as listas de filmes e séries
      List<List<dynamic>> combinedResults = [];
      for (int i = 0; i < generos.length; i++) {
        combinedResults.add([...resultsFilmes[i], ...resultsSeries[i]]);
      }

      setState(() {
        _mediaPorGenero = combinedResults;
      });
    } catch (e) {
      print('Erro ao carregar dados da API: $e');
      // Trate o erro conforme necessário
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
      body: _mediaPorGenero.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _mediaPorGenero.length,
              itemBuilder: (context, index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Gênero ${index + 1}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    CarouselSlider(
                      options: CarouselOptions(
                        aspectRatio: 16/9,
                        viewportFraction:1/3,
                        enlargeCenterPage: false,
                        pageViewKey:
                            PageStorageKey<String>('carousel_slider_$index'),
                      ),
                      items: _ObterListaCards(
                        context,
                        _mediaPorGenero[index],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
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

 List<Widget> _ObterListaCards(BuildContext context, List<dynamic> movies) {
    return movies
        .map(
          (movie) => GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detalhes(movie) // Aqui você precisa passar o ID do filme
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w200/${movie['poster_path']}',
                ),
              ),
            ),
          ),
        )
        .toList();
  }