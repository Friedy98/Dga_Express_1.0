
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';

import '../../Utils/font_styles.dart';
import '../Services/My_Announcements.dart';
import 'package:http/http.dart' as http;

class PopupWidgetDelete extends StatefulWidget {
  const PopupWidgetDelete({Key? key}) : super(key: key);

  @override
  _PopupWidgetDeleteState createState() => _PopupWidgetDeleteState();
}

class _PopupWidgetDeleteState extends State<PopupWidgetDelete>{
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAnnDataPopup();
  }

  String announcementId = "";

  void getAnnDataPopup() async {
    announcementId = (await storage.read(key: 'announcementId'))!;
  }

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Icon(Icons.warning_rounded, color: Colors.red,size: 70),
                const SizedBox(width: 15),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text( " Warning! ",
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold),),
                      SizedBox(
                        width: 280.w,
                        child: Text( "Do you really want to delete this post?",
                            style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Center(
                      child: Text('Cancel',
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),

                    ),
              ),
              TextButton(
                onPressed: () {
                  deleteAnnouncement(announcementId);
                },
                child: Text('Delete',
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),

              ),
            ],
          ),
        ],
      ),
    );
  }

  void deleteAnnouncement(String announcementId) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var request = http.Request('DELETE', Uri.parse('http://46.105.36.240:3000/delete/$announcementId/announcements'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Navigator.pop(context);
      /*Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: const MyTravels()),
      );*/

      MotionToast.delete(
          description:  Text("Article Supprimé!", style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);

      MotionToast.error(
        title: Text("Erreur!", style: FontStyles.montserratRegular19().copyWith(
            color: Colors.black)),
          description:  Text(errorMessage, style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);

    }

  }
}