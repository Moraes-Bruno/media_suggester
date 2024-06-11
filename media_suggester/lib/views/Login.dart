import 'package:flutter/material.dart';
import 'package:media_suggester/controller/user_controller.dart';
import 'package:media_suggester/views/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:media_suggester/views/genre_movie.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserController _userController = UserController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userController.CheckIfLoggedIn().then((loggedIn) {
      if (loggedIn) {
        // Se o usuário já está logado, redirecionar para a página Home
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => Home(_auth.currentUser!)));
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true; // Ativar indicador de progresso
      });

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // O usuário cancelou o login.
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final User? user = await _userController.SignIn(googleUser!);

      if (user != null) {
        print('Usuário logado: ${user.displayName}');

        _userController.HasPreferences(user.uid).then((hasPreferences) {
          hasPreferences
              ? Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Home(_auth.currentUser!)))
              : Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Genre_movie()));
        });
      }
    } catch (e) {
      print('Erro ao fazer login com Google: $e');
    } finally {
      setState(() {
        _isLoading = false;
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
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
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
}
