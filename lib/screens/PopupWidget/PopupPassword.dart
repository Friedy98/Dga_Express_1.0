
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/Profile/profile.dart';

import '../../Utils/font_styles.dart';
import 'package:http/http.dart' as http;

import '../../main.dart';

class PopupWidgetPassword extends StatefulWidget {
  const PopupWidgetPassword({Key? key}) : super(key: key);

  @override
  _PopupWidgetPasswordState createState() => _PopupWidgetPasswordState();
}

class _PopupWidgetPasswordState extends State<PopupWidgetPassword>{
  final storage = const FlutterSecureStorage();

  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmpasswordController = TextEditingController();

  final _PasswordKey = GlobalKey<FormState>();
  bool isValidForm = false;
  RegExp pass_valid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");

  bool _isObscure = true;
  bool _isObscure2 = true;
  bool _isObscure3 = true;

  double password_strength = 0;

  String passwordOld = "";
  String passwordNew = "";

  bool validatePassword(String pass){
    String _password = pass.trim();
    if(_password.isEmpty){
      setState(() {
        password_strength = 0;
      });
    }else if(_password.length < 6 ){
      setState(() {
        password_strength = 1 / 4;
      });
    }else if(_password.length < 8){
      setState(() {
        password_strength = 2 / 4;
      });
    }else{
      if(pass_valid.hasMatch(_password)){
        setState(() {
          password_strength = 4 / 4;
        });
        return true;
      }else{
        setState(() {
          password_strength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      child: Form(
        key: _PasswordKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            const Icon(Icons.lock_rounded, size: 80),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text("Modifier le Mot de Pass",style:
                  FontStyles.montserratRegular19().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280.w,
                  child: TextFormField(
                    controller: oldPassword,
                    obscureText: _isObscure,
                    autofocus: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Entrer l\'ancien Mot de Pass',
                      labelText: 'Ancien Mot de Pass',
                      filled: true,
                      icon: const Icon(Icons.lock),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      }, icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field required";
                      }else{
                        bool result = validatePassword(inputValue);
                        if(result){
                          // create account event
                          return null;
                        }else{
                          return " Mot de Pass dois contenir une lettre Maj,mini, numero & charactaire special";
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: 280.w,
                  child: TextFormField(
                    controller: newPassword,
                    obscureText: _isObscure2,
                    autofocus: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Entez le nouveau Mot de Pass',
                      labelText: 'Nouveau Mot de Pass',
                      filled: true,
                      icon: const Icon(Icons.lock),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          _isObscure2 = !_isObscure2;
                        });
                      }, icon: Icon(
                          _isObscure2 ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field Required";
                      }else{
                        bool result = validatePassword(inputValue);
                        if(result){
                          // create account event
                          return null;
                        }else{
                          return " Mot de Pass dois contenir une lettre Maj,mini, numero & charactaire special";
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),
                SizedBox(
                  width: 280.w,
                  child: TextFormField(
                    controller: confirmpasswordController,
                    obscureText: _isObscure3,
                    autofocus: false,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                      hintText: 'Confirmer le nouveau Mot de Pass',
                      labelText: 'Confirmer le Mot de Pass',
                      filled: true,
                      icon: const Icon(Icons.lock),
                      suffixIcon: IconButton(onPressed: (){
                        setState(() {
                          _isObscure3 = !_isObscure3;
                        });
                      }, icon: Icon(
                          _isObscure3 ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field Required";
                      }if(inputValue != newPassword.text){
                        return "Mots de Pass ne concoordent pas";
                      }
                      else{
                        bool result = validatePassword(inputValue);
                        if(result){
                          // create account event
                          return null;
                        }else{
                          return " Mot de Pass dois contenir une lettre Maj,mini, numero & charactaire special";
                        }
                      }
                    },
                  ),
                ),

              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: ()async{
                await storage.write(key: "oldPassword", value: oldPassword.text);
                await storage.write(key: "newPassword", value: newPassword.text);
                if(_PasswordKey.currentState!.validate()){
                  isValidForm = true;
                  getPassword();
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      width: 130,
                      height: 40,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.orangeAccent, Colors.orange],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child:  Center(
                        child: Text('Modifier',
                            style: FontStyles.montserratRegular14().copyWith(color: Colors.white,fontWeight: FontWeight.bold)),

                      )),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  void getPassword() async{
    passwordOld = (await storage.read(key: "oldPassword"))!;
    passwordNew = (await storage.read(key: "newPassword"))!;
    updatePassword(passwordOld, passwordNew);
  }

  void updatePassword(String passwordOld, String passwordNew) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/update/$passwordOld/$passwordNew/password'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());

      MotionToast.success(
          description:  Text("Mot de passe modifié avec succès", style: FontStyles.montserratRegular19().copyWith(
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

      MotionToast.error(
          title: Text("Erreur!", style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black)),
          description:  Text(errorMessage, style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);
    }
  }
}