
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:im_stepper/stepper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/AllAnnouncements.dart';
import 'package:smart_shop/screens/Services/My_Announcements.dart';

import '../../Common/Widgets/custom_app_bar.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../main.dart';


class updateAnnouncement extends StatefulWidget {
  static const String routeName = 'updateAnnouncement';
  const updateAnnouncement({Key? key}) : super(key: key);

  @override
  _updateAnnouncementState createState() => _updateAnnouncementState();

}

class _updateAnnouncementState extends State<updateAnnouncement> {

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

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String announcementId = "";
  int? price = 0;
  int? quantity = 0;

  void getUserData() async {
    final profileData = await storage.read(key: 'Profile');
    announcementId = (await storage.read(key: 'announcementId'))!;

    getAnnouncementById(announcementId);

    if(mounted) {
        setState(() {
          currentUserId = json.decode(profileData!)['id'];
          firstName = json.decode(profileData)['firstName'];
          lastName = json.decode(profileData)['lastName'];
          pseudo = json.decode(profileData)['pseudo'];
          email = json.decode(profileData)['email'];

        });
    }
  }

  void getAnnouncementById(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}announcement/$id/users'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      Map<String, dynamic> announcementDto = json.decode(data);

          initialdateval.text = announcementDto['departuredate'];
          finaldateval.text = announcementDto['arrivaldate'];
          departureController.text = announcementDto['departuretown'];
          arrivalController.text = announcementDto['destinationtown'];
          quantityController.text = (await storage.read(key: 'quantity'))!;
          computerController.text = (await storage.read(key: 'computer'))!;
          documentController.text = (await storage.read(key: 'document'))!;
          restrictionController.text = announcementDto['restriction'];
          priceController.text = (await storage.read(key: 'price'))!;
    }
    else {
      print(response.reasonPhrase);
    }
  }

  final GlobalKey <FormState> _formKey = GlobalKey <FormState> ();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  File? passport;
  File? ticket;
  File? covidtest;

  final _picker = ImagePicker();
  final _picker2 = ImagePicker();
  final _picker3 = ImagePicker();

  // Implementing the image picker
  _openImagePicker() async {
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        passport = File(pickedImage.path);
      });
    }
  }

  _openImagePicker2() async {
    final XFile? pickedImage =
    await _picker2.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        ticket = File(pickedImage.path);
      });
    }
  }

  _openImagePicker3() async {
    final XFile? pickedImage =
    await _picker3.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        covidtest = File(pickedImage.path);
      });
    }
  }

  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  TextEditingController initialdateval = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController finaldateval = TextEditingController();
  TextEditingController restrictionController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController computerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: const Text('Mettre à jour une Annonce'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                  child: const MyTravels()),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body:  _bodybuilder(context),
    );
  }

  bool isValidForm = false;
  bool isloading = false;
  String countryValue = "";
  String countryValue2 = "";
  String stateValue = "";
  String stateValue2 = "";
  String cityValue = "";

  Future _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(pickedDate!);
    print(formattedDate);
    if(pickedDate != null ){
      setState(() {
        initialdateval.text = formattedDate; //set output date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }
  Future _selectDate2() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2030));
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(pickedDate!);
    print(formattedDate);
    if(pickedDate != null ){
      setState(() {
        finaldateval.text = formattedDate; //set output date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }

  Widget _bodybuilder(BuildContext context){
    switch (activeIndex){
      case 0:
        return _buildForm(context);
      case 1:
        return _buildSecondForm(context);

      default:
        return _buildForm(context);
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(15.0),
        children: [
          Center(
            child: DotStepper(
              activeStep: activeIndex,
              dotRadius: 20.0,
              shape: Shape.pipe,
              spacing: 10.0,
            ),
          ),
          Text("Step ${activeIndex + 1} of $totalIndex",
            style: const TextStyle(
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 13.0),
          TextFormField(
            // focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            autocorrect: false,
            controller: initialdateval,
            onTap: () {
              _selectDate();
              FocusScope.of(context).requestFocus(FocusNode());
            },
            maxLines: 1,
            //initialValue: 'Aseem Wangoo',
            validator: (value) {
              if (value!.isEmpty || value.isEmpty) {
                return '';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'departureDate',
              hintText: 'departure_date',
              //filled: true,
              icon: Icon(Icons.calendar_today),
              labelStyle:
              TextStyle(decorationStyle: TextDecorationStyle.solid),
            ),
          ),

          const SizedBox(height: 13.0),
          TextFormField(
            // focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            autocorrect: false,
            controller: finaldateval,
            onTap: () {
              _selectDate2();
              FocusScope.of(context).requestFocus(FocusNode());
            },
            maxLines: 1,
            //initialValue: 'Aseem Wangoo',
            validator: (value) {
              if (value!.isEmpty || value.isEmpty) {
                return '';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'arrival_date',
              hintText: 'arrival_date',
              //filled: true,
              icon: Icon(Icons.calendar_today),
              labelStyle:
              TextStyle(decorationStyle: TextDecorationStyle.solid),
            ),
          ),
          const SizedBox(height: 13.0),
          TextFormField(
            controller: departureController,
            autocorrect: true,
            onTap: ()async{
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return Dialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        child: SizedBox(
                          height: 120.h,
                          child: CSCPicker(
                            onCountryChanged: (value) {
                              setState(() {
                                countryValue = value;
                              });
                            },
                            onStateChanged:(value) {
                              if(value != null) {
                                setState(() {
                                  stateValue = value;
                                });
                              }
                            },
                            onCityChanged:(value) {
                              if(value != null) {
                                setState(() {
                                  departureController.text = value + ", " + countryValue;
                                });
                                Navigator.pop(context);
                              }
                            },
                          ),
                        )
                    );
                  });
            },
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Town, Country',
              labelText: 'departure_town',
              icon: Icon(Icons.pin_drop),
            ),
            validator: (inputValue){
              if(inputValue == ''){
                return null;
              }
              return null;
            },
          ),
          const SizedBox(height: 13.0),
          TextFormField(
            controller: arrivalController,
            autocorrect: true,
            textCapitalization: TextCapitalization.sentences,
            onTap: ()async{
              showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return Dialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15.0))),
                        child: SizedBox(
                          height: 120.h,
                          child: CSCPicker(
                            onCountryChanged: (value) {
                              setState(() {
                                countryValue2 = value;
                              });
                            },
                            onStateChanged:(value) {
                              if(value != null) {
                                setState(() {
                                  stateValue2 = value;
                                });
                              }
                            },
                            onCityChanged:(value) {
                              if(value != null) {
                                setState(() {
                                  arrivalController.text = value + ", " + countryValue2;
                                  Navigator.pop(context);
                                });
                              }
                            },
                          ),
                        )
                    );
                  });
            },
            decoration: const InputDecoration(
              hintText: 'Town, country',
              labelText: 'destination_town',
              icon: Icon(Icons.pin_drop),
            ),
            validator: (inputValue){
              if(inputValue == ''){
                return "";
              }
              return null;
            },
          ),
          const SizedBox(height: 13.0),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: quantityController,
            decoration: const InputDecoration(
                hintText: 'Quantity in Kg',
                labelText: 'quantity',
                icon: Icon(Icons.production_quantity_limits)
            ),
          ),

          const SizedBox(height: 13.0),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: priceController,
            decoration: const InputDecoration(
                hintText: 'Price per Kilo',
                labelText: 'Price',
                icon: Icon(Icons.price_check_sharp)
            ),
          ),
          //_dropdown(context),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  const Icon(Icons.mail_outline),
                  const SizedBox(width: 5.0),
                  const Text("Documents?"),
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.laptop_mac),
                  const SizedBox(width: 5.0),
                  const Text("Computers?"),
                  Checkbox(
                    value: isChecked2,
                    onChanged: (value) {
                      setState(() {
                        isChecked2 = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 13.0),
          TextFormField(
            controller: restrictionController,
            decoration: const InputDecoration(
                hintText: 'Restriction?',
                labelText: 'Restriction?',
                icon: Icon(Icons.description_outlined)
            ),
          ),

          const SizedBox(height: 30.0),
          Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(110, 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),),
                    onPressed: () async{
                      if(_formKey.currentState?.validate() ?? false){
                        setState(() {isloading = true;
                        });
                        updateAnnouncement();
                        setState(() => isloading = false);
                      } else{
                        setState(() {
                          isValidForm = false;
                        });
                      }
                    },
                    child: (isloading)
                        ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 1.5,
                        ))
                        : const Text('Update')),
              ]
          ),
        ],
      ),
    );
  }

  Widget _buildSecondForm(BuildContext context) {
    return ListView(
      key: _formKey,
      padding: const EdgeInsets.all(15.0),
      children: [
        Center(
          child: DotStepper(
            activeStep: activeIndex,
            dotRadius: 20.0,
            shape: Shape.pipe,
            spacing: 10.0,
          ),
        ),
        Text("Step ${activeIndex + 1} of $totalIndex",
          style: const TextStyle(
            fontSize: 20.0,
          ),
          textAlign: TextAlign.center,),
        ElevatedButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const[
              Text("Upload NIC/ Passport"),
              Icon(Icons.insert_drive_file, color: Colors.white,)
            ],
          ),
          onPressed: () {
            _openImagePicker();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 100.w,
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
            _openImagePicker2();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 70.w,
          height: 100.h,
          color: Colors.grey[300],
          child: ticket != null
              ? Image.file(ticket!, fit: BoxFit.fill)
              : const Text('Please select an image'),
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
            _openImagePicker3();
          },
        ),
        Container(
          alignment: Alignment.center,
          width: 70.w,
          height: 100.h,
          color: Colors.grey[300],
          child: covidtest != null
              ? Image.file(covidtest!, fit: BoxFit.fill)
              : const Text('Please select an image'),
        ),

        const SizedBox(height:30 ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                child: const Text ('Back'),
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),),
                onPressed: () {
                  setState(() {
                    activeIndex--;
                  });
                }),


          ],
        ),
      ],
    );
  }

  void updateAnnouncement() async{
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}update/announcement'));
    request.body = json.encode({
      "id": announcementId,
      "departuredate": initialdateval.text,
      "arrivaldate": finaldateval.text,
      "departuretown": departureController.text,
      "destinationtown": arrivalController.text,
      "quantity": quantityController.text,
      "computer": isChecked2,
      "restriction": restrictionController.text,
      "document": isChecked,
      "status": "ENABLED",
      "cni": "string",
      "ticket": "string",
      "covidtest": "string",
      "price": priceController.text,
      "validation": false,
      "userDto": {
        "id": currentUserId,
        "firstName": firstName,
        "lastName": lastName,
        "pseudo": pseudo,
        "email": email,
        "roleDtos": [
          {
            "id": 2,
            "name": "ROLE_CLIENT"
          }
        ],
        "password": "string",
        "status": "ENABLED"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      uploadTicket(ticket, announcementId);
      uploadPassport(passport, announcementId);
      uploadCovid(covidtest, announcementId);
      Fluttertoast.showToast(
          msg: "Announcement Upddated Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
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
}