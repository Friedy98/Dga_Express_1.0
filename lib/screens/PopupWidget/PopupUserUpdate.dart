
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/Profile/currentuserProfile.dart';
import 'package:smart_shop/screens/Profile/profile.dart';
import '../../Utils/font_styles.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class PopupWidgetUpdate extends StatefulWidget {
  const PopupWidgetUpdate({Key? key}) : super(key: key);

  @override
  _PopupWidgetUpdateState createState() => _PopupWidgetUpdateState();
}

class _PopupWidgetUpdateState extends State<PopupWidgetUpdate>{

  @override
  void initState(){
    super.initState();
    getUserdata();
  }
  String userId = "";

  void getUserdata() async{
    final Userdata = await storage.read(key: 'Profile');
    if(mounted) {
      setState(() {
        userId = json.decode(Userdata!)['id'];
        firstNameController.text = json.decode(Userdata)['firstName'];
        lastNameController.text = json.decode(Userdata)['lastName'];
        pseudoController.text = json.decode(Userdata)['pseudo'];
        emailController.text = json.decode(Userdata)['email'];
        telController.text = json.decode(Userdata)['phone'];
      });
    }
  }

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController pseudoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController telController = TextEditingController();

  bool isChecked = false;
  final storage = const FlutterSecureStorage();

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.manage_accounts_outlined, size: 80, color: Colors.blue),
                ),
                const SizedBox(height: 10),
                Text("Update Profile",style:
                FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 280.0.w,
            child: TextFormField(
              controller: firstNameController,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                labelText: 'First Name',
                icon: const Icon(Icons.person),
              ),
              validator: (inputValue){
                if(inputValue!.isEmpty ) {
                  return "field Required!";
                }
              },
            ),
          ),

          const SizedBox(height: 15.0),
          SizedBox(
            width: 280.w,
            child: TextFormField(
              controller: lastNameController,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                labelText: 'Last Name',
                icon: const Icon(Icons.person_pin_outlined),
              ),
              validator: (inputValue){
                if(inputValue!.isEmpty ) {
                  return "field Required!";
                }
              },
            ),
          ),

          const SizedBox(height: 15.0),
          SizedBox(
            width: 280.w,
            child: TextFormField(
              controller: pseudoController,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                labelText: "Pseudo",
                icon: const Icon(Icons.person_pin_rounded),
              ),
              validator: (inputValue){
                if(inputValue!.isEmpty ) {
                  return "field Required!";
                }
              },
            ),
          ),
          const SizedBox(height: 15.0),
          SizedBox(
            width: 280.w,
            child: TextFormField(
              controller: telController,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                labelText: "Phone Number",
                icon: const Icon(Icons.person_pin_rounded),
              ),
              validator: (inputValue){
                if(inputValue!.isEmpty ) {
                  return "field Required!";
                }
              },
            ),
          ),

          const SizedBox(height: 15.0),
            SizedBox(
              width: 280.w,
              child: TextFormField(
                controller: emailController,
                autofocus: false,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  labelText: "Email Address",
                  icon: const Icon(Icons.mail_rounded),
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty ) {
                    return "field Required!";
                  }else if(!inputValue.contains("@") && !inputValue.contains(".")){
                    return "Invalid E-mail!";
                  }
                },
              ),
            ),

          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: ()async{
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child:
                Container(
                    width: 110,
                    height: 30,
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.grey, Colors.black12],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child:  Center(
                      child: Text('Cancel',
                          style: FontStyles.montserratRegular14().copyWith(color: Colors.white,fontWeight: FontWeight.bold)),

                    )),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: ()async{
                  _UpdateUser();
                },
                child:
                    Container(
                        width: 110,
                        height: 30,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.orangeAccent, Colors.orange],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        child:  Center(
                          child: Text('Update',
                              style: FontStyles.montserratRegular14().copyWith(color: Colors.white,fontWeight: FontWeight.bold)),

                        )),
              ),
            ],
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  void _UpdateUser() async{
    String? token = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}update/user'));
    request.body = json.encode({
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "profileimgage": "",
      "pseudo": pseudoController.text,
      "phone": telController.text,
      "email": emailController.text,
      "roleDtos": [
        {
          "id": 2,
          "name": "ROLE_CLIENT"
        }
      ],
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final profile = await response.stream.bytesToString();
      print(profile);

      Fluttertoast.showToast(
          msg: "User Updated Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
      Navigator.pushReplacementNamed(context, MyProfile.routeName);
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
  }

  void setProfileImage(File? imageFile) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Domain.dgaExpressPort}upload/profile/image'));
    request.files.add(await http.MultipartFile.fromPath('file',
        imageFile!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
    await response.stream.bytesToString();

    MotionToast.success(
        description:  Text("Photo de profile ajouté avec Succès", style: FontStyles.montserratRegular19().copyWith(
            color: Colors.black))
    ).show(context);

    Navigator.push(
      context,
      PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
          child: const Profile()),
    );

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);

      MotionToast.error(
          title: Text("Erreur!", style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black)),
          description:  Text(errorMessage, style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);

    }
  }
}