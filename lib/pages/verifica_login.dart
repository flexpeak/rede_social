import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:hive/hive.dart';
import 'package:rede_social/pages/feed.dart';
import 'package:rede_social/pages/login.dart';

class VerificaLogin extends StatefulWidget {
  const VerificaLogin({super.key});

  @override
  State<VerificaLogin> createState() => _VerificaLoginState();
}

class _VerificaLoginState extends State<VerificaLogin> {
  Future<bool>? _estaLogado;

  @override
  void initState() {
    _estaLogado = _checkLoginStatus();
    super.initState();
  }

  Future<bool> _checkLoginStatus() async {
    Box userBox = await Hive.openBox('user');
    String? token = userBox.get('idToken');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _estaLogado,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
      },
    );
  }
}