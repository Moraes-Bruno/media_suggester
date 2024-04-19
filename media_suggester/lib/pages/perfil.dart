import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/pages/AlterarPerfil.dart';
import 'package:media_suggester/pages/favorito.dart';
import 'package:media_suggester/pages/review_unica.dart';

class Perfil extends StatelessWidget {
  const Perfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "PERFIL",
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 40, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
                image: AssetImage('assets/images/profile_placeholder.png'),
                width: 200,
                height: 200),
            Container(
              width: MediaQuery.of(context).size.width,
              color: const Color.fromARGB(255, 42, 42, 42),
              margin: EdgeInsets.only(top: 40),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'INFORMAÇÔES',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'Nome: Jane now',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Email: Jane now',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              width: 250,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Alterar(),
                        ),
                      );
                },
                child: Text(
                  'ALTERAR DADOS',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Favoritos',
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Favorito(),
                        ),
                      );
                    },
                    child: Text('Ver mais',
                        style: TextStyle(
                            fontSize: 16,
                            color:
                                Theme.of(context).colorScheme.inversePrimary)),
                 style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                )
                  )
                ],
              ),
            ),
            CarouselSlider(
              items: __ObterFav(context),
              options: CarouselOptions(
                aspectRatio: 2.0,
                enlargeCenterPage: true,
                pageViewKey: const PageStorageKey<String>('carousel_slider'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  __ObterFav(BuildContext context) {
    final List<String> comments = [
      ".",
    ];

    final List<Widget> commentSlider = comments.map((comment) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
            child: Image(
                image: AssetImage('assets/images/vertical_placeholder.jpg'),
                width: 300,
                height: 200),
          );
        },
      );
    }).toList();

    return commentSlider;
  }
}
