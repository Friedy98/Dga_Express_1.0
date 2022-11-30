
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/My_Announcements.dart';

import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import 'package:smart_shop/screens/Services/delayed_animation.dart';

import '../../main.dart';

class finishAnnReview extends StatefulWidget {
  static const String routeName = 'finishAnnReview';
  const finishAnnReview({Key? key}) : super(key: key);

  @override
  _finishAnnReviewState createState() => _finishAnnReviewState();

}

class _finishAnnReviewState extends State<finishAnnReview> {

  bool showbackArrow = true;
  final storage = const FlutterSecureStorage();
  bool isChecked = false;
  bool isChecked2 = false;

  String? selectedValue;
  String? selectedValue2;
  int activeIndex = 0;
  int totalIndex = 2;

  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  String currentUserId = "";
  String announcementId = "";

  @override
  void initState() {
    super.initState();
    getAnnouncementData();
  }

  void getAnnouncementData()async{
    if(mounted) {
      announcementId = (await storage.read(key: 'announcementId'))!;
    }
}

  final GlobalKey <FormState> _formKey = GlobalKey <FormState> ();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  File? passport;
  File? ticket;
  File? covidtest;
  String displayflightticket = "";
  String displaycovidtest = "";

  final _picker = ImagePicker();

  // Implementing the image picker
  passportPicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        passport = File(pickedImage.path);
      });
    }
  }

  ticketPicker() async {
    FilePickerResult? myflightticket = await FilePicker.platform.pickFiles();
    if (myflightticket != null) {
      setState(() {
        ticket = File(myflightticket.files.single.path.toString());
        displayflightticket = myflightticket.files.single.name;
      });
    }
  }

  covidtestPicker() async {
    FilePickerResult? mycovidTest = await FilePicker.platform.pickFiles();
    if(mycovidTest != null){
      setState(() {
        covidtest = File(mycovidTest.files.single.path.toString());
        displaycovidtest = mycovidTest.files.single.name;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: const Text('Completer l\'Annonce'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? const Icon(Icons.arrow_back_ios)  : const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body:  DelayedAnimation(delay: 300,
          child: _buildSecondForm(context))
    );
  }

  bool isloading = false;

  Widget _buildSecondForm(BuildContext context) {
    return ListView(
      key: _formKey,
      padding: const EdgeInsets.all(15.0),
      children: [
        const SizedBox(height: 13.0),
        ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const[
              Text("Upload NIC/ Passport"),
              Icon(Icons.insert_drive_file, color: Colors.white,)
            ],
          ),
          onPressed: () {
            passportPicker();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 70.w,
          height: 150.h,
          color: Colors.grey[300],
          child: passport != null
              ? Image.file(passport!, fit: BoxFit.fill)
              : const Text('Please select an image'),
        ),

        const SizedBox(height: 13.0),
        ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const[
              Text("Upload Flight Ticket"),
              Icon(Icons.flight_takeoff_outlined, color: Colors.white,)
            ],
          ),
          onPressed: () {
            ticketPicker();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 100.w,
          height: 80.h,
          color: Colors.grey[300],
          child: ticket != null
              ? Text(displayflightticket)
              : const Text('Please select a File'),
        ),

        const SizedBox(height: 13.0),
        ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const[
              Text("Upload Covid-Test"),
              Icon(Icons.medical_services, color: Colors.white,)
            ],
          ),
          onPressed: () {
            covidtestPicker();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 100.w,
          height: 80.h,
          color: Colors.grey[300],
          child: covidtest != null
              ? Text(displaycovidtest)
              : const Text('Please select a File'),
        ),
        const SizedBox(height:30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(110, 40),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),),
                onPressed: () async{
                  setState(() => isloading = true);
                  Fluttertoast.showToast(
                      msg: "This will take a moment...",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 5,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 20.0
                  );
                  await uploadPassport(passport, announcementId);
                  await uploadTicket(ticket, announcementId);
                  await uploadCovid(covidtest, announcementId);

                  setState(() => isloading = false);
                },
                child: (isloading)
                    ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 1.5,
                    ))
                    : const Text('Validate')),
          ],
        ),
      ],
    );
  }

  Future uploadTicket(File? ticket, String announcementId) async{
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Domain.dgaExpressPort}upload/tiket/image/$announcementId'));
    request.files.add(await http.MultipartFile.fromPath('file',
        ticket!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final image = await response.stream.bytesToString();
      debugPrint(image);
      Fluttertoast.showToast(
          msg: "FlightTicket Successfull! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
      Fluttertoast.showToast(
          msg: "Error:  " + errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
  }
  Future uploadCovid(File? covidtest, String announcementId) async{
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
    'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Domain.dgaExpressPort}upload/covid/test/image/$announcementId'));
    request.files.add(await http.MultipartFile.fromPath('file',
        covidtest!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final image = await response.stream.bytesToString();
      debugPrint(image);
      Fluttertoast.showToast(
          msg: "Passport Successfull! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MyTravels(),
        ),
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
      Fluttertoast.showToast(
          msg: "Error:  " + errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
  }
  Future uploadPassport(File? passport, String announcementId) async{
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Domain.dgaExpressPort}upload/passport/image/$announcementId'));
    request.files.add(await http.MultipartFile.fromPath('file',
        passport!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final image = await response.stream.bytesToString();
      debugPrint(image);
      Fluttertoast.showToast(
          msg: "Passport Successfull! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
      Fluttertoast.showToast(
          msg: "Error:  " + errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
  }
}