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
import 'package:hearable_device_sdk_sample/menu.dart';

import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math';

class Tennis extends StatelessWidget {
  const Tennis({super.key});

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

  var random = Random();
  bool _computerFlag = true;
  bool gameOver = false;
  bool sensor_flag = false;
  int repeat = 0;

  double _ballPositionY = 50.0;
  double _ballPositionX = 150.0;
  double _ballSpeedY = 0.0; // ボールの速度
  double _ballSpeedX = 0.0;

  double _paddleY = 50.0; // プレイヤーのパドルの位置
  double _paddleX = 50.0; // プレイヤーのパドルの位置

  double _computerPaddleY = 50.0; // コンピューターのパドルの位置
  double _computerPaddleX = 50.0; // コンピューターのパドルの位置

  double x = 0;
  double y = 0;
  double angz = 0;
  double x_initial = 0;
  double y_initial = 0;
  double angz_initial = 0;

  int playerScore = 0;
  int computerScore = 0;

  @override
  void initState() {
    super.initState();
    // フレームごとにアニメーションを更新
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _updateBallPosition();
    });
  }

  // ボールの位置を更新するメソッド
  void _updateBallPosition() {
    setState(() {
      // ボールの位置を更新
      _ballPositionY += _ballSpeedY;
      _ballPositionX += _ballSpeedX;

      // コンピューターの動き
      if(_computerFlag) {
        if(random.nextDouble() < 0.99) {
          _computerPaddleX += _ballSpeedX;
        } else {
          _computerPaddleX -= _ballSpeedX;
          _computerFlag = false;
        }
      } else {
        _computerPaddleX -= _ballSpeedX;
        repeat++;
        if (repeat > 10) {
          _computerFlag = true;
          repeat = 0;
        }
      }

      // ボールがミスされた場合の得点処理
      if (_ballPositionY >= MediaQuery.of(context).size.height - 96 || _ballPositionY <= 0) {
        // コンピューターがボールをミスした場合
        if (_ballPositionY >= MediaQuery.of(context).size.height - 96 - 50) {
          playerScore++;
          _ballSpeedY = -1.0 - random.nextDouble() * 2;
        } else {
          // プレイヤーがボールをミスした場合
          computerScore++;
          _ballSpeedY = 1.0 + random.nextDouble() * 2;
        }
        // ボールの位置をリセット
        _ballPositionY = (MediaQuery.of(context).size.height - 96) / 2;
        _ballPositionX = MediaQuery.of(context).size.width / 2;
        _computerPaddleX = MediaQuery.of(context).size.width / 2 - 50;
        _computerPaddleY = MediaQuery.of(context).size.height - 96 - 50;
        // ボールの速度をランダムにリセット
        _ballSpeedX = random.nextDouble() * 4 - 2;

        // ゲーム終了条件のチェック
        if (playerScore >= 3 || computerScore >= 3) {
          gameOver = true;
        }

      }
      

      // 画面の端で反射する
      if (_ballPositionX >= MediaQuery.of(context).size.width - 20 || _ballPositionX <= 0) {
        _ballSpeedX = -_ballSpeedX;
      }

      //コンピューターのパドルが画面外に出ないように制限
      if (_computerPaddleY < (MediaQuery.of(context).size.height - 96) / 2) {
        _computerPaddleY = (MediaQuery.of(context).size.height - 96) / 2;
      } else if (_computerPaddleY > MediaQuery.of(context).size.height - 96) {
        _computerPaddleY = MediaQuery.of(context).size.height - 96;
      }
      if (_computerPaddleX < 0) {
        _computerPaddleX = 0;
      } else if (_computerPaddleX > MediaQuery.of(context).size.width - 100) {
        _computerPaddleX = MediaQuery.of(context).size.width - 100;
      }

      // プレイヤーのパドルとの当たり判定
      if (_ballPositionY >= _paddleY + y - 10 && _ballPositionY <= _paddleY + y &&
          _ballPositionX >= _paddleX - x && _ballPositionX <= _paddleX - x + 100) {
        _ballSpeedY = -_ballSpeedY * 1.05;
        _ballSpeedX = angz;
      }

      // コンピューターのパドルとの当たり判定
      if (_ballPositionY >= _computerPaddleY - 10 && _ballPositionY <= _computerPaddleY &&
          _ballPositionX >= _computerPaddleX && _ballPositionX <= _computerPaddleX + 100) {
        _ballSpeedY = -_ballSpeedY * 1.05;
        _ballSpeedX = random.nextDouble() * 4 - 2;
      }

    });

    // ゲームが終了していない場合、次のフレームの更新をスケジュール
    if (!gameOver) {
      Future.delayed(Duration(milliseconds: 16), _updateBallPosition);
    }
  }

  // プレイヤーのパドルの移動処理
  void _movePaddle(Offset delta) {
    setState(() {
      _paddleY -= delta.dy;
      _paddleX += delta.dx;

      // プレイヤーのパドルが画面外に出ないように制限
      if (y < -50) {
        y = -50;
      } else if (y > (MediaQuery.of(context).size.height - 96 - 50) / 2 - 50) {
        y = (MediaQuery.of(context).size.height - 96 - 50) / 2 - 50;
      }
      if (x < -50) {
        x = -50;
      } else if (_paddleX > MediaQuery.of(context).size.width - 150) {
        _paddleX = MediaQuery.of(context).size.width - 150;
      }
    });
  }

  // ゲームリセット
  void _resetGame() {
    setState(() {
      playerScore = 0;
      computerScore = 0;
      gameOver = false;
      _ballPositionY = MediaQuery.of(context).size.height / 2;
      _ballPositionX = MediaQuery.of(context).size.width / 2;
      _ballSpeedY = random.nextDouble() * 4 - 2;
      _ballSpeedX = random.nextDouble() * 4 - 2;
    });
    _updateBallPosition();
  }

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

  Widget _buildButtons() {
  return Positioned(
    bottom: 20,
    left: 20,
    child: Row(
      children: [
        ElevatedButton(
          onPressed: () {
            // 再生する場合の処理
            // ここで再生するための処理を実装してください
          },
          child: Text('再生する'),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            // 前の画面に戻る場合の処理
            // ここで前の画面に戻るための処理を実装してください
          },
          child: Text('前の画面に戻る'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    _computerPaddleY = MediaQuery.of(context).size.height - 96 - 100;
    _setRequiredNumText();
    _setBatteryIntervalText();

    final List<double> data = [0.45, 0.75, 1.0];
    final double maxValue = 1.0;

    if (!isSetEaaCallback) {
      eaa.addEaaListener(
        registerCallback: _registerCallback,
        cancelRegistrationCallback: null,
        deleteRegistrationCallback: _deleteRegistrationCallback,
        verifyCallback: _verifyCallback,
        getRegistrationStatusCallback: _getRegistrationStatusCallback,
      );
      isSetEaaCallback = true;
    }

    String imagePath = 'assets/candle1.jpg';
    int ballOutOfBoundCount = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('テニスゲーム', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(48, 116, 187, 10),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
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
                  children: [
                    const SizedBox(height: 10),
                    const SizedBox(
                      height: 20,
                    ),
                    Consumer<NineAxisSensor>(
                      builder: ((context, nineAxisSensor, _) => Widgets.switchContainer2(
                        title: '9軸センサ：',
                        enable: nineAxisSensor.isEnabled,
                        function: _switch9AxisSensor,
                      )),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          sensor_flag = true;
                          tapStartTime = DateTime.now();
                          _ballSpeedY = 2.0; // ボールの速度
                          _ballSpeedX = 2.0;
                          x_initial = NineAxisSensor().getposZ().toDouble();
                          y_initial = NineAxisSensor().getposY().toDouble();
                          angz_initial = NineAxisSensor().getangZ().toDouble();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('スタート'),
                      ),
                    ),  
                  ],
                ),
              ),
            ),
          ),
          if (gameOver) ...[
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playerScore >= 3 ? "YOU WIN!" : "YOU LOSE",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: _resetGame,
                    child: Text('Restart'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Menu()),
                      );
                    },
                    child: Text('Back to home'),
                  ),
                ],
              ),
            ),
          ] else ...[
            GestureDetector(
              // onPanUpdate: (details) {
              //   _movePaddle(details.delta);
              // },
              child: Stack(
                children: [
                  Positioned(
                    bottom: _ballPositionY,
                    left: _ballPositionX,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Consumer<NineAxisSensor>(
                    builder: (context, nineAxisSensor, _) {
                      if (sensor_flag) {
                        x = (nineAxisSensor.getposZ() - x_initial).toDouble() / 4;
                        y = (nineAxisSensor.getposY() - y_initial).toDouble() / 4;
                        angz = (nineAxisSensor.getangX() - angz_initial).toDouble();
                      }
                      
                      if (y < -50) {
                        y = -50;
                      } else if (y > (MediaQuery.of(context).size.height - 96 - 50) / 2 - 50) {
                        y = (MediaQuery.of(context).size.height - 96 - 50) / 2 - 50;
                      }
                      if (x > -50) {
                        x > -50;
                      } else if (x < MediaQuery.of(context).size.width - 150) {
                        x = MediaQuery.of(context).size.width - 150;
                      }
                      if (angz < -4.0) {
                        angz = -4.0;
                      } else if (angz > 4.0) {
                        angz = 4.0;
                      }
                      
                      print("angle z : $angz");
                      
                      return Positioned(
                        bottom: _paddleY + y,
                        left: _paddleX - x,
                        child: Container(
                          width: 100,
                          height: 10,
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: _computerPaddleY,
                    left: _computerPaddleX,
                    child: Container(
                      width: 100,
                      height: 10,
                      color: Colors.green,
                    ),
                  ),
                  Positioned(
                    top: (MediaQuery.of(context).size.height - 96) / 2,
                    left: MediaQuery.of(context).size.width / 2 - 120,
                    child: Text(
                      'Player: $playerScore',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                  Positioned(
                    top: (MediaQuery.of(context).size.height - 96) / 2,
                    right: MediaQuery.of(context).size.width / 2 - 120,
                    child: Text(
                      'Computer: $computerScore',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}