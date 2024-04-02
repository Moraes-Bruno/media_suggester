import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: const ColorScheme.dark(
    background: Color.fromRGBO(34, 34, 34,1),
    primary: Color.fromRGBO(187, 11, 11,0.7),
    secondary: Color.fromRGBO(187, 11, 11,1),
    tertiary: Colors.black,
    inversePrimary: Colors.white,
    
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black), // Cor padrão do texto do corpo
    // Adicione outras definições de estilo de texto conforme necessário
  ),
);