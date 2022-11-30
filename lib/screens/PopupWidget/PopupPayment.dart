
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Utils/font_styles.dart';
import '../mainhome/mainhome.dart';

class PopupWidgetPayment extends StatefulWidget {
  const PopupWidgetPayment({Key? key}) : super(key: key);

  @override
  _PopupWidgetPaymentState createState() => _PopupWidgetPaymentState();
}

class _PopupWidgetPaymentState extends State<PopupWidgetPayment>{
  final storage = const FlutterSecureStorage();
  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Colors.orange,
            width: double.infinity,
            height: 40.h,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Payment Method",style:
                FontStyles.montserratRegular19().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Image.asset('assets/images/visa.png',width: 80,height: 80),
                  onTap: (){
                    //
                  },
                ),
                GestureDetector(
                  child: Image.asset('assets/images/paypal.png',width: 100,height: 100),
                  onTap: (){
                    //
                  },
                )
              ],
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  child: Image.asset('assets/images/kindpng_1514348.png',width: 80,height: 80),
                  onTap: (){
                    //
                  },
                ),
                GestureDetector(
                  child: Image.asset('assets/images/Orange_Money_logo_PNG4.png',width: 80,height: 80),
                  onTap: (){
                    //
                  },
                )
              ],
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}