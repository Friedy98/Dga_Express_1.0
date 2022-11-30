
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Common/Widgets/gradient_header.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/SignUp/sign_up.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';

import 'package:http/http.dart' as http;

import '../../main.dart';
import 'forgotten_Password.dart';

// ignore: camel_case_types
class login extends StatefulWidget {
  static const String routeName = 'login';
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {

  final storage = const FlutterSecureStorage();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late Box box;
  bool isChecked1 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    createbox();
  }

  void createbox() async{
    box = await Hive.openBox('User_box');
    getdata();
  }
  void getdata()async{
    if(box.get('useremail')!=null){
      emailController.text = box.get('useremail');
      isChecked1 = true;
      setState(() {
      });
    }
    if(box.get('password')!=null){
      passwordController.text = box.get('password');
      isChecked1 = true;
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(context),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      width: double.infinity,
      height: 50.0.h,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          Text("Developed By: shinTheo",
              style: FontStyles.montserratRegular17().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  RegExp passwordValid = RegExp(r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)");
  double passwordStrength = 0;

  bool validatePassword(String pass) {
    String _password = pass.trim();
    if (_password.isEmpty) {
      setState(() {
        passwordStrength = 0;
      });
    } else if (_password.length < 6) {
      setState(() {
        passwordStrength = 1 / 4;
      });
    } else if (_password.length < 8) {
      setState(() {
        passwordStrength = 2 / 4;
      });
    } else {
      if (passwordValid.hasMatch(_password)) {
        setState(() {
          passwordStrength = 4 / 4;
        });
        return true;
      } else {
        setState(() {
          passwordStrength = 3 / 4;
        });
        return false;
      }
    }
    return false;
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildForm(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return AppHeaderGradient(
      fixedHeight: MediaQuery
          .of(context)
          .size
          .height * .20,
      isProfile: false,
      text: 'Connexion',
    );
  }

  final _formKey = GlobalKey<FormState>();
  bool isValidForm = false;
  bool _isObscure = true;
  bool isloading = false;


  Widget _buildForm(BuildContext context) {
    return Form(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(17.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 15.0),
                DelayedAnimation(delay: 300,
                    child: TextFormField(
                      controller: emailController,
                      autofocus: false,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Address Mail',
                        labelText: 'Email',
                        filled: true,
                        icon: const Icon(Icons.email_outlined),
                      ),
                      validator: (inputValue) {
                        if (inputValue!.isEmpty) {
                          return "field Required!";
                        }
                      },
                    ),
                ),
                const SizedBox(height: 15.0),
                DelayedAnimation(delay: 500,
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: _isObscure,
                      autofocus: false,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                        hintText: 'Mot de Pass',
                        labelText: 'Mot de Pass',
                        filled: true,
                        icon: const Icon(Icons.lock),
                        suffixIcon: IconButton(onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        }, icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off),
                        ),
                      ),
                      validator: (inputValue) {
                        if (inputValue!.isEmpty) {
                          return "field Required!";
                        }
                      },
                    ),
                ),
                const SizedBox(height: 15.0),
                DelayedAnimation(delay: 700,
                    child: Row(
                      children: [
                        Checkbox(
                          value: isChecked1,
                          onChanged: (value){
                            isChecked1 = !isChecked1;
                            setState(() {
                            });
                          },
                        ),
                        Text("Se souvenir de moi",style: FontStyles.montserratRegular14().copyWith(
                            color: Colors.black45)),

                      ],
                    ),
                ),
                const SizedBox(height: 15.0),
                DelayedAnimation(delay: 800,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                              child: ForgottenPassword()),
                        );
                      },
                      child: Text(
                        'Mot de Pass oublié?',
                        style: FontStyles.montserratRegular14().copyWith(
                            color: Colors.blue),
                      ),
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 1000,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          isValidForm = true;

                          setState(() => isloading = true);
                          await login();
                          setState(() => isloading = false);
                        }
                        else {
                          setState(() {
                            isValidForm = false;
                          });
                        }
                      },
                      child: (isloading)
                          ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          )) : Text("Connexion", style:
                      FontStyles.montserratRegular17().copyWith(color: Colors.white)),
                    ),
                ),
                const SizedBox(height: 10.0),
                DelayedAnimation(delay: 1200,
                    child: Row(
                      children: [
                        Text("Pas encore de Compte?",
                            style: FontStyles.montserratRegular17().copyWith(
                                color: Colors.black45)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                                  child: const SignUp()),
                            );
                          },
                          child: Text(
                            "SignUp",
                            style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                ),

                //Authentification through gmail Standby

                /*Padding(
                  child: Text('Login with Google',
                    style: FontStyles.montserratRegular14().copyWith(
                        color: Colors.black45)),
                  padding: const EdgeInsets.fromLTRB(60, 60, 60, 20),
                ),
                GestureDetector(
                  onTap: () {
                    function();
                    Navigator.pushReplacementNamed(context, mainhome.routeName);
                  },
                  child: SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: Image.asset("assets/images/google.png"),
                  ),
                ),*/
              ],
            ),

          ),
        ));
  }

  login() async {

    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Domain.dgaExpressPort}login'));
    request.fields.addAll({
      'useremail': emailController.text,
      'password': passwordController.text
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      final token = await response.stream.bytesToString();

      debugPrint(json.decode(token)['access-token']);
      debugPrint("refreshToken is: " + json.decode(token)['refresh-token']);

      var accessToken = json.decode(token)['access-token'];

      await storage.write(key: 'accesstoken', value: accessToken);
      await storage.write(key: 'refreshToken', value: json.decode(token)['refresh-token']);

      storeLoginDetails();

      await storage.write(key: "email", value: emailController.text);
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 500),
            child: const mainhome()),
      );

      MotionToast.success(
        description:  Text("Login Sucessful", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

      if(isChecked1){
        storeLoginDetails();
      }else{
        if(box.isEmpty) {
          await box.clear();
        }
      }
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];

      MotionToast.error(
        description:  Text(errorMessage, style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

    }
  }
//final data = await request.fields;

  void storeLoginDetails() {
    box.put('useremail', emailController.text);
    box.put('password', passwordController.text);
  }
}

function(){
  Fluttertoast.showToast(
      msg: "google signIn called",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
