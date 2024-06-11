import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../views/Detalhes.dart';

class CardWidget {
  Widget ObterCard(
      BuildContext context, Map<String, dynamic> midia, String posterPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Detalhes(midia)),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            'https://image.tmdb.org/t/p/w200/$posterPath',
          ),
        ),
      ),
    );
  }
}
