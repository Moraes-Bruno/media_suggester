import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:media_suggester/pages/genre_movie.dart';
import 'package:media_suggester/pages/Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart' ;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _checkIfLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O usuário cancelou o login.
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
          credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Verificar se o documento do usuário existe no Firestore
        final userDoc = await _firestore.collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          // Se o documento não existir, criar um novo documento com as informações do usuário
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'favoritos': [],
            'photoUrl': user.photoURL,
          });
        }

<<<<<<< HEAD

        print('Usuário logado: ${user.uid}');

        // Faz vericação de login
        verificarPreferencia(user.uid).then((value){
          value ? Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()))
              : Navigator.push(context, MaterialPageRoute(builder: (context)=>Genre_movie()));
        });
=======
        print('Usuário logado: ${user.displayName}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
>>>>>>> e95b66a952ef540b44a516e590b756d44ea433d3
      }
    } catch (e) {
      print('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar um indicador de carregamento enquanto espera a verificação
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data == true) {
          // Se o usuário está logado, redireciona para a tela Home
          return const Home();
        } else {
          // Se o usuário não está logado, mostrar a tela de login
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/home_background.png"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
<<<<<<< HEAD
                height: 280,
                width: 200),
            const Text(
              "Login",
              style: TextStyle(fontSize: 50,),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 50,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      _signInWithGoogle();
                      //_signInWithGoogle;
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme
                            .of(context)
                            .colorScheme
                            .secondary,
                        foregroundColor: Theme
                            .of(context)
                            .colorScheme
                            .inversePrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                    child: const Text(
                      "Entrar",
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
=======
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/logo_teste.png"),
                        fit: BoxFit.cover,
                      ),
>>>>>>> e95b66a952ef540b44a516e590b756d44ea433d3
                    ),
                    height: 280,
                    width: 200,
                  ),
                  const Text(
                    "Login",
                    style: TextStyle(fontSize: 50,),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: ElevatedButton(
                          onPressed: _signInWithGoogle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Entrar",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
<<<<<<< HEAD

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  // Verificação se existe o user na preferencia
  static Future<bool> verificarPreferencia(String userId) async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("preferences").doc(userId).get();
          //.where("token_google", isEqualTo: "12345x")
      // Se houver documentos encontrados, retorna true
      print(user.exists);
      return user.exists;
    } catch (e) {
      // Em caso de erro, retorna false
      return false;
    }
  }
=======
>>>>>>> e95b66a952ef540b44a516e590b756d44ea433d3
}
