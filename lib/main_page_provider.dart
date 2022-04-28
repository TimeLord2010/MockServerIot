import 'dart:async';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:alfred/alfred.dart';
import 'package:flutter/material.dart';

class MainPageProvider with ChangeNotifier {
  final alfred = Alfred();
  final networkInfo = NetworkInfo();

  int port = 3000;

  double envTemp = 30;
  double minTemp = 25;
  double temp = 28;
  bool isFanOn = false;
  double delta = 0.05;

  String? _ip;

  Future<String> get ip async {
    _ip ??= await networkInfo.getWifiIP() ?? '<error>';
    return _ip!;
  }

  void run() async {
    alfred.get('/temperatura', (req, res) {
      res.json({
        'temperatura': temp,
      });
    });
    alfred.post('/temperatura', (req, res) async {
      final body = await req.body;
      Map map = body as Map;
      temp = map['temperatura'];
      envTemp = map['temperaturaAmbiente'] ?? envTemp;
      minTemp = map['temperaturaMinima'] ?? minTemp;
      res.json({
        'status': "sucesso",
      });
      notifyListeners();
    });
    alfred.post('/ventilador', (req, res) async {
      final body = await req.body;
      Map map = body as Map;
      bool valor = map['estado'];
      isFanOn = valor;
      notifyListeners();
    });
    alfred.get('/ventilador', (req, res) async {
      res.json({
        'estado': isFanOn,
        'temperatura': minTemp,
      });
    });
    runFan();
    await alfred.listen(port);
  }

  void runFan() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isFanOn) {
        if (temp > minTemp) {
          temp = temp - delta;
        }
      } else {
        if (temp < envTemp) {
          temp = temp + delta;
        }
      }
      debugPrint('$isFanOn: $minTemp / $temp / $envTemp');
      notifyListeners();
    });
  }
}
