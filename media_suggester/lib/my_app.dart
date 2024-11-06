import 'package:flutter/material.dart';
import 'package:media_suggester/theme/theme_provider.dart';
import 'main.dart';
import 'views/Login.dart';
import 'package:provider/provider.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Suggester',
      navigatorObservers: [routeObserver],
      theme: Provider.of<ThemeProvider>(context).themeData,
      debugShowCheckedModeBanner: false,
      home: const Login(),
    );
  }
}