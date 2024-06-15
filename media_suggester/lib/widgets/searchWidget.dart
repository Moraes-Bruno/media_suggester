import 'package:flutter/material.dart';
import 'package:media_suggester/views/Detalhes.dart';

class Searchcardwidget extends StatelessWidget{
  final List<dynamic> media;

  const Searchcardwidget({super.key, required this.media});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: media.length,
      itemBuilder: (context, index) {
        final movie = media[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Detalhes(movie),
              ),
            );
          },
          child: ListTile(
            title: Text(
              movie['title'] ?? movie['original_name'],
              maxLines: 2,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              movie['overview'],
              maxLines: 3,
              style: const TextStyle(fontSize: 15),
            ),
            leading: Image.network(
              'https://image.tmdb.org/t/p/w200/${movie['poster_path']}',
            ),
          ),
        );
      },
    );
  }
}