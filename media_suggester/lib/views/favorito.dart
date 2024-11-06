import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/views/Detalhes.dart';
import 'package:media_suggester/models/Media.dart';

class Favorito extends StatefulWidget {
  @override
  State<Favorito> createState() => _FavoritoState();
}

class _FavoritoState extends State<Favorito> {
  Media _media = Media();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<dynamic> media = [];
  bool isLoading = true;

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      _fetchFavoritos(user!.uid);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (user != null) {
      _fetchFavoritos(user!.uid);
    }
  }

  Future<void> _fetchFavoritos(String userId) async {
    setState(() {
      isLoading = true;
    });

    List<String> favoritos = [];

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        favoritos = List<String>.from(data['favoritos'] ?? []);
      }

      List<dynamic> mediaTemp = [];
      for (String favorito in favoritos) {
        final result = await _media.searchMedia(favorito);
        final firstValidMedia = result
            .where((movie) =>
                movie['title'] != null &&
                movie['overview'] != null &&
                movie['poster_path'] != null)
            .toList()
            .take(1)
            .toList();

        if (firstValidMedia.isNotEmpty) {
          mediaTemp.add(firstValidMedia[0]);
        }
      }

      setState(() {
        media = mediaTemp;
        isLoading = false;
      });
    } catch (e) {
      print("Nao foi possivel retornar os favoritos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> procurarMedia(String query) async {
    try {
      final result = await _media.searchMedia(query);
      final firstValidMedia = result
          .where((movie) =>
              movie['title'] != null &&
              movie['overview'] != null &&
              movie['poster_path'] != null)
          .toList()
          .take(1)
          .toList(); //Pega apenas o primeiro resultado

      if (firstValidMedia.isNotEmpty) {
        setState(() {
          media.add(firstValidMedia[0]);
        });
      }
    } catch (error) {
      // Lidar com erros
      print('Erro ao pesquisar filmes: $error');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          title: const Text(
            "FAVORITOS",
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
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : media.isEmpty
              ? const Center(child: Text("Nenhum favorito encontrado"))
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: media.length,
                  itemBuilder: (context, index) {
                    final item = media[index];
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Detalhes(item)),
                        );
                        _fetchFavoritos(user!
                            .uid); // Recarrega os favoritos quando voltar da página de detalhes
                      },
                      child: GridTile(
                        child: Image.network(
                          'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
