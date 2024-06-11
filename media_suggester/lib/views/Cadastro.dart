import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
                context, MaterialPageRoute(builder: (context) => Login()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration:  const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/home_background.png"),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Colors.black54, BlendMode.darken)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/logo_teste.png"),
                          fit: BoxFit.cover),
                    ),
                    height: 280,
                    width: 200),
              ),
              const Text(
                "Cadastro",
                style: TextStyle(fontSize: 50),
              ),
              const SizedBox(height: 20),
              //widget column utilizado para colocar um texto sobre cada campo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //label usuario
                  const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                      child: Text(
                        "Usuário",
                        style: TextStyle(fontSize: 20),
                      )),
                  //input usuario
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: TextField(
                        decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      hintText: "john doe",
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.inversePrimary,
                    )),
                  ),
                  //label email
                  const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                      child: Text(
                        "Email",
                        style: TextStyle(fontSize: 20),
                      )),
                  //input email
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                          hintText: "johndoe@gmail.com",
                          filled: true,
                          fillColor: Colors.white),
                    ),
                  ),
                  //label senha
                  const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                      child: Text(
                        "Senha",
                        style: TextStyle(fontSize: 20),
                      )),
                  //input senha
                   Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
                    child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                            hintText: "**********",
                            filled: true,
                            fillColor: Colors.white)),
                  ),
                  //label repetir senha
                  const Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                      child: Text(
                        "Repita a senha",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      )),
                  //input repitir senha
                   Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                          hintText: "**********",
                          filled: true,
                          fillColor: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CadastroPreferencias()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: const Text("Cadastar",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),),
                ),
              ),
              //sizedbox para nao deixar o botao colado na base da tela
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
