
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/Login/login.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';

import '../../Utils/font_styles.dart';

class PopupWidgetLogin extends StatefulWidget {
  const PopupWidgetLogin({Key? key}) : super(key: key);

  @override
  _PopupWidgetLoginState createState() => _PopupWidgetLoginState();
}

class _PopupWidgetLoginState extends State<PopupWidgetLogin>{

  final storage = const FlutterSecureStorage();

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
                Text("Connectez vous pour continuer!",style:
                FontStyles.montserratRegular17().copyWith(color: Colors.black)),
              ],
            ),
          ),
          const Divider(color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () async{
                  await storage.delete(key: 'accesstoken');
                  Navigator.push(
                    context,
                    PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                        child: const mainhome()),
                  );
                },
                child: Text('Annuler',
                          style: FontStyles.montserratRegular17().copyWith(color: const Color(0xFF59595C))),

              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                        child: const login()),
                  );
                },
                child: Text('Se Connecter',
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.green)),

              ),
            ],
          ),

        ],
      ),
    );
  }
}