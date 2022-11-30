
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Utils/font_styles.dart';
import '../mainhome/mainhome.dart';

class PopupWidgetLogout extends StatefulWidget {
  const PopupWidgetLogout({Key? key}) : super(key: key);

  @override
  _PopupWidgetLogoutState createState() => _PopupWidgetLogoutState();
}

class _PopupWidgetLogoutState extends State<PopupWidgetLogout>{
  final storage = const FlutterSecureStorage();
  SharedPreferences? prefs;

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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.red,size: 80),
                Text("Voulez-vous vraiment quitter?",style:
                FontStyles.montserratRegular17().copyWith(color: Colors.black)),
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
                child: Text('Annuler',
                          style: FontStyles.montserratRegular17().copyWith(color: const Color(0xFF59595C))),

              ),
              TextButton(
                onPressed: () {
                  logout();
                },
                child: Text('Se Déconecter',
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),

              ),
            ],
          ),
        ],
      ),
    );
  }

  Future logout() async {
    await storage.delete(key: 'accesstoken');
    await storage.delete(key: 'Profile');
    prefs != null ? await prefs!.clear() : null;

    Fluttertoast.showToast(
        msg: "Logout Successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.amber,
        textColor: Colors.white,
        fontSize: 16.0
    );
    Navigator.push(
      context,
      PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
          child: const mainhome()),
    );
  }
}