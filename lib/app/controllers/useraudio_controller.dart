import 'dart:async';
import 'dart:typed_data';

import 'package:audio_session/audio_session.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';

import 'package:socket_io_client/socket_io_client.dart';

/// Stream Server Audio
class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

class UserAudioController extends GetxController {
  final theSource = AudioSource.microphone;

  /// Direccion IP
  RxString ip = ''.obs;

  /// Nombre del dispositivo
  RxString deviceName = "".obs;

  final _formKey = GlobalKey<FormState>();

  /// Llave para los formularios.
  get formKey => _formKey;

  late Socket socket;

  /// Stream del server audio
  StreamSocket streamSocket = StreamSocket();
  Codec _codec = Codec.pcm16;
  String _mPath = 'tau_file.mp4';

  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  RxBool blConnectServer = false.obs;
  RxBool blEscucharSonido = false.obs;
  // StreamSink<Food>? _mStreamSink;
  // StreamSink? _mStreamSink = StreamSink();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  RxBool _mplaybackReady = false.obs;

  /// Obtenemos los datos de los usuarios
  final _counterStateController = StreamController<Food>();
  StreamSink<Food> get mStreamSink => _counterStateController.sink;
  Stream<Food> get counter => _counterStateController.stream;

  /// Ejecucion al iniciar aplicacion
  @override
  void onInit() async {
    // Obtenemos el nombre del dispositivo
    deviceName.value = await getDeviceName();
    // Abrimos el reproductor
    await _mPlayer!.openPlayer();
    // Abrimos el reproductor
    await openTheRecorder();
    super.onInit();
  }

  @override
  void onClose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;
    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.onClose();
  }

  void record() {
    _mRecorder!
        .startRecorder(
      toStream: mStreamSink,
      codec: Codec.pcm16,
      audioSource: theSource,
    )
        .then((value) async {
      print("-------- Log M StreamSink ------");
      print(mStreamSink);
      await _mPlayer!.startPlayerFromStream(codec: Codec.pcm16);

      counter.listen((buffer) {
        print("TUTUT");
        if (buffer is FoodData) {
          print("eNTRO");
          _mPlayer!.foodSink!.add(FoodData(buffer.data));
        }
      });
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      _mplaybackReady.value = true;
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady.value &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {})
        .then((value) {});
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {});
  }

  void saveIP(val) {
    ip.value = val;
  }

  void connectDisconeectServer() {
    try {
      print(blConnectServer.value);
      if (blConnectServer.value) {
        blConnectServer.value = false;

        print("Dalse");
        socket.onDisconnect((_) => print('disconnect'));
      } else {
        socket = io(
            'http://${ip.value}:2000/usuarios',
            OptionBuilder()
                .setTransports(['websocket']) // for Flutter or Dart VM
                .disableAutoConnect() // disable auto-connection
                .build());
        socket.connect();
        socket.on('connect', (data) {
          socket.emit('msg', "${deviceName.value}");
          blConnectServer.value = true;
        });
        socket.on('connect_error', (data) {
          blConnectServer.value = false;
          socket.close();
          Get.snackbar('Server', 'Error al conectar al server.');
        });
        socket.on('fromServer', (data) {
          if (data is List<dynamic>) {
            List<dynamic> listdy = data;
            List<int> listint = [];
            for (var i = 0; i < listdy.length; i++) {
              listint.add(listdy[i]);
            }
            Uint8List bytes = Uint8List.fromList(listint);
            if (blEscucharSonido.value) {
              _mPlayer!.foodSink!.add(FoodData(bytes));
            }
          }
        });
      }
    } catch (e) {
      blConnectServer.value = false;
    }
  }

  void onOffSound() async {
    if (blEscucharSonido.value) {
      blEscucharSonido.value = false;
      await _mPlayer!.stopPlayer();
    } else {
      blEscucharSonido.value = true;

      await _mPlayer!.startPlayerFromStream(codec: Codec.pcm16);
    }
  }

  /// Inicializacion al abrir el recorder
  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
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

  Future<String> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo info = await deviceInfo.androidInfo;
    return "${info.brand} ${info.device}";
  }
}
