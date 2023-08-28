import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';

import '../../../controllers/useraudio_controller.dart';

/// Example app.
class UserAudioPage extends GetView<UserAudioController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text('Usuario de audio'),
        ),
        body: StreamBuilder(
          stream: controller.streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Obx(() => Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: 500,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: Text("IP: ",
                                  style: TextStyle(
                                      fontFamily: "Helvetica",
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  hintText: 'Ingresa el ip',
                                  hintStyle: TextStyle(fontSize: 25),
                                ),
                                style: TextStyle(fontSize: 25),
                                onChanged: (val) async {
                                  controller.saveIP(val);
                                },
                              ),
                            ),
                          ]),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: controller.connectDisconeectServer,
                          child: Text(controller.blConnectServer.value
                              ? 'Desconectar del server'
                              : 'Conectar server'),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(controller.blConnectServer.value
                            ? 'Conectado'
                            : 'Desconectado'),
                      ]),
                    ),
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: controller.onOffSound,
                          child: Text(controller.blEscucharSonido.value
                              ? "Apagar Sonido"
                              : "Encender Sonido"),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(controller.blEscucharSonido.value
                            ? "Sonido encendido"
                            : 'Sonido Apagado'),
                      ]),
                    ),
                  ],
                ));
          },
        ));
  }
}
