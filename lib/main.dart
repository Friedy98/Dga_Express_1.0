
import 'dart:async';
import 'dart:convert';

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:smart_shop/Utils/Constants/app_constants.dart';
import 'package:smart_shop/Utils/app_theme.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';
import 'package:smart_shop/screens/notificationservice.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'local_notice_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConstants.setSystemStyling();
  await Hive.initFlutter();
  box = await Hive.openBox('User_box');
  runApp(
    ScreenUtilInit(
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routes: AppConstants.appRoutes,
        initialRoute: '/',
      ),
      designSize: const Size(375, 812),
    ),
  );
}

late Box box;

class Domain{
  static var dgaExpressPort = "https://dga-express.com:8443/";
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  NotificationService notificationService = NotificationService();
  Timer? timer;
  final storage = const FlutterSecureStorage();


  @override
  void initState() {
    // TODO: implement initState
    //notificationService.initialiseNotification();
    Stripe.publishableKey = "pk_live_51LjiQQCZjIzC8Xowo7DL6dtbHOCFIqLZGZaLRAGGQJby2NYhYazpdEnh6VLbleWanVEyzI6bs06pJFmITvMHOoJj00aYOvJIXQ";

    LocalNoticeService().setup();
    super.initState();
    checkLogin();
  }

  checkLogin()async{
    await Stripe.instance.applySettings();
    String? token = await storage.read(key: "accesstoken");
    if(token != null) {
      print("Timer on...");
      timer = Timer.periodic(
          const Duration(seconds: 1200), (Timer t) => callRefreshtoken());
    }else{
      print("Timer Off!!!");
    }
  }

  void callRefreshtoken() async{

    String? refreshToken = await storage.read(key: "refreshToken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $refreshToken'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}refreshToken'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final newtoken = await response.stream.bytesToString();

      var accessToken = json.decode(newtoken)['access-token'];

      await storage.write(key: 'accesstoken', value: accessToken);
      print("New accesstoken is \n$accessToken");
    }
    else {
      await response.stream.bytesToString();
    }
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedSplashScreen.withScreenFunction(
      splash: Image.asset('assets/images/Final logo dga sans fond.png'),
      duration: 5000,
      splashIconSize: double.infinity,
      screenFunction: () async{
        return const mainhome();
      },
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white,
      //pageTransitionType: PageTransitionType.scale,
    );
  }
}

class Sse {
  final html.EventSource eventSource;
  final StreamController<String> streamController;

  Sse._internal(this.eventSource, this.streamController);

  factory Sse.connect({
    @required Uri? uri,
    bool withCredentials = false,
    bool closeOnError = true,
  }) {
    final streamController = StreamController<String>();
    final eventSource = html.EventSource(uri.toString(), withCredentials: withCredentials);

    eventSource.addEventListener('addReservation', (html.Event addReservation) {
      streamController.add((addReservation as html.MessageEvent).data as String);
    });
    eventSource.addEventListener('confirmReservation', (html.Event confirmReservation) {
      streamController.add((confirmReservation as html.MessageEvent).data as String);
    });
    eventSource.addEventListener('validationSuggest', (html.Event validationSuggest) {
      streamController.add((validationSuggest as html.MessageEvent).data as String);
    });

    ///close if the endpoint is not working
    if (closeOnError) {
      eventSource.onError.listen((event) {
        eventSource.close();
        streamController.close();
      });
    }
    return Sse._internal(eventSource, streamController);
  }

  Stream get stream => streamController.stream;

  bool isClosed() => streamController == null || streamController.isClosed;

  void close() {
    eventSource.close();
    streamController.close();
  }
}