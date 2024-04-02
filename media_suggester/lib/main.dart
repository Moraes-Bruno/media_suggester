import 'package:flutter/material.dart';
import 'package:media_suggester/my_app.dart';
import 'package:media_suggester/theme/theme_provider.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}


