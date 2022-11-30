import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/Services/AllAnnouncements.dart';
import 'package:smart_shop/screens/Services/My_Reservations.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';
import 'dart:io' as plateform;

import '../../Utils/font_styles.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = 'notifications';
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State <NotificationScreen>{

  final storage = const FlutterSecureStorage();

  List notifications = [];
  bool noNotifications = false;

  @override
  void initState(){
    initialise();
    super.initState();
  }
  bool receivedNotifications = false;

  initialise()async{
    String? stringOfItems = await storage.read(key: 'listOfnotifications');
    if(stringOfItems != null) {
      setState(() {
        notifications = jsonDecode(stringOfItems);
      });

      print(notifications);
    }
    if(notifications.isNotEmpty){
      setState(() {
        receivedNotifications = !receivedNotifications;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? const Icon(Icons.arrow_back_ios)  : const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.pop(context);
            },
        ),
        actions: [
          IconButton(
              onPressed: (){
                storage.delete(key: "listOfnotifications");

                Navigator.push(
                  context,
                  PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                      child: const mainhome()),
                );

              }, icon: const Icon(Icons.clear_all_outlined)
          )
        ],
      ),
      body: buildNotificationList(context),
    );
  }

  Widget buildNotificationList(BuildContext context){
    return Visibility(
      visible: receivedNotifications,
        child: notifications.isNotEmpty ? Column(
          children: [
            Expanded(
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0.r),
                          ),
                          padding: const EdgeInsets.all(15),
                          //margin: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: 5.0.h),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 30,
                                    child: Image.asset('assets/images/Final logo dga sans fond.png'),
                                  ),
                                  SizedBox(width: 20.w),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          style:DefaultTextStyle.of(context).style,
                                          children: <TextSpan>[
                                            TextSpan(text: notifications[index]["title"],
                                                style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                            TextSpan(text: "\n${notifications[index]["content"]}",
                                                style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Container(
                                  transform: Matrix4.translationValues(0.0, 12.0, 0.0),
                                  child: Container(
                                    height: 0.5,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            ],
                          )
                      ),
                      onTap: (){
                        if(notifications[index]["content"] == "votre voyage a été validé"){

                          Navigator.push(
                            context,
                            PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                                child: const My_Posts()),
                          );
                          notifications.remove(notifications[index]);
                        }else if(notifications[index]["content"] == "A reservé des kilos sur votre voyage"){

                          Navigator.push(
                            context,
                            PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                                child: const MyReservations()),
                          );
                          notifications.remove(notifications[index]);

                        }
                      },
                    );
                  },
                )
            )
          ],
        ) : Center(
          child: Text("Pas de notification",
              style: FontStyles.montserratRegular14().copyWith(color: Colors.grey)
          ),
        )
    );
  }
}
