import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:media_suggester/repository/media_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/pages/gender_serie.dart';


class Gender_movie extends StatefulWidget {
  @override
  _Gender_movieState createState() => _Gender_movieState();
}

class _Gender_movieState extends State<Gender_movie> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<dynamic> genres = [];
  int selectedCount = 0;
  MediaRepository media = MediaRepository();

  User? user;

  @override
  void initState() {
    user = _auth.currentUser;

    super.initState();
    fetchGenres();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPopup();
    });
  }

  Future<void> fetchGenres() async {
    final apiKey = media.chaveApi ;
    final url = 'https://api.themoviedb.org/3/genre/movie/list?api_key=$apiKey&language=pt-BR';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        genres = json.decode(response.body)['genres'];
      });
    } else {
      throw Exception('Failed to load genres');
    }
  }

  void saveSelectedGenres() {
    List<dynamic> selectedGenres = genres.where((genre) => genre['selected'] ?? false).toList();
    print('Selected Genres: $selectedGenres');
    print(user?.uid);

    List<Map<String, dynamic>> selectedGenresData = selectedGenres.take(5).map((genre) {
      return {
        'id': genre['id'],
        'name': genre['name'],
      };
    }).toList();

    _firestore.collection('preferences').doc(user?.uid).set({
      'genders_movie': selectedGenresData,
    });
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Gender_serie()));
  }


  void _showPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Aviso!!'),
          content: Text('Você pode selecionar até cinco gêneros de filmes.  Caso não tenha preferência por algum gênero específico, basta deixar o campo correspondente em branco antes de salvar suas escolhas.', style: TextStyle(color: Colors.white,),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar', style: TextStyle(color: Colors.white),),
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
              activeColor: Theme.of(context).colorScheme.primary, // Definindo a cor da caixa de seleção como vermelho
              onChanged: (value) {
                setState(() {
                  if (value! && selectedCount >= 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Você só pode selecionar até 5 gêneros.'),
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
        onPressed: saveSelectedGenres,
        child: Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}