import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_suggester/pages/CadastroPreferencias.dart';

class Alterar extends StatelessWidget {
  const Alterar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "ALTERAR DADOS",
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
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                child: Text(
                  'ALTERAR FOTO DE PERFIL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              child: IconButton(
                icon: const Icon(Icons.account_circle),
                iconSize: 120,
                color: Colors.white,
                onPressed: () {},
              ),
            ),
            Center(
              child: Text('Clique para selecionar uma foto',style: TextStyle(fontSize: 16 ),),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Text(
                          'ALTERAR EMAIL',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextField(
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              hintText: "joagana@mediasuggester.com",
                              hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Container(
                          child: Text(
                            'ALTERAR SENHA',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: TextField(
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              filled: true,
                              fillColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              hintText: "123456789",
                              hintStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              width: 264,
              height: 40,
              child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  'SALVAR DADOS ALTERADOS',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
                        Container(
              margin: EdgeInsets.only(top: 16, bottom: 16),
              width: 248,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                   Navigator.push(
                context, MaterialPageRoute(builder: (context) => CadastroPreferencias()));
                },
                child: Text(
                  'ALTERAR GENERO',
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            //--------------------------------
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
