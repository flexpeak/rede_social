// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rede_social/pages/login.dart';

class Configuracoes extends StatelessWidget {
  const Configuracoes({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          Box box = await Hive.openBox('usuarios');
          box.clear();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
          );
        },
        child: const Text('Fazer Logout'),
      ),
    );
  }
}
