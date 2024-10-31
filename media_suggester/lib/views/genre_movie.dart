import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_suggester/models/Media.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/views/genre_serie.dart';
import 'package:media_suggester/controller/user_controller.dart';
import 'package:media_suggester/controller/media_controller.dart';

class Genre_movie extends StatefulWidget {
  @override
  _GenreMovieState createState() => _GenreMovieState();
}

class _GenreMovieState extends State<Genre_movie> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final MediaController _mediaController = MediaController();
  final UserController _userController = UserController();

  List<dynamic> genres = [];
  int selectedCount = 0;

  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadGenres();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopup();
    });
  }

  Future<void> _loadGenres() async {
    List<dynamic> fetchedGenres = await _mediaController.fetchGenres_movie();
    setState(() {
      genres = fetchedGenres;
    });
  }

  void _saveSelectedGenres() async {
    if (selectedCount == 0) {
      // Exibe uma mensagem se nenhum gênero for selecionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione pelo menos um gênero.',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      await _userController.saveSelectedGenres_movie(genres);
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Gender_serie()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar gêneros: $e')),
      );
    }
  }

  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso!!'),
          content: Text(
            'Você pode selecionar até cinco gêneros de filmes. Caso não tenha preferência por algum gênero específico, basta deixar o campo correspondente em branco antes de salvar suas escolhas.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Fechar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gêneros de filme',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        child: ListView.builder(
          itemCount: genres.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(genres[index]['name']),
              value: genres[index]['selected'] ?? false,
              checkColor: Colors.white,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  if (value! && selectedCount >= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Você só pode selecionar até 5 gêneros.',
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.bold),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    genres[index]['selected'] = value;
                    selectedCount += value ? 1 : -1;
                  }
                });
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: _saveSelectedGenres,
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
