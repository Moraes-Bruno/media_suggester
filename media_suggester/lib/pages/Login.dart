import 'package:flutter/material.dart';
import 'package:media_suggester/pages/Home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:media_suggester/pages/genre_movie.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  User? userLogado;

  @override
  void initState() {
    super.initState();
    _checkIfLoggedIn().then((loggedIn) {
      if (loggedIn) {
        // Se o usuário já está logado, redirecionar para a página Home
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home(_auth.currentUser)));
      }
    });
  }

  Future<bool> _checkIfLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true; // Ativar indicador de progresso
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // O usuário cancelou o login.
        setState(() {
          _isLoading = false; // Desativar indicador de progresso
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Verificar se o documento do usuário existe no Firestore
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // Se o documento não existir, criar um novo documento com as informações do usuário
          await _firestore.collection('users').doc(user.uid).set({
            'name': user.displayName,
            'email': user.email,
            'favoritos': [],
            'photoUrl': user.photoURL,
          });
        }

        print('Usuário logado: ${user.displayName}');
        verificarPreferencia(user.uid).then((value) {
          value
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(_auth.currentUser)))
              : Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Genre_movie()));
        });
      }
    } catch (e) {
      print('Erro ao fazer login com Google: $e');
    } finally {
      setState(() {
        _isLoading = false; // Desativar indicador de progresso
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/novo_logo.png"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(150))),
                  height: 400,
                  width: 400,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 160,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: const Text(
                                  "Entrar",
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<bool> verificarPreferencia(String userId) async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("preferences")
          .doc(userId)
          .get();
      //.where("token_google", isEqualTo: "12345x")
      // Se houver documentos encontrados, retorna true
      print(user.exists);
      return user.exists;
    } catch (e) {
      // Em caso de erro, retorna false
      return false;
    }
  }
}
