import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<DocumentSnapshot?> GetPreferences(userId) async{
    DocumentSnapshot preferences = await FirebaseFirestore.instance
        .collection("preferences")
        .doc(userId)
        .get();
  }

  Future<bool> CheckIfLoggedIn() async {
    User? user = _auth.currentUser;
    return user != null;
  }

  Future<bool> HasPreferences(String userId) async {
    try {
      DocumentSnapshot user = await FirebaseFirestore.instance
          .collection("preferences")
          .doc(userId)
          .get();
      return user.exists;
    } catch (e) {
      return false;
    }
  }

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
}
