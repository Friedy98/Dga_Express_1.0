
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Home/HomePage.dart';
import 'package:smart_shop/screens/Services/My_Reservations.dart';
import 'package:smart_shop/screens/Services/My_Sales.dart';

import '../../Screens/notificationservice.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../Services/My_Announcements.dart';
import '../Services/My_Purchase.dart';
//import 'package:http/http.dart' as http;

class mainhome extends StatefulWidget {
  const mainhome({Key? key}) : super(key: key);
  static const String routeName = 'main';

  @override
  _mainhomeState createState() => _mainhomeState();
}

class _mainhomeState extends State<mainhome> {
  int currentIndex = 0;
  Timer? timer;
  List notifications = [];
  List notificationData = [];

  String userid = "";
  NotificationService notificationService = NotificationService();

  List<Widget> myScreens = [
    const HomePage(),
    const MySales(),
    const MyPurchase(),
    const MyTravels(),
    const MyReservations(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myScreens.elementAt(currentIndex),
      // bottomNavigationBar: buildBottomNavigation(),
      bottomSheet: buildBottomSheet(),
      resizeToAvoidBottomInset: false,
    );
  }

  final storage = const FlutterSecureStorage();

  bool islogin = false;
  
  @override
  void initState() {
    super.initState();
    notificationService.initialiseNotification();
    checkUser();
  }

  void checkUser()async{
    String? token = await storage.read(key: "accesstoken");
    final profileData = await storage.read(key: 'Profile');
    if(mounted) {
      if (token != null) {
        if(profileData != null) {
          userid = json.decode(profileData)['id'];
        }
        setState(() {
          testSse(userid);
          islogin = !islogin;
        });

      }
    }
  }

  void testSse(String userid) async{
    Stream myStream;
    print("Server is on...");
    myStream = Sse.connect(
      uri: Uri.parse('${Domain.dgaExpressPort}subcribe?userId=$userid'),
      closeOnError: true,
      withCredentials: false,
    ).stream;

    myStream.listen((event) async{
      //print(event.toString());

      notificationService.sendNotification("New Notification", "Vous avez Une Nouvelle notification");

      MotionToast.info(
        animationCurve: Curves.ease,
        title: Text("Nouvelle Notification", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        description: Text("Vous avez recu une nouvelle Notification!", style: FontStyles.montserratRegular14().copyWith(
            color: Colors.white)),
        enableAnimation: true,
        animationType: AnimationType.fromTop,
        position: MotionToastPosition.top,
      ).show(context);

      await storage.write(key: 'NotificationsSize', value: json.decode(event)["notificationSize"].toString());

    });
  }

  Widget buildBottomSheet() {
    //var screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0.r),
            topRight: Radius.circular(20.0.r),
          ),
        ),
      child: Visibility(
        visible: islogin,
        child: Container(
          height: 40.0.h,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 1,
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 0;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.home,
                                  color: currentIndex == 0
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                                Text(
                                  'Accueil',
                                  style: TextStyle(
                                    color: currentIndex == 0
                                        ? Colors.black
                                        : AppColors.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 1;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.sell_rounded ,
                                  color: currentIndex == 1
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                                Text(
                                  'Articles',
                                  style: TextStyle(
                                    color: currentIndex == 1
                                        ? Colors.black
                                        : AppColors.textLightColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 2;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_shopping_cart,
                                  color: currentIndex == 2
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                                Text(
                                  'Achats',
                                  style: TextStyle(
                                    color: currentIndex == 2
                                        ? Colors.black
                                        : AppColors.textLightColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 3;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.airplanemode_on_sharp ,
                                  color: currentIndex == 3
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                                Text(
                                  'Voyages',
                                  style: TextStyle(
                                    color: currentIndex == 3
                                        ? Colors.black
                                        : AppColors.textLightColor,
                                  ),
                                )
                              ],
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              setState(() {
                                currentIndex = 4;
                              });
                            },
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_month_sharp,
                                  color: currentIndex == 4
                                      ? AppColors.primaryLight
                                      : Colors.grey,
                                ),
                                Text(
                                  'Reservations',
                                  style: TextStyle(
                                    color: currentIndex == 4
                                        ? Colors.black
                                        : AppColors.textLightColor,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}

