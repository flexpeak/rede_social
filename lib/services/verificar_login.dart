import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rede_social/pages/feed.dart';
import 'package:rede_social/pages/login.dart';

class VerificarLogin extends StatefulWidget {
  const VerificarLogin({super.key});

  @override
  State<VerificarLogin> createState() => _VerificarLoginState();
}

class _VerificarLoginState extends State<VerificarLogin> {
  Future<bool>? usuarioLogado;

  Future<bool> _verificarUsuarioLogado() async {
    Box box = await Hive.openBox('usuarios');
    String? token = box.get('idToken');
    return token != null;
  }

  @override
  void initState() {
    usuarioLogado = _verificarUsuarioLogado();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: usuarioLogado,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData && snapshot.data == true) {
            return const Feed();
          } else {
            return const Login();
          }
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      });
  }
}
