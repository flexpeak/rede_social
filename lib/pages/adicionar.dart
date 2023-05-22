// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class Adicionar extends StatefulWidget {
  const Adicionar({super.key});

  @override
  State<Adicionar> createState() => _AdicionarState();
}

class _AdicionarState extends State<Adicionar> {
  final tituloController = TextEditingController();
  Position? localizacao;
  CameraController? cameraController;
  late List<CameraDescription> _cameras;
  XFile? _imagem;
  bool podeTirarFoto = false;
  bool podeFazerPostagem = false;
  bool isLoading = false;

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    localizacao = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _determinePosition();
    _inicializarCamera();
    super.initState();
  }

  _inicializarCamera() async {
    _cameras = await availableCameras();
    cameraController = CameraController(_cameras[0], ResolutionPreset.max);
    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (cameraController == null) {
      return Container();
    }

    return SingleChildScrollView(
      child: Stack(
        children: [
          IgnorePointer(
            child: SizedBox(
              height: !podeFazerPostagem ? size.height / 1.17 : size.height / 0.965,
              width: double.infinity,
              child: _imagem != null ? Image.file(File(_imagem!.path)) : CameraPreview(cameraController!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white.withOpacity(0.5),
              ),
              child: Column(
                children: [
                  const Text(
                    'FALE UM POUCO SOBRE ESSA FOTO',
                    style: TextStyle(
                      fontFamily: 'ReemKufiFun',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: tituloController,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.isNotEmpty && value.length > 5) {
                        setState(() {
                          podeTirarFoto = true;
                        });
                      } else {
                        setState(() {
                          podeTirarFoto = false;
                        });
                      }
                    },
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(0),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      label: Center(child: Text('DESCRIÇÃO')),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Color.fromARGB(255, 249, 250, 210),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: !podeFazerPostagem,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            podeTirarFoto ? const Color(0xFFEEF350) : Colors.grey.shade300,
                          ),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: !podeTirarFoto
                            ? null
                            : () async {
                                final imagem = await cameraController!.takePicture();
                                await Permission.photos.request();
                                await Permission.manageExternalStorage.request();
                                final imageBytes = await imagem.readAsBytes();
                                await ImageGallerySaver.saveImage(imageBytes);
                                setState(() {
                                  _imagem = imagem;
                                  podeFazerPostagem = true;
                                });
                              },
                        child: const Text('TIRAR FOTO',
                            style: TextStyle(
                              fontFamily: 'ReemKufiFun',
                              color: Colors.black87,
                            )),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: podeFazerPostagem,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            podeTirarFoto ? Colors.red : Colors.grey.shade300,
                          ),
                          elevation: MaterialStateProperty.all(0),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _imagem = null;
                            podeFazerPostagem = false;
                          });
                        },
                        child: const Text('DESCARTAR FOTO',
                            style: TextStyle(
                              fontFamily: 'ReemKufiFun',
                              color: Colors.black87,
                            )),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: podeFazerPostagem,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
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
                        onPressed: localizacao != null
                            ? () async {
                                setState(() {
                                  isLoading = true;
                                });
                                Box box = await Hive.openBox('usuarios');
                                const Uuid uuid = Uuid();

                                final responseImagem = await http.post(Uri.parse("${dotenv.env['HOST_STORAGE']}${uuid.v4()}.jpg"), body: await _imagem!.readAsBytes());

                                final resDataImg = jsonDecode(responseImagem.body);

                                final response = await http.post(
                                  Uri.parse("${dotenv.env['HOST_API']}/posts.json"),
                                  body: jsonEncode({
                                    'title': tituloController.text,
                                    'user_id': box.get('localId'),
                                    'photo': '${dotenv.env['HOST_STORAGE']}${resDataImg['name']}?alt=media&token=${resDataImg['downloadTokens']}',
                                    'user_email': box.get('email'),
                                    'lat': localizacao!.latitude.toString(),
                                    'lng': localizacao!.longitude.toString(),
                                  }),
                                );

                                setState(() {
                                  isLoading = false;
                                  _imagem = null;
                                  podeFazerPostagem = false;
                                });

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Postagem criada com sucesso'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Erro ao criar postagem'),
                                    ),
                                  );
                                }
                              }
                            : null,
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
                                'FAZER POSTAGEM',
                                style: TextStyle(
                                  fontFamily: 'ReemKufiFun',
                                  color: Colors.black87,
                                ),
                              ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
