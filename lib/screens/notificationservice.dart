import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings =
  const AndroidInitializationSettings("@mipmap/finallogodgasansfond");
  final IOSInitializationSettings iosInitializationSettings =
  const IOSInitializationSettings();

  void initialiseNotification() async{
    InitializationSettings initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String title, String body) async{
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
      'channelId',
      'channelName',
      importance: Importance.max,
      //color: Colors.orange,
      enableVibration: true,
      enableLights: true,
      largeIcon: DrawableResourceAndroidBitmap("@mipmap/finallogodgasansfond"),
        styleInformation: MediaStyleInformation(
            htmlFormatContent: true, htmlFormatTitle: true),
      priority: Priority.high,
      playSound: true,
    );
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: const IOSNotificationDetails(presentSound: true),
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }
}