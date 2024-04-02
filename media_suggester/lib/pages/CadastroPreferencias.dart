import 'package:flutter/material.dart';

class CadastroPreferencias extends StatefulWidget {
  const CadastroPreferencias({super.key});

  @override
  State<CadastroPreferencias> createState() => _CadastroPreferenciasState();
}

class _CadastroPreferenciasState extends State<CadastroPreferencias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Personalize suas sugestões:",
              style: TextStyle(fontSize: 30),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Tipo("Filmes"), Tipo("Séries"), Tipo("Outros")],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Genero("AÇÃO", Theme.of(context).colorScheme.secondary),
                  Genero("COMÉDIA", Colors.grey)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Genero("SCI-FI", Colors.grey),
                  Genero("ROMANCE", Theme.of(context).colorScheme.secondary)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Genero("FANTASIA", Theme.of(context).colorScheme.secondary),
                  Genero("BIOGRAFIA", Colors.grey)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Genero("TERROR", Colors.grey),
                  Genero("SUSPENSE", Theme.of(context).colorScheme.secondary)
                ],
              ),
            ),
            SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Continuar",
                        style: TextStyle(fontSize: 20),
                      ),
                      Icon(Icons.arrow_forward)
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

class Genero extends StatelessWidget {
  Genero(this.titulo, this.cor, {super.key});

  String titulo;
  Color cor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 80,
        width: 160,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
              backgroundColor: cor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          child: Text(
            titulo,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}

class Tipo extends StatelessWidget {
  Tipo(this.titulo, {super.key});

  String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          titulo,
          style: TextStyle(fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.red,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(width: 2.0, color: Colors.red))),
      ),
    );
  }
}
