import 'package:cloud_firestore/cloud_firestore.dart';

import 'Midia.dart';

class Suggestion {
  final List<dynamic> filmes;
  final List<dynamic> series;

  Suggestion({
    required this.filmes,
    required this.series,
  });

  factory Suggestion.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return Suggestion(
      filmes: snapshot.get('filmes') as List<dynamic>,
      series: snapshot.get('series') as List<dynamic>,
    );
  }

  factory Suggestion.fromGeneratedInput(
      List<dynamic> filmes, List<dynamic> series) {
    return Suggestion(
      filmes: filmes,
      series: series,
    );
  }
}
