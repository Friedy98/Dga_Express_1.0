
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../Services/delayed_animation.dart';

class ForgottenPassword extends StatefulWidget {
  @override
  _ForgottenPasswordState createState() => _ForgottenPasswordState();
}

class _ForgottenPasswordState extends State<ForgottenPassword> {

  @override
  void initState() {
    super.initState();
  }

  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 40),
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: Icon(plateform.Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back_sharp),
              onPressed: (){
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: 20),
          DelayedAnimation(delay: 200,
            child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    left: 16,
                    right: 16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1, color: Colors.blueGrey),
                  color: Colors.white,
                ),
                child:const Center(
                    child: Icon(Icons.lock, size: 100,color: Colors.blueGrey,)
                )
            ),
          ),
          DelayedAnimation(delay: 400,
            child: Container(
              padding: const EdgeInsets.only(top: 25),
              child: Text(
                'RESET PASSWORD',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: isLightMode ? Colors.black : Colors.white),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'Entrez votre address mail',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 3,
                  color: isLightMode ? Colors.black : Colors.white),
            ),
          ),
          SizedBox(height: 30),
          Container(
            padding: EdgeInsets.all(20),
            child: DelayedAnimation(
                delay: 600,
                child: TextFormField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                      labelText: 'Your Email',
                      hintText: "your_email@example.com",
                      prefixIcon: Icon(Icons.mail_rounded),
                      labelStyle: TextStyle(
                        color: Colors.grey[400],
                      )
                  ),
                  controller: emailController,
                )
            ),
          ),
          SizedBox(height: 30),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 150,
              height: 40,
              decoration: BoxDecoration(
                color: isLightMode ? Colors.blue : Colors.white,
                borderRadius:
                const BorderRadius.all(Radius.circular(10.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.6),
                      offset: const Offset(4, 4),
                      blurRadius: 8.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if(emailController.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });
                      recoverPassword();
                    }else{
                      Fluttertoast.showToast(
                          msg: "Entrer votre mail!!!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          textColor: Colors.white,
                          backgroundColor: Colors.grey,
                          fontSize: 20.0
                      );
                    }
                  },
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: (isLoading)
                          ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          )) : Text("Valider", style:
                      FontStyles.montserratRegular17().copyWith(color: Colors.white)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void recoverPassword() async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}reset/password?emailAddress=${emailController.text}'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final answer = await response.stream.bytesToString();
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Nous avons envoyé un mail à ${emailController.text}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          textColor: Colors.white,
          backgroundColor: Colors.blue,
          fontSize: 20.0
      );
      print(answer);
    }
    else {
      final error = await response.stream.bytesToString();
      print(error);
    }
  }
}
