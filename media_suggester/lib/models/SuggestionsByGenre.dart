import 'MediaSimplified.dart';

class SugestoesPorGenero {
  int? idGenero;
  String nomeGenero;
  List<Midia> midias;

  SugestoesPorGenero(
      {this.idGenero, required this.nomeGenero, required this.midias});

  factory SugestoesPorGenero.fromJson(Map<String, dynamic> json) {
    List<Midia> midiasList = [];
    json.forEach((genero, dados) {
      List<dynamic> midias = dados;
      midiasList.addAll(midias.map((midia) => Midia.fromJson(midia)).toList());
    });
    return SugestoesPorGenero(
      idGenero: 0,
      nomeGenero: "",
      midias: midiasList,
    );
  }

  static List<SugestoesPorGenero> fromJsonList(List<dynamic> json) {
    List<SugestoesPorGenero> sugestoes = [];
    for (Map<String, dynamic> genero in json) {
      genero.forEach((key, value) {
        List<Map<String, dynamic>> midias =
            List<Map<String, dynamic>>.from(value);
        sugestoes.add(SugestoesPorGenero(
          idGenero: 0,
          nomeGenero: key,
          midias: midias.map((midia) => Midia.fromJson(midia)).toList(),
        ));
      });
    }
    return sugestoes;
  }
}
