
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

class LocalNoticeService{
  Future<void> setup() async {
    // #1
    const androidSetting = AndroidInitializationSettings('@mipmap/finallogodgasansfond');
    const iosSetting = IOSInitializationSettings();

    // #2
    const initSettings =
    InitializationSettings(android: androidSetting, iOS: iosSetting);

    // #3
    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      debugPrint('setupPlugin: setup success');
    }).catchError((Object error) {
      debugPrint('Error: $error');
    });
  }

  void addNotification(String title, String body)async{

// #2
    var androidDetail = const AndroidNotificationDetails(
        "channelId", // channel Id
        "channelName",
      importance: Importance.max,
      color: Colors.orange,
      enableVibration: true,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap("finallogodgasansfond"),
      styleInformation: MediaStyleInformation(
          htmlFormatContent: true, htmlFormatTitle: true),
      priority: Priority.high,
      playSound: true,// channel Name
    );

    var iosDetail = const IOSNotificationDetails();

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

// #4
    _localNotificationsPlugin.show(
      0,
      title,
      body,
      noticeDetail,
    );
  }
}

