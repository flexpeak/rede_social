// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rede_social/pages/registrar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:rede_social/pages/feed.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool isLoading = false;

  _loginFirebase() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${dotenv.env['FIREBASE_TOKEN']}"),
      body: jsonEncode(
        {
          'email': _emailController.text,
          'password': _senhaController.text,
          'returnSecureToken': true,
        },
      ),
    );

    setState(() {
      isLoading = false;
    });

    Map responseData = jsonDecode(response.body);

    if (responseData['error'] == null) {
      Box box = await Hive.openBox('usuarios');
      box.put('idToken', responseData['idToken']);
      box.put('email', responseData['email']);
      box.put('refreshToken', responseData['refreshToken']);
      box.put('expiresIn', responseData['expiresIn']);
      box.put('localId', responseData['localId']);
      box.put('registered', responseData['registered']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário loggado com sucesso'),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Feed(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(responseData['error']['message']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/background.png', repeat: ImageRepeat.repeat),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/place.svg', width: 220),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFFDFDFD),
                          border: Border.all(color: const Color(0xFFEEF350), width: 2),
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            children: [
                              const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'ReemKufiFun',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 30),
                              TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(1),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  label: Text('Email'),
                                  prefixIcon: Icon(TablerIcons.mail, color: Colors.black45),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 249, 250, 210),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _senhaController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Campo obrigatório';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.all(1),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  label: Text('Senha'),
                                  prefixIcon: Icon(TablerIcons.key, color: Colors.black45),
                                  filled: true,
                                  fillColor: Color.fromARGB(255, 249, 250, 210),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                height: 43,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : _loginFirebase,
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      const Color(0xFFEEF350),
                                    ),
                                    elevation: MaterialStateProperty.all(0),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                        height: 15,
                                        width: 15,
                                        child: CircularProgressIndicator(
                                            color: Colors.black87,
                                            strokeWidth: 2,
                                          ),
                                      )
                                      : const Text(
                                          'FAZER LOGIN',
                                          style: TextStyle(
                                            fontFamily: 'ReemKufiFun',
                                            color: Colors.black87,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  elevation: MaterialStateProperty.all(0),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Registrar(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'ME CADASTRAR',
                                  style: TextStyle(
                                    fontFamily: 'ReemKufiFun',
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
