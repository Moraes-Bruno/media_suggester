import 'package:flutter/material.dart';

class ReviewUnica extends StatefulWidget {
  const ReviewUnica({super.key});

  @override
  State<ReviewUnica> createState() => _ReviewUnicaState();
}

class _ReviewUnicaState extends State<ReviewUnica> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white, size: 30),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: const Text(
          "REVIEW",
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
        child: Container(
          margin: const EdgeInsets.only(top: 25),
          width: MediaQuery.of(context).size.width,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("assets/images/profile_placeholder.png"),
                height: 200,
                width: 200,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Jane Doe",
                style: TextStyle(fontSize: 25),
              ),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut ",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.justify,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage("assets/images/vertical_placeholder.jpg"),
                    height: 200,
                    width: 150,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8,),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Titulo Placeholder",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Genero 1",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Genero 2",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "Genero 3",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          "Duração Ano",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 18, top: 10, bottom: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Criticos: ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "★★★★☆",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Usuarios: ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text(
                          "★★★★★",
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
