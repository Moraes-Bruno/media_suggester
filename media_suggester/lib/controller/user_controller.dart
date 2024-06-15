import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/models/User.dart';

class UserController extends PageController {
  final UserModel _user = UserModel();

  Future<bool> CheckIfLoggedIn() async {
    return _user.CheckIfLoggedIn();
  }

  Future<User?> SignIn(googleUser) async {
    return _user.SignIn(googleUser);
  }

  Future<bool> HasPreferences(userId) async {
    return _user.HasPreferences(userId);
  }

  Future<bool> HasSuggestions(userId) async {
    return _user.HasSuggestions(userId);
  }

  Future<DocumentSnapshot?> GetPreferences(userId) async {
    return _user.GetPreferences(userId);
  }

  Future<List<dynamic>> GetFavoritos(userId,limit){
    return _user.FetchFavoritos(userId,limit);
  }

  //-------------------detalhes.dart------------------\\
  Future <bool> Favoritar(String nomeMedia,String uid){
    return _user.Favoritar(nomeMedia,uid);
  }

 //-------------------genre_movie------------------------
  Future<void> saveSelectedGenres_movie(List<dynamic> genres) async {
    await _user.saveSelectedGenres_movie(genres);
  }
  //-------------genre_seria----------------------------
  Future<void> saveSelectedGenres_serie(List<dynamic> genres) async {
    await _user.saveSelectedGenres_serie(genres);
  }
}
