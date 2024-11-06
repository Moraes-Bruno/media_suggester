import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  /*List<dynamic>? filmes;
  List<dynamic>? series;

  Suggestion(this.filmes, this.series);*/

  /* factory Suggestion.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    return Suggestion(
      snapshot.get('filmes') as List<dynamic>,
      snapshot.get('series') as List<dynamic>,
    );
  }

  factory Suggestion.fromGeneratedInput(
      List<dynamic> filmes, List<dynamic> series) {
    return Suggestion(filmes, series);
  } */

  Future<QuerySnapshot<Map<String, dynamic>>> getReviews(String busca) {
    if (busca.isNotEmpty) {
      return FirebaseFirestore.instance.collection('reviews')
          .limit(10)
          .where('descricao',
          isGreaterThanOrEqualTo: busca,
          isLessThan: busca.substring(0, busca.length - 1) +
              String.fromCharCode(busca.codeUnitAt(busca.length - 1) + 1))
          .get();
    } else {
      return FirebaseFirestore.instance.collection('reviews')
          .limit(10)
          .orderBy('criacao', descending: true)
          .get();
    }
  }
}
