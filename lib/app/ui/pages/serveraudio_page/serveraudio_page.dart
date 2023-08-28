import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/serveraudio_controller.dart';

/// Pagina para el ui del servidor de audio
class ServerAudioPage extends GetView<ServerAudioController> {
  /// Controller simplificado
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Server Audio'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: controller.streamSocket.getResponse,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Obx(
                () => Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(3),
                      height: 80,
                      width: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF0E6),
                        border: Border.all(
                          color: Colors.indigo,
                          width: 3,
                        ),
                      ),
                      child: Row(children: [
                        ElevatedButton(
                          onPressed: controller.onOffServer,
                          child: Text(controller.blServer.value
                              ? "Apagar Server"
                              : "Iniciar Server"),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(controller.blServer.value
                            ? "Server Conectado"
                            : "Server Desconectado")
                      ]),
                    ),
                    controller.blServer.value && controller.lsClients.isNotEmpty
                        ? Container(
                            margin: const EdgeInsets.all(3),
                            padding: const EdgeInsets.all(3),
                            height: 80,
                            width: double.infinity,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF0E6),
                              border: Border.all(
                                color: Colors.indigo,
                                width: 3,
                              ),
                            ),
                            child: Row(children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (controller.blRecorder.value) {
                                    controller.stopRecorder();
                                  } else {
                                    controller.startRecorder();
                                  }
                                },
                                child: Text(controller.blRecorder.value
                                    ? "Stop"
                                    : "Enviar audio Microphone"),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(controller.blSendAudio.value
                                  ? "Enviando Audio..."
                                  : "")
                            ]),
                          )
                        : Container(),
                    Container(
                        margin: const EdgeInsets.all(3),
                        padding: const EdgeInsets.all(3),
                        height: 300,
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF0E6),
                          border: Border.all(
                            color: Colors.indigo,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Container(
                                  height: 40,
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Color.fromARGB(255, 121, 184, 255),
                                      width: 4,
                                    ),
                                  ),
                                  child: Text.rich(
                                    TextSpan(
                                        text: "Dirección IP: ",
                                        style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 50, 50, 50),
                                            fontFamily: 'Helvetica',
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                        children: <InlineSpan>[
                                          TextSpan(
                                            text: controller.ip.value,
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 50, 50, 50),
                                                fontSize: 25,
                                                fontWeight: FontWeight.normal),
                                          )
                                        ]),
                                    textAlign: TextAlign.center,
                                  ),
                                )),
                            const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Text("Clientes",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 50, 50, 50),
                                      fontFamily: 'Helvetica',
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            client(controller.lsClients)
                          ],
                        ))
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget client(RxList clients) {
    if (clients.isEmpty) {
      return Text("No hay clientes");
    } else {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: clients.length,
        itemBuilder: (BuildContext context, int index) => Container(
          height: 50,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 219, 247, 216),
            border: Border.all(
              color: const Color(0xFFFAF0E6),
              width: 3,
            ),
          ),
          child: Center(child: Text(clients[index])),
        ),
      );
    }
  }

  Column clmClients(List lsClients) {
    List<Widget> lsClmClients = [];

    /// Agregar Title
    lsClmClients.add(const Text("Clientes",
        style: TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontFamily: 'Helvetica',
            fontSize: 25,
            fontWeight: FontWeight.bold)));
    lsClmClients.add(const Text("Clientes",
        style: TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontFamily: 'Helvetica',
            fontSize: 25,
            fontWeight: FontWeight.bold)));
    lsClmClients.add(const Text("Clientes",
        style: TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontFamily: 'Helvetica',
            fontSize: 25,
            fontWeight: FontWeight.bold)));
    lsClmClients.add(const Text("Clientes",
        style: TextStyle(
            color: Color.fromARGB(255, 50, 50, 50),
            fontFamily: 'Helvetica',
            fontSize: 25,
            fontWeight: FontWeight.bold)));
    if (lsClients.isEmpty) {
      lsClmClients.add(const Text("Lista Vacia"));
    } else {
      for (var i = 0; i < lsClients.length; i++) {
        lsClmClients.add(Text(lsClients[i]));
      }
    }
    return Column(children: lsClmClients);
  }
}
