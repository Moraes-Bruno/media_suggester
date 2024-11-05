import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/models/Media.dart';
import 'package:flutter/material.dart';

class UserModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? userLogado;


  Future<User?> SignIn(googleUser) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    final User? user = userCredential.user;

    // Verificar se o documento do usuário existe no Firestore
    final userDoc = await _firestore.collection('users').doc(user!.uid).get();

    if (!userDoc.exists) {
      // Se o documento não existir, criar um novo documento com as informações do usuário
      await _firestore.collection('users').doc(user!.uid).set({
        'name': user.displayName,
        'email': user.email,
        'favoritos': [],
        'nickname': user.displayName,
        'photoUrl': user.photoURL,
      });
    }

    return user;
  }

  Future<DocumentSnapshot?> GetPreferences(userId) async {
    return await FirebaseFirestore.instance
        .collection("preferences")
        .doc(userId)
        .get();
  }

  Future<bool> CheckIfLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }
//-------------verifica se existe preferencia --------------------------
  Future<bool> HasPreferences(String userId) async {
    try {
      // Acessa o documento do usuário na coleção preferences
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("preferences")
          .doc(userId)
          .get();

      // Verifica se o documento de preferências existe
      if (user.exists) {
        // Acessa o campo genders_movie
        List<dynamic> gendersMovie = user.get("genders_movie") ?? [];
        // Acessa o campo genders_serie
        List<dynamic> gendersSerie = user.get("genders_serie") ?? [];

        // Verifica se ambos os arrays existem e não estão vazios
        bool hasGendersMovie = gendersMovie.isNotEmpty;
        bool hasGendersSerie = gendersSerie.isNotEmpty;

        // Debug
        print("Genders Movie existe: $hasGendersMovie");
        print("Genders Serie existe: $hasGendersSerie");

        // Se ambos existem, retorna true
        if (hasGendersMovie && hasGendersSerie) {
          return true;
        } else {
          return false;
        }
      }
      return false; // Retorna false se o documento de preferências não existir
    } catch (e) {
      print("Erro: $e");
      return false; // Retorna false em caso de erro
    }
  }
//-----------------------fim----------------------------------------------------------------

  Future<bool> HasSuggestions(String userId) async {
    try {
      DocumentSnapshot suggestions = await FirebaseFirestore.instance
          .collection("suggestions")
          .doc(userId)
          .get();
      return suggestions.exists;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> FetchFavoritos(String userId, bool limit) async {
    final Media media = Media();
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
        final result = await media.searchMedia(favorito);
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

      if (limit) {
        mediaTemp = mediaTemp.take(6).toList();
      }

      return mediaTemp;
    } catch (e) {
      print("Nao foi possivel retornar os favoritos: $e");
      return [];
    }
  }
  //----------------------------Gener Movie -------------------------------
  Future<void> saveSelectedGenres_movie(List<dynamic> genres) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    List<dynamic> selectedGenres = genres.where((genre) => genre['selected'] ?? false).toList();
    List<Map<String, dynamic>> selectedGenresData = selectedGenres.take(5).map((genre) {
      return {
        'id': genre['id'],
        'name': genre['name'],
      };
    }).toList();

    await _firestore.collection('preferences').doc(user.uid).set({
      'genders_movie': selectedGenresData,
    });
  }

  //------------------------------serie----------------------------
  Future<void> saveSelectedGenres_serie(List<dynamic> genres) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Usuário não autenticado');
    }

    List<dynamic> selectedGenres = genres.where((genre) => genre['selected'] ?? false).toList();
    List<Map<String, dynamic>> selectedGenresData = selectedGenres.take(5).map((genre) {
      return {
        'id': genre['id'],
        'name': genre['name'],
      };
    }).toList();

    await _firestore.collection('preferences').doc(user.uid).update({
      'genders_serie': selectedGenresData,
    });
  }

  //-------------------Detalhes.dart-----------------------\\
  Future <bool> Favoritar(String nomeMedia,String uid) async {
    bool add = false;

    try {
      DocumentReference userDoc =
          _firestore.collection('users').doc(uid);
      
      print(userLogado?.displayName);

      DocumentSnapshot userSnapshot = await userDoc.get();

      List favoritos = userSnapshot['favoritos'] ?? [];

      if (favoritos.contains(nomeMedia)) {
        await userDoc.update({
          'favoritos': FieldValue.arrayRemove([nomeMedia])
        });

        add = false;
      }else {
          await userDoc.update({
            'favoritos': FieldValue.arrayUnion([nomeMedia])
          });
          add = true;
          }

         
    } catch (e) {
      print(e);
    }

    return add;
  }

  Future <bool> checkFavorito (String nomeMedia,String uid) async{
    bool checked = false;
   try {
      DocumentReference userDoc =
          _firestore.collection('users').doc(uid);
      
      print(userLogado?.displayName);

      DocumentSnapshot userSnapshot = await userDoc.get();

      List favoritos = userSnapshot['favoritos'] ?? [];

      if (favoritos.contains(nomeMedia)) {
        checked = true;
      }else {
         checked = false;
          }      
    } catch (e) {
      print(e);
    }

    return checked;

  }

  Future<void> alterarPerfil(BuildContext context, String nickname) async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    throw Exception('Usuário não autenticado');
  }

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
          'nickname': nickname.isNotEmpty ? nickname : user.displayName,
        });

    // ignore: use_build_context_synchronously
    showConfirmationDialog(context, 'Apelido atualizado com sucesso');
  } catch (e) {
    print(e);
  }
}

void showConfirmationDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Apelido Atualizado"),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
//-------------------logout---------------

  Future<void> signOut() async {
    await _auth.signOut();
  }

}


