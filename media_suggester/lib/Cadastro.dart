import 'package:flutter/material.dart';
import 'Login.dart';
import 'CadastroPreferencias.dart';

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Color(0x00000000),
        elevation: 0,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Login()));
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/home_background.png"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/logo_teste.png"),
                      fit: BoxFit.cover),
                ),
                height: 280,
                width: 200),
            Text(
              "Cadastro",
              style: TextStyle(fontSize: 50, color: Colors.white),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 15),
              child: TextField(
                  decoration: InputDecoration(
                      label: Text("Usuário"),
                      filled: true,
                      fillColor: Colors.white)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 15),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Email"),
                    filled: true,
                    fillColor: Colors.white),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 15),
              child: TextField(
                  decoration: InputDecoration(
                      label: Text("Senha"),
                      filled: true,
                      fillColor: Colors.white)),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30),
              child: TextField(
                decoration: InputDecoration(
                    label: Text("Confirmar Senha"),
                    filled: true,
                    fillColor: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 120,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CadastroPreferencias()));
                },
                child: Text("Enviar"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
