import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/pages/AlterarPerfil.dart';
import 'package:media_suggester/pages/Detalhes.dart';
import 'package:media_suggester/pages/favorito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/repository/media_repository.dart';

class Perfil extends StatelessWidget {
  Perfil({super.key});

  final User? user = FirebaseAuth.instance.currentUser;
  final MediaRepository mediaRepository = MediaRepository();

  Future<Map<String, dynamic>> _getUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
    }
    return {};
  }

  Future<List<dynamic>> _fetchFavoritos(String userId) async {
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
        final result = await mediaRepository.pesquisarMedia(favorito);
        final firstValidMedia = result
            .where((movie) =>
                movie['title'] != null &&
                movie['overview'] != null &&
                movie['poster_path'] != null)
            .take(1)
            .toList();

        if (firstValidMedia.isNotEmpty) {
          mediaTemp.add(firstValidMedia[0]);
        }
      }

      return mediaTemp.take(6).toList();
    } catch (e) {
      print("Nao foi possivel retornar os favoritos: $e");
      return [];
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Erro ao carregar os dados do usuário"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("Nenhum dado do usuário encontrado"));
          } else {
            Map<String, dynamic> userData = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.only(top: 40, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: userData['photoUrl'] != null
                          ? NetworkImage(userData['photoUrl'])
                          : const AssetImage(
                                  'assets/images/profile_placeholder.png')
                              as ImageProvider,
                      width: 200,
                      height: 200,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(255, 42, 42, 42),
                      margin: const EdgeInsets.only(top: 40),
                      child: SizedBox(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(
                                child: Text(
                                  'INFORMAÇÕES',
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                'Nome: ${userData['name'] ?? 'Nome não disponível'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Email: ${userData['email'] ?? 'Email não disponível'}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 16, bottom: 16),
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                        ),
                        child: Text(
                          'ALTERAR DADOS',
                          style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Favoritos',
                            style: TextStyle(fontSize: 20),
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
                            child: Text(
                              'Ver mais',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FutureBuilder<List<dynamic>>(
                      future: _fetchFavoritos(user!.uid),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Text("Erro ao carregar favoritos"));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text("Nenhum favorito encontrado"));
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            child: CarouselSlider(
                              items: snapshot.data!.map((item) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigate to details page
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Detalhes(item),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(5.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image.network(
                                            'https://image.tmdb.org/t/p/w500${item['poster_path']}',
                                            fit: BoxFit.cover,
                                            width: 1000.0,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                              options: CarouselOptions(
                                aspectRatio: 16 / 9,
                                viewportFraction: 1 / 3,
                                enlargeCenterPage: false,
                                enableInfiniteScroll: true,
                                initialPage: 1,
                                autoPlay: false,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
