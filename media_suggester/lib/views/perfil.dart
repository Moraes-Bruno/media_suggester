import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_suggester/controller/user_controller.dart';
import 'package:media_suggester/views/AlterarPerfil.dart';
import 'package:media_suggester/views/Detalhes.dart';
import 'package:media_suggester/views/favorito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/models/Media.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:media_suggester/views/Login.dart';

class Perfil extends StatelessWidget {
  Perfil({super.key});

  final User? user = FirebaseAuth.instance.currentUser;

  final UserController _userController = UserController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOutAndClearData(BuildContext context) async {
    // Faz o logout do Firebase
    await _auth.signOut();

    // Limpa os dados armazenados localmente
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa todos os dados armazenados localmente

    // Redireciona para a tela de login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Login()), // Tela de login
      (Route<dynamic> route) => false,
    );
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data == null || !snapshot.data!.exists) {
            return const CircularProgressIndicator(); // ou outro widget de aviso
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(top: 40, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image(
                      image: userData['photoUrl'] != null
                          ? NetworkImage(userData['photoUrl'])
                          : const AssetImage(
                                  'assets/images/profile_placeholder.png')
                              as ImageProvider,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
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
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Apelido: ${userData['nickname']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: 10,
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
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // Chama o método de logout da Controller
                        UserController().signOut(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(
                        'SAIR',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
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
                    future: _userController.GetFavoritos(user!.uid, true),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text("Erro ao carregar favoritos"));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text("Nenhum favorito encontrado"));
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
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
        },
      ),
    );
  }
}
