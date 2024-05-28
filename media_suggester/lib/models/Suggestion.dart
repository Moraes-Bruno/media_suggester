import 'package:cloud_firestore/cloud_firestore.dart';

class Suggestion {
  final String filmes;
  final String series;

  Suggestion({
    required this.filmes,
    required this.series,
  });

  factory Suggestion.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return Suggestion(
      filmes: snapshot.get('filmes'),
      series: snapshot.get('series'),
    );
  }
}
