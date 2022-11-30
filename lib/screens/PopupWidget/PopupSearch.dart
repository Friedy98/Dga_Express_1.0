
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/SearchPage.dart';

import '../../Utils/font_styles.dart';
//import 'package:http/http.dart' as http;

class PopupWidgetSearch extends StatefulWidget {
  const PopupWidgetSearch({Key? key}) : super(key: key);

  @override
  _PopupWidgetSearchState createState() => _PopupWidgetSearchState();
}

class _PopupWidgetSearchState extends State<PopupWidgetSearch>{
  final storage = const FlutterSecureStorage();

  TextEditingController departure = TextEditingController();
  TextEditingController destination = TextEditingController();
  final _SearchKey = GlobalKey<FormState>();
  bool isValidForm = false;

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Form(
        key: _SearchKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 60,
                      child: Icon(Icons.search, size: 60),
                    ),
                    const SizedBox(height: 10),
                    Text("Search Announcement",style:
                    FontStyles.montserratRegular19().copyWith(color: Colors.blue)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 250.0.w,
                    child: TextFormField(
                      controller: departure,
                      autofocus: false,
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Enter Departure Town',
                        labelText: 'Departure',
                        suffixIcon: const Icon(Icons.location_pin),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: 250.0.w,
                    child: TextFormField(
                      controller: destination,
                      autofocus: false,
                      autocorrect: true,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Enter Destination Town',
                        labelText: 'Destination',
                        suffixIcon: Icon(Icons.location_pin),
                      ),
                      validator: (inputValue){
                        if(inputValue!.isEmpty ) {
                          return "field Required!";
                        }
                      },
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: ()async{
                  if(_SearchKey.currentState!.validate()){
                    isValidForm = true;
                    await storage.write(key: "departure", value: departure.text);
                    await storage.write(key: "ddestination", value: destination.text);
                    Navigator.push(
                      context,
                      PageTransition(type: PageTransitionType.fade, child: const SearchPage()),
                    );
                  }else{
                    isValidForm = false;
                  }
                },
                child: Container(
                    width: 160.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      border: Border.all(width: 2, color: Colors.orange),
                    ),
                    child:  Center(
                      child: Text('Search',
                          style: FontStyles.montserratRegular19().copyWith(color: Colors.orange)),

                    )),
              ),
              const SizedBox(height: 15),
            ],
          ),
      ),
    );
  }
}