import 'dart:async';
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:device_info_plus/device_info_plus.dart';

///
typedef _Fn = void Function();

const theSource = AudioSource.microphone;

/// Stream Server Audio
class StreamSocket {
  final _socketResponse = StreamController<String>();

  void Function(String) get addResponse => _socketResponse.sink.add;

  Stream<String> get getResponse => _socketResponse.stream;

  void dispose() {
    _socketResponse.close();
  }
}

/// Example app.
class UserAudioPage extends StatefulWidget {
  @override
  _UserAudioPageState createState() => _UserAudioPageState();
}

class _UserAudioPageState extends State<UserAudioPage> {
  String ip = "";

  // final _formKey = GlobalKey<FormState>();

  final _formKey = GlobalKey<FormState>();

  /// Llave para los formularios.
  get formKey => _formKey;

  /// Stream del server audio
  StreamSocket streamSocket = StreamSocket();
  late Socket socket;
  Codec _codec = Codec.pcm16;
  String _mPath = 'tau_file.mp4';
  final _counterStateController = StreamController<Food>();
  StreamSink<Food> get _mStreamSink => _counterStateController.sink;
  Stream<Food> get counter => _counterStateController.stream;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool blConecctServer = false;
  bool blEscucharSonido = false;
  // StreamSink<Food>? _mStreamSink;
  // StreamSink? _mStreamSink = StreamSink();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

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

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    print("-------- Log M StreamSink ------");
    print(_mStreamSink);
    _mRecorder!
        .startRecorder(
      toStream: _mStreamSink,
      // toFile: _mPath,
      codec: Codec.pcm16,
      audioSource: theSource,
    )
        .then((value) async {
      setState(() {});
      print("-------- Log M StreamSink ------");
      print(_mStreamSink);
      await _mPlayer!.startPlayerFromStream(codec: Codec.pcm16);

      // _mPlayer.foodSink.add(FoodEvent(() {
      //   _mPlayer.stopPlayer();
      // }));
      counter.listen((buffer) {
        print("TUTUT");
        if (buffer is FoodData) {
          print("eNTRO");
          _mPlayer!.foodSink!.add(FoodData(buffer.data));
        }

        // _mPlayer!.foodSink!.add(FoodData(data));
        // data.dummy(_mPlayer!);
        // play();
        //      _mPlayer!
        //     .startPlayer(
        //                 codec: Codec.pcm16,
        //                 fromDataBuffer: data.,
        //         //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        //         whenFinished: () {
        //           setState(() {});
        //         })
        //     .then((value) {
        //   setState(() {});
        // })
      });
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

  void saveIP(val) {
    setState(() {
      ip = val;
    });
  }
// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  _Fn? streamconunter() {
    counter.listen((data) {
      print("Hola");
    });
  }

  void connectDisconeectServer() {
    if (blConecctServer) {
      setState(() {
        blConecctServer = false;
      });
      socket.onDisconnect((_) => print('disconnect'));
    } else {
      setState(() {
        blConecctServer = true;
      });
      socket = io(
          'http://192.168.1.198:2000/usuarios',
          OptionBuilder()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection
              .build());
      socket.connect();

      /// Verificamos si ocurrio un error
      socket.on('connect_error', (data) => print(data));
      socket.emit('msg', 'Cliente de web 1');
      socket.on('fromServer', (data) {
        print(blEscucharSonido);
        List<dynamic> listdy = data;
        List<int> listint = [];
        for (var i = 0; i < listdy.length; i++) {
          listint.add(listdy[i]);
        }
        try {
          Uint8List bytes = Uint8List.fromList(listint);
          if (blEscucharSonido) {
            print("Bytes:");
            print(bytes);
            print(blEscucharSonido);
            _mPlayer!.foodSink!.add(FoodData(bytes));
          }
        } catch (e) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          title: const Text('Usuario de audio'),
        ),
        body: StreamBuilder(
          stream: streamSocket.getResponse,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Column(
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
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Error ip incorrecto';
                              }
                              return null;
                            },
                            onChanged: (val) async {
                              saveIP(val);
                              var ip = val;
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
                      onPressed: () {
                        if (formKey.currentState!.validate()) {}
                      },
                      child: Text(blConecctServer
                          ? 'Desconectar del server'
                          : 'Conectar con server'),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(blConecctServer ? 'Conectado' : 'Desconectado'),
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
                      onPressed: () async {
                        if (blEscucharSonido) {
                          setState(() {
                            blEscucharSonido = false;
                          });
                          await _mPlayer!.stopPlayer();
                        } else {
                          setState(() {
                            blEscucharSonido = true;
                          });

                          await _mPlayer!
                              .startPlayerFromStream(codec: Codec.pcm16);
                        }
                      },
                      //color: Colors.white,
                      //disabledColor: Colors.grey,
                      child: Text(blEscucharSonido
                          ? "Apagar Sonido"
                          : "Encender Sonido"),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(blEscucharSonido
                        ? "Sonido encendido"
                        : 'Sonido Apagado'),
                  ]),
                ),
              ],
            );
          },
        ));
  }
}
