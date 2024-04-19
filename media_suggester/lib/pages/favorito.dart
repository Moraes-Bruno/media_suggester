import 'package:flutter/material.dart';

class Favorito extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "FAVORITOS",
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    hintText: "Pesquisar...",
                    hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary)),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3, 
              children: List.generate(
                20, // num cards
                (index) {
                  return Card(
                    child: Image(
                image: AssetImage('assets/images/vertical_placeholder.jpg'),
                width: 300,
                height: 200)
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
