import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io/socket_io.dart';

/// Stream Server Audio
class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

/// Puerto para el servidor
const port = 2000;

class ServerAudioController extends GetxController {
  /// Direccion IP
  RxString ip = ''.obs;

  /// Server Iniciador
  Server io = Server();

  /// Clientes del Server
  var svClients;

  /// Server conectado o desconectado
  RxBool blServer = false.obs;

  /// Enviar audio
  RxBool blSendAudio = false.obs;

  /// Verificar si esta transmitiendo el audio del microfono
  RxBool blRecorder = false.obs;

  /// Lista de Clientes
  RxList<dynamic> lsClients = [].obs;

  /// Stream del server audio
  StreamSocket streamSocket = StreamSocket();

  /// Codigo del formato de audio
  Codec codec = Codec.pcm16;

  /// Obtenemos los datos de los usuarios
  final usersStateController = StreamController<Food>();
  StreamSink<Food> get mStreamSink => usersStateController.sink;
  Stream<Food> get users => usersStateController.stream;

  /// Declaramos para grabar el audio del microfono
  FlutterSoundRecorder? mRecorder = FlutterSoundRecorder();

  @override
  void onInit() async {
    ip.value = await getIp();
    openTheRecorder().then((value) {});
    super.onInit();
  }

  @override
  void onClose() {
    mRecorder!.closeRecorder();
    mRecorder = null;
    super.onClose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await mRecorder!.openRecorder();
    if (!await mRecorder!.isEncoderSupported(codec) && kIsWeb) {
      codec = Codec.opusWebM;
      if (!await mRecorder!.isEncoderSupported(Codec.opusWebM) && kIsWeb) {
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
  }

  Future<void> stopRecorder() async {
    await mRecorder!.stopRecorder().then((value) {
      blRecorder.value = false;
    });
  }

  Future<void> startRecorder() async {
    mRecorder!
        .startRecorder(
      toStream: mStreamSink,
      codec: Codec.pcm16,
    )
        .then((value) async {
      blSendAudio.value = true;
      blRecorder.value = true;
      users.listen((buffer) {
        if (buffer is FoodData) {
          svClients.emit('fromServer', buffer.data);
        }
      });
    });
  }

  void onOffServer() {
    var nsp = io.of('/usuarios');

    /// Desconectar Server
    if (blServer.value) {
      blServer.value = false;
      lsClients.clear();
      io.close();
    }

    /// Conectar Server
    else {
      blServer.value = true;
      nsp.on('connection', (client) {
        svClients = client;
        client.on('msg', (newClient) {
          /// Verificamos si el cliente ya esta conectado
          bool blWhClients = lsClients
              .where((stClient) =>
                  stClient.toLowerCase().contains(newClient.toLowerCase()))
              .toList()
              .isEmpty;
          if (blWhClients) {
            lsClients.add(newClient);
            client.emit('fromServer', "Conectado");
          } else {
            client.emit('fromServer', "Ya esta conectado");
          }
          lsClients = lsClients;
        });
      });
      io.listen(port);
    }
  }

  Future<String> getIp() async {
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        return addr.address;
      }
    }
    return "Desconocida";
  }
}
