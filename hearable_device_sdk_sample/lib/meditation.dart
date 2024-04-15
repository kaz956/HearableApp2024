import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

//import 'package:hearable_device_sdk_sample/size_config.dart';
//import 'package:hearable_device_sdk_sample/widget_config.dart';
import 'package:hearable_device_sdk_sample/widgets.dart';
import 'package:hearable_device_sdk_sample/alert.dart';
import 'package:hearable_device_sdk_sample/nine_axis_sensor.dart';
import 'package:hearable_device_sdk_sample/temperature.dart';
import 'package:hearable_device_sdk_sample/heart_rate.dart';
import 'package:hearable_device_sdk_sample/ppg.dart';
import 'package:hearable_device_sdk_sample/eaa.dart';
import 'package:hearable_device_sdk_sample/battery.dart';
import 'package:hearable_device_sdk_sample/config.dart';

import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math';

class Meditate extends StatelessWidget {
  const Meditate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: NineAxisSensor()),
        ChangeNotifierProvider.value(value: Temperature()),
        ChangeNotifierProvider.value(value: HeartRate()),
        ChangeNotifierProvider.value(value: Ppg()),
        ChangeNotifierProvider.value(value: Eaa()),
        ChangeNotifierProvider.value(value: Battery()),
      ],
      child: _HearableServiceView(),
    );
  }
}

class _HearableServiceView extends StatefulWidget {
  @override
  State<_HearableServiceView> createState() => _HearableServiceViewState();
}

class _HearableServiceViewState extends State<_HearableServiceView> {
  DateTime? tapStartTime;
  Duration elapsedTime = Duration.zero;

  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  String userUuid = (Eaa().featureGetCount == 0)
      ? const Uuid().v4()
      : Eaa().registeringUserUuid;
  var selectedIndex = -1;
  var selectedUser = '';
  bool isSetEaaCallback = false;

  var config = Config();
  Eaa eaa = Eaa();

  TextEditingController featureRequiredNumController = TextEditingController();
  TextEditingController featureCountController = TextEditingController();
  TextEditingController eaaResultController = TextEditingController();

  TextEditingController nineAxisSensorResultController =
      TextEditingController();
  TextEditingController temperatureResultController = TextEditingController();
  TextEditingController heartRateResultController = TextEditingController();
  TextEditingController ppgResultController = TextEditingController();

  TextEditingController batteryIntervalController = TextEditingController();
  TextEditingController batteryResultController = TextEditingController();

  void _createUuid() {
    userUuid = const Uuid().v4();

    eaa.featureGetCount = 0;
    eaa.registeringUserUuid = userUuid;
    _samplePlugin.cancelEaaRegistration();

    setState(() {});
  }

  void _feature() async {
    eaa.registeringUserUuid = userUuid;
    _showDialog(context, '特徴量取得・登録中...');
    // 特徴量取得、登録
    if (!(await _samplePlugin.registerEaa(uuid: userUuid))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー削除
    if (!(await _samplePlugin.deleteSpecifiedRegistration(
        uuid: selectedUser))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteAllRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー全削除
    if (!(await _samplePlugin.deleteAllRegistration())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _cancelRegistration() async {
    // 特徴量登録キャンセル
    if (!(await _samplePlugin.cancelEaaRegistration())) {
      // エラーダイアログ
      Alert.showAlert(context, 'IllegalStateException');
    }
  }

  void _verify() async {
    _showDialog(context, '照合中...');
    // 照合
    if (!(await _samplePlugin.verifyEaa())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _requestRegisterStatus() async {
    _showDialog(context, '登録状態取得中...');
    // 登録状態取得
    if (!(await _samplePlugin.requestRegisterStatus())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _switch9AxisSensor(bool enabled) async {
    NineAxisSensor().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await NineAxisSensor().addNineAxisSensorNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        NineAxisSensor().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  // 選択可能なListView
  ListView _createUserListView(BuildContext context) {
    return ListView.builder(
        // 登録ユーザー数
        itemCount: eaa.uuids.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              selected: selectedIndex == index ? true : false,
              selectedTileColor: Colors.grey.withOpacity(0.3),
              title: Widgets.uuidText(eaa.uuids[index]),
              onTap: () {
                if (index == selectedIndex) {
                  _resetSelection();
                } else {
                  selectedIndex = index;
                  selectedUser = eaa.uuids[index];
                }
                setState(() {});
              },
            ),
          );
        });
  }

  void _showDialog(BuildContext context, String text) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return AlertDialog(
            content: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(text)
                  ],
                )
              ],
            ),
          );
        });
  }

  void _resetSelection() {
    selectedIndex = -1;
    selectedUser = '';
  }

  void _saveInput(BuildContext context) {
    var num = featureRequiredNumController.text;
    var interval = batteryIntervalController.text;

    if (num.isNotEmpty) {
      var num0 = int.parse(num);
      if (num0 >= 10 && num0 != config.featureRequiredNumber) {
        config.featureRequiredNumber = num0;
        _samplePlugin.setHearableEaaConfig(featureRequiredNumber: num0);
      }
    }
    _setRequiredNumText();

    if (interval.isNotEmpty) {
      var interval0 = int.parse(interval);
      if (interval0 >= 10 && interval0 != config.batteryNotificationInterval) {
        config.batteryNotificationInterval = interval0;
        _samplePlugin.setBatteryNotificationInterval(interval: interval0);
      }
    }
    _setBatteryIntervalText();

    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _onSavedFeatureRequiredNum(String? numStr) {
    if (numStr != null) {
      config.featureRequiredNumber = int.parse(numStr);
      _setRequiredNumText();
    }
    setState(() {});
  }

  void _onSavedBatteryInterval(String? intervalStr) {
    if (intervalStr != null) {
      config.batteryNotificationInterval = int.parse(intervalStr);
      _setBatteryIntervalText();
    }
    setState(() {});
  }

  void _setRequiredNumText() {
    featureRequiredNumController.text = config.featureRequiredNumber.toString();
    featureRequiredNumController.selection = TextSelection.fromPosition(
        TextPosition(offset: featureRequiredNumController.text.length));
  }

  void _setBatteryIntervalText() {
    batteryIntervalController.text =
        config.batteryNotificationInterval.toString();
    batteryIntervalController.selection = TextSelection.fromPosition(
        TextPosition(offset: batteryIntervalController.text.length));
  }

  void _registerCallback() {
    Navigator.of(context).pop();
  }

  void _deleteRegistrationCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  void __cancelRegistrationCallback() {
    eaa.featureGetCount = 0;
    setState(() {});
  }

  void _verifyCallback() {
    Navigator.of(context).pop();
  }

  void _getRegistrationStatusCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  Widget _buildElapsedTimeText() {
    if (tapStartTime != null) {
      elapsedTime = DateTime.now().difference(tapStartTime!);
      return Positioned(
        top: 20,
        left: MediaQuery.of(context).size.width / 2,
        child: Text(
          '${elapsedTime.inSeconds} 秒',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return Container(); // onTapされていない場合は何も表示しない
    }
  }

  @override
  Widget build(BuildContext context) {
    _setRequiredNumText();
    _setBatteryIntervalText();

    final List<double> data = [0.45, 0.75, 1.0];
    final double maxValue = 1.0;
    double x = 0;
    double y = 0;

    if (!isSetEaaCallback) {
      eaa.addEaaListener(
          registerCallback: _registerCallback,
          cancelRegistrationCallback: null,
          deleteRegistrationCallback: _deleteRegistrationCallback,
          verifyCallback: _verifyCallback,
          getRegistrationStatusCallback: _getRegistrationStatusCallback);
      isSetEaaCallback = true;
    }

    String imagePath = 'assets/candle1.jpg';
    int ballOutOfBoundCount = 0;
    double x_initial = 0;
    double y_initial = 0;
    bool sensor_flag = false;
    bool gameOver = false;

    return Scaffold(
      appBar: AppBar(
        //leadingWidth: SizeConfig.blockSizeHorizontal * 20,
        //leading: Widgets.barBackButton(context),
        title: const Text('座禅', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(48, 116, 187, 10),
        //iconTheme: const IconThemeData(color: Colors.blue),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              _saveInput(context);
            },
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const SizedBox(height: 10),
                    // 9軸センサ
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<NineAxisSensor>(
                      builder: ((context, nineAxisSensor, _) =>
                        Widgets.switchContainer(
                            title: '9軸センサ：',
                            enable: nineAxisSensor.isEnabled,
                            function: _switch9AxisSensor,
                        )
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          sensor_flag = true;
                          tapStartTime = DateTime.now();
                          x_initial = NineAxisSensor().getposZ().toDouble();
                          y_initial = NineAxisSensor().getposY().toDouble();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // ボタンの背景色を赤色に設定
                          foregroundColor: Colors.white, // ボタンのテキスト色を白色に設定
                        ),
                        child: Text('スタート'),
                      ),
                    ),
                    // 9軸センサ
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 50,
            child: Container(
              width: MediaQuery.of(context).size.width, // 横幅を画面の幅に合わせる
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Positioned(
                    top: 50,
                    left: MediaQuery.of(context).size.width / 2 - 100, // 横幅の中央に配置
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueGrey.shade300.withOpacity(0.8),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  for (int i = 0; i < 12; i++)
                    Positioned(
                      top: 150,
                      left: MediaQuery.of(context).size.width / 2 - 100, // 横幅の中央に配置
                      child: Transform.rotate(
                        angle: pi / 6 * i,
                        child: Container(
                          width: 200,
                          height: 0.5,
                          color: Colors.blueGrey.shade300.withOpacity(0.8),
                        ),
                      ),
                    ),
                  for (int i = 0; i < data.length; i++)
                    Positioned(
                      top: 150 - (data[i] * 100),
                      left: MediaQuery.of(context).size.width / 2 - (data[i] * 100), // 横幅の中央に配置
                      child: Container(
                        width: data[i] * 200,
                        height: data[i] * 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ),
                  Consumer<NineAxisSensor>(
                    builder: (context, nineAxisSensor, _) {
                      
                      if(sensor_flag) {
                        x = (nineAxisSensor.getposZ() - x_initial).toDouble();
                        y = (nineAxisSensor.getposY() - y_initial).toDouble();
                      }
                      
                      // ボールの可動範囲を円の内側に制限
                      double centerX = MediaQuery.of(context).size.width / 2 - 10;
                      double centerY = 140;
                      double radius = 100; // 円の半径

                      // ボールの中心から円の中心までの距離
                      double distanceToCenter = 
                        sqrt(pow(x , 2) + pow(y, 2));

                      // ボールが円の内側にあるかどうかをチェック
                      if (distanceToCenter <= radius) {
                        if (distanceToCenter <= 45) {
                          imagePath = 'assets/candle1.jpg';
                        } else if (distanceToCenter <= 75) {
                          imagePath = 'assets/candle2.jpg';
                        } else {
                          imagePath = 'assets/candle3.jpg';
                        }

                        if (ballOutOfBoundCount >= 3) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).size.height / 2,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              color: Colors.white.withOpacity(0.7),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ゲーム終了',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'プレイ時間: ${elapsedTime.inSeconds} 秒',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      ballOutOfBoundCount = 0;
                                    },
                                    child: Text('プレイを続ける'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('前の画面に戻る'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Stack(
                          children: [
                            // ボールを表示
                            Positioned(
                              top: centerY - y,
                              left: centerX + x,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            // キャンドル画像を表示
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 150,
                              child: Image.asset(
                                imagePath,
                                width: 240,
                                height: 360,
                              ),
                            ),
                          ],
                        );
                      } else {
                        imagePath = 'assets/candle4.jpg';
                        ballOutOfBoundCount++;
                        // 円の外側にある場合は円周上に配置し、色を赤くする
                        double angle = atan2(y - centerY, x - centerX);
                        double ballX = centerX + radius * cos(angle);
                        double ballY = centerY + radius * sin(angle);
                        gameOver = true;

                        if (ballOutOfBoundCount >= 3) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).size.height / 2,
                            child: Container(
                              padding: EdgeInsets.all(20),
                              color: Colors.white.withOpacity(0.7),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'ゲーム終了',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'プレイ時間: ${elapsedTime.inSeconds} 秒',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      ballOutOfBoundCount = 0;
                                    },
                                    child: Text('プレイを続ける'),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('前の画面に戻る'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Stack(
                            children: [
                              // ボールを表示
                              Positioned(
                                top: ballY,
                                left: ballX,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // キャンドル画像を表示
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 150,
                                child: Image.asset(
                                  imagePath,
                                  width: 240,
                                  height: 360,
                                ),
                              ),
                            ],
                          );
                        }
                      }
                    },
                  ),
                  _buildElapsedTimeText(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}