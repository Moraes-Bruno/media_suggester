import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:media_suggester/pages/review_unica.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<dynamic> listReviews = [];

  void carregarReviews() async {
    final reviews = await _firestore.collection('reviews').get();
    listReviews = reviews.docs.map((doc) => doc.data()).toList();
    print(listReviews);
  }

  @override
  void initState() {
    super.initState();
    carregarReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "REVIEWS",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 30),
                    padding: const EdgeInsetsDirectional.all(8.0),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.inversePrimary,
                  hintText: "Procurar Review",
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary)

                ),

              ),
            ),
            //tres pontos(...) expande a lista de widgets em uma lista de argumentos
            ..._obterComentarios(context),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  _obterComentarios(BuildContext context) {
    final List<String> comments = [
      "Um filme emocionante que prende sua atenção do início ao fim...",
      "Uma obra-prima cinematográfica que cativa com sua narrativa envolvente...",
      "Um filme repleto de ação que entrega adrenalina do começo ao fim...",
      "Uma comédia hilária que garante gargalhadas do público, com piadas...",
      "Um drama emocionante que explora temas profundos e complexos..."
    ];

    final List<Widget> commentSlider = comments.map((comment) {
      return GestureDetector(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewUnica()));
        },
        child: Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width-30,
              margin: const EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 42, 42, 42),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Image(
                          image:
                              AssetImage("assets/images/profile_placeholder.png"),
                          height: 45,
                          width: 45,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Jane Doe",
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(
                              "★★★★☆",
                              style: TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                        Spacer(), // Adiciona um espaçamento flexível
                        Text(
                          "01/04/2024", // Sua data aqui
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    child: Text(
                      comment,
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }).toList();

    return commentSlider;
  }
}
