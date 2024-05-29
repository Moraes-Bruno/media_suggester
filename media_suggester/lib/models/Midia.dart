class Midia {
  int? id;
  String? titulo;
  String ondeAssistir;

  Midia({this.titulo, required this.ondeAssistir, this.id});

  factory Midia.fromJson(Map<String, dynamic> json) {
    return Midia(
      titulo: json['titulo'],
      ondeAssistir: json['ondeAssistir'],
    );
  }
}