import 'package:flutter/foundation.dart';
import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;

class NineAxisSensor extends ChangeNotifier {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  bool isEnabled = false;

  int? _resultCode;
  Uint8List? _data;


  factory NineAxisSensor() {
    return _instance;
  }

  NineAxisSensor._internal();

  int? get resultCode => _resultCode;
  Uint8List? get data => _data;
  int gyrx = 0;
  int gyry = 0;
  int gyrz = 0;
  int accx = 0;
  int accy = 0;
  int accz = 0;
  int posx = 0;
  int posy = 0;
  int posz = 0;
  double x1 = 0;
  double x2 = 0;
  double y1 = 0;
  double y2 = 0;
  double z = 0;
  double z2 = 0;
  int angx = 0;
  int angy = 0;
  int angz = 0;

  int getRandomNum() {
    //ランダム変数生成
    var random = math.Random();
    int randomNumber = random.nextInt(5); // 0から4の範囲で乱数を生成
    //print(randomNumber);
    return randomNumber;
  }

  int getangX() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsX = data[11].toRadixString(16); // 上位8ビット
      String lowerBitsX = data[12].toRadixString(16); // 下位8ビット

      String fullnumX = "$upperBitsX$lowerBitsX";
      int decimalValueX = int.parse(fullnumX, radix: 16); // 16進数を10進数に変換
      print(decimalValueX);
      if (decimalValueX > 23767) {
        decimalValueX -= 65536;
      }
      if (decimalValueX.abs() < 60) {
        return 0;
      }

      gyrx = decimalValueX;

      double deltagyrx = 5 * (decimalValueX / 1000) ;
    
      x1 += deltagyrx ;
      angx = x1.toInt();

      return angx;

    } else {
      return angx;
    }

    //return decimalValueX.toString();
  }

  int getposX() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsX = data[5].toRadixString(16); // 上位8ビット
      String lowerBitsX = data[6].toRadixString(16); // 下位8ビット

      String fullnumX = "$upperBitsX$lowerBitsX";
      int decimalValueX = int.parse(fullnumX, radix: 16); // 16進数を10進数に変換
      print(decimalValueX);
      if (decimalValueX > 23767) {
        decimalValueX -= 65536;
      }

      accx = decimalValueX;

      double deltaposx = 5 * (decimalValueX / 100) ;
    
      x2 += deltaposx ;
      posx = x2.toInt();

      return accx;

    } else {
      return accx;
    }

    //return decimalValueX.toString();
  }

  int getangY() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsY = data[13].toRadixString(16); // 上位8ビット
      String lowerBitsY = data[14].toRadixString(16); // 下位8ビット

      String fullnumY = "$upperBitsY$lowerBitsY";
      int decimalValueY = int.parse(fullnumY, radix: 16); // 16進数を10進数に変換
      print(decimalValueY);
      if (decimalValueY > 23767) {
        decimalValueY -= 65536;
      }
      if (decimalValueY.abs() < 60) {
        return 0;
      }

      gyry = decimalValueY;

      double deltagyry = 5 * (decimalValueY / 1000) ;

      y1 += deltagyry ;
      angy = y1.toInt();

      return angy;

    } else {
      return angy;
    }
  }

  int getposY() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsY = data[7].toRadixString(16); // 上位8ビット
      String lowerBitsY = data[8].toRadixString(16); // 下位8ビット

      String fullnumY = "$upperBitsY$lowerBitsY";
      int decimalValueY = int.parse(fullnumY, radix: 16); // 16進数を10進数に変換
      print(decimalValueY);
      if (decimalValueY > 23767) {
        decimalValueY -= 65536;
      }

      accy = decimalValueY;

      double deltaposy = 5 * (decimalValueY / 100) ;
    
      y2 += deltaposy ;
      posy = y2.toInt();

      return accy;

    } else {
      return accy;
    }
  }

//Copy
  int getangZ() {
    String str = '';
    int i = 0;
    double a = 0;

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //Z
      String upperBitsZ = data[15].toRadixString(16); // 上位8ビット
      String lowerBitsZ = data[16].toRadixString(16); // 下位8ビット

      String fullnumZ = "$upperBitsZ$lowerBitsZ";
      int decimalValueZ = int.parse(fullnumZ, radix: 16); // 16進数を10進数に変換
      print(decimalValueZ);
      if (decimalValueZ > 23767) {
        decimalValueZ -= 65536;
      }
      if (decimalValueZ.abs() < 60) {
        return angz;
      }
      gyrz = decimalValueZ;

      double deltagyrz = 5 * (decimalValueZ / 1000) ;

      z += deltagyrz ;
      angz = z.toInt();

      return angz;
    }

    else {
      return angz;
    }
  }

  int getposZ() {
    String str = '';

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsZ = data[9].toRadixString(16); // 上位8ビット
      String lowerBitsZ = data[10].toRadixString(16); // 下位8ビット

      String fullnumZ = "$upperBitsZ$lowerBitsZ";
      int decimalValueZ = int.parse(fullnumZ, radix: 16); // 16進数を10進数に変換
      print(decimalValueZ);
      if (decimalValueZ > 23767) {
        decimalValueZ -= 65536;
      }

      accz = decimalValueZ;

      double deltaposz = 5 * (decimalValueZ / 100) ;
    
      z2 += deltaposz ;
      posz = z2.toInt();

      return accz;

    } else {
      return accz;
    }
  }

  String getResultString() {
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    int accXoffset = 5;
    int accYoffset = 7;
    int accZoffset = 9;
    int gyrXoffset = 11;
    int gyrYoffset = 13;
    int gyrZoffset = 15;
    int magXoffset = 17;
    int magYoffset = 19;
    int magZoffset = 21;
    String accX = "";
    String accY = "";
    String accZ = "";
    String gyrX = "";
    String gyrY = "";
    String gyrZ = "";
    String magX = "";
    String magY = "";
    String magZ = "";

    /*サンプルアプリのオリジナルソースコード
    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i].toRadixString(16)}, ';
      }
      str += data.last.toRadixString(16);
    }*/

    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      for (int i = 0; i < 5; i++) {
        accX +=
            '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
        accY +=
            '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        accZ +=
            '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrX +=
            '${data[gyrXoffset + (i * 22)].toRadixString(16)}${data[gyrXoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrY +=
            '${data[gyrYoffset + (i * 22)].toRadixString(16)}${data[gyrYoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrZ +=
            '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[gyrZoffset + 1 + (i * 22)].toRadixString(16)}';
        magX +=
            '${data[magXoffset + (i * 22)].toRadixString(16)}${data[magXoffset + 1 + (i * 22)].toRadixString(16)}';
        magY +=
            '${data[magYoffset + (i * 22)].toRadixString(16)}${data[magYoffset + 1 + (i * 22)].toRadixString(16)}';
        magZ +=
            '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[magZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          accX += ',';
          accY += ',';
          accZ += ',';
          gyrX += ',';
          gyrY += ',';
          gyrZ += ',';
          magX += ',';
          magY += ',';
          magZ += ',';
        }
      }
      str += 'accX:' +
          accX +
          '\n' +
          'accY:' +
          accY +
          '\n' +
          'accZ:' +
          accZ +
          '\n' +
          'gyrX:' +
          gyrX +
          '\n' +
          'gyrY:' +
          gyrY +
          '\n' +
          'gyrZ:' +
          gyrZ +
          '\n' +
          'magX:' +
          magX +
          '\n' +
          'magY:' +
          magY +
          '\n' +
          'magZ:' +
          magZ;
    }
    return str;
  }

//Copy
  int getResultX() {
    String str = '';
    int i = 0;
    double a = 0;

    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (i = 0; i < data.length - 1; i++) {
        str += '${data[i]}, ';
      }
      str += data.last.toRadixString(16);

      //X
      String upperBitsX = data[11].toRadixString(16); // 上位8ビット
      String lowerBitsX = data[12].toRadixString(16); // 下位8ビット

      String fullnumX = "$upperBitsX$lowerBitsX";
      int decimalValueX = int.parse(fullnumX, radix: 16); // 16進数を10進数に変換
      print(decimalValueX);

      accx = decimalValueX;

      //Y
      String upperBitsY = data[13].toRadixString(16); // 上位8ビット
      String lowerBitsY = data[14].toRadixString(16); // 下位8ビット

      String fullnumY = "$upperBitsY$lowerBitsY";
      int decimalValueY = int.parse(fullnumY, radix: 16); // 16進数を10進数に変換
      print(decimalValueY);

      //Z
      String upperBitsZ = data[15].toRadixString(16); // 上位8ビット
      String lowerBitsZ = data[16].toRadixString(16); // 下位8ビット

      String fullnumZ = "$upperBitsZ$lowerBitsZ";
      int decimalValueZ = int.parse(fullnumZ, radix: 16); // 16進数を10進数に変換
      print(decimalValueZ);
      if (decimalValueZ > 23767) {
        decimalValueZ -= 65536;
      }
      gyrz = decimalValueZ;

      if (decimalValueX > 23767) {
        decimalValueX -= 65536;
      }
      //角速度ー＞角度に補正

      // Δt [s](元のセンシング周期は単位がμsだったので、(1000.0 * 1000.0)で割ることで単位をsに変換)
      /*double deltaT = 5*decimalValueZ / 100 ;

      //double a = 0;
      a += deltaT ;
      int angz=a.toInt();

      return angz;*/

      return decimalValueZ;
    }
    //return decimalValueZ;
    //return gyrx;

    else {
      return 0;
    }
  }

  Future<bool> addNineAxisSensorNotificationListener() async {
    final res = await _samplePlugin.addNineAxisSensorNotificationListener(
        onStartNotification: _onStartNotification,
        onStopNotification: _onStopNotification,
        onReceiveNotification: _onReceiveNotification);
    return res;
  }

  void _removeNineAxisSensorNotificationListener() {
    _samplePlugin.removeNineAxisSensorNotificationListener();
  }

  void _onStartNotification(int resultCode) {
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onStopNotification(int resultCode) {
    _removeNineAxisSensorNotificationListener();
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onReceiveNotification(Uint8List? data, int resultCode) {
    _data = data;
    _resultCode = resultCode;
    notifyListeners();
  }
}
