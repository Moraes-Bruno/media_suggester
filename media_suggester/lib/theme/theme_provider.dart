import 'package:flutter/material.dart';
import 'package:media_suggester/theme/dark_theme.dart';


class ThemeProvider extends ChangeNotifier{
  //tema padrao
  ThemeData _themeData = darkMode; 

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    //atualiza a interface
    notifyListeners();
  }
}