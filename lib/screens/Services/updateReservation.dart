
import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import '../../Common/Widgets/custom_app_bar.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../ListReservations.dart';
import '../subinformation.dart';
import 'My_Reservations.dart';

class UpdateReservation extends StatefulWidget {
  static const String routeName = 'UpdateReservation';
  const UpdateReservation({Key? key}) : super(key: key);

  @override
  _UpdateReservationState createState() => _UpdateReservationState();
}

class _UpdateReservationState extends State<UpdateReservation> {

  var isLoaded = false;
  bool showbackArrow = true;
  bool isChecked = false;
  bool isChecked2 = false;
  final storage = const FlutterSecureStorage();

  @override
  void initState(){
    super.initState();
    getAnnDataReserve();
  }

  String announcementId = '';
  String departureDate = "";
  String arrivaldate = "";
  String departuretown = "";
  String destinationtown = "";
  bool computer = false;
  bool document = false;
  int? price = 0;
  int? quantity = 0;
  String restriction = "";

  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  String currentUserId = "";

  String travellerfirstName = "";
  String travellerlastName = "";
  String travellerpseudo = "";
  String travelleremail = "";
  String travellerId = "";
  String reservId = "";

  bool isdocument = false;
  bool iscomputer = false;
  bool setdocquantity = false;
  bool setcomputerquantity = false;
  String phoneNumber = "";
  List<Subinformation>? subinformations;

  int activeIndex = 0;
  int totalIndex = 2;
  String docprice = "";
  String computerprice = "";
  String currency = "";

  void getAnnDataReserve() async {
    reservId = (await storage.read(key: "reservId"))!;
    announcementId = (await storage.read(key: 'announcementId'))!;

    descriptionController.text = (await storage.read(key: "description"))!;
    quantityController.text = (await storage.read(key: "quantity"))!;
    computerController.text = (await storage.read(key: "computer"))!;
    documentController.text = (await storage.read(key: "document"))!;
    nameController.text = (await storage.read(key: "receiver"))!;
    phoneNumber = (await storage.read(key: "tel"))!;
    cniController.text = (await storage.read(key: "receivernumbercni"))!;

    getAnnouncementById(announcementId);
    final profileData = await storage.read(key: 'Profile');
    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            docprice = i.documentPrice;
            computerprice = i.computerPrice;
            currency = i.currency;
          });
        }
      }
      setState(() {
        firstName = json.decode(profileData!)['firstName'];
        lastName = json.decode(profileData)['lastName'];
        pseudo = json.decode(profileData)['pseudo'];
        email = json.decode(profileData)['email'];
        currentUserId = json.decode(profileData)['id'];
      });
    }
  }

  Future getsubInfo()async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}sub/informations/view'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List myresults = json.decode(data);

      return myresults.map((data) => Subinformation.fromJson(data)).toList();

    }
    else {
      print(response.reasonPhrase);
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

      Map<String, dynamic> senderDto = json.decode(data);

      //print(senderDto["userDto"]);
      setState(() {
        travellerId = senderDto["userDto"]["id"];
        travellerfirstName = senderDto["userDto"]["firstName"];
        travellerlastName = senderDto["userDto"]["lastName"];
        travellerpseudo = senderDto["userDto"]["pseudo"];
        travelleremail = senderDto["userDto"]["email"];

        departureDate = json.decode(data)["departuredate"];
        arrivaldate = json.decode(data)["arrivaldate"];
        departuretown = json.decode(data)["departuretown"];
        destinationtown = json.decode(data)["destinationtown"];
        document = json.decode(data)["document"];
        computer = json.decode(data)["computer"];
        quantity = json.decode(data)["quantity"];
        price = json.decode(data)["price"];
        restriction = json.decode(data)["restriction"];
      });
      if(document == true){
        setState(() {
          isdocument = true;
        });
      }
      if(computer == true){
        setState(() {
          iscomputer = true;
        });
      }
    }
    else {
      print(response.reasonPhrase);
    }
  }

  final GlobalKey <FormState> _formKey = GlobalKey <FormState>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  TextEditingController quantityController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController computerController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController telController = TextEditingController();
  TextEditingController cniController = TextEditingController();
  TextEditingController documentQuantity = TextEditingController();
  TextEditingController computerQuantity = TextEditingController();

  List<ListReservation> reservation = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: const Text('Mettre à jour une Reservations'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                  child: const MyReservations()),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: _buildBody(context),
    );
  }

    Widget _buildBody(BuildContext context) {
      switch (activeIndex) {
        case 0:
          return _buildfirstForm(context);
        case 1:
          return _buildSecondForm(context);

        default:
          return _buildfirstForm(context);
      }
    }

    Widget _buildfirstForm(BuildContext context) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnnouncement(),
            _buildForm(context),
          ],
        ),
      );
    }

  bool isValidForm = false;
  bool isloading = false;

    Widget _buildSecondForm(BuildContext context){
      return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                const SizedBox(height: 13.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Receiver Info',
                        style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: nameController,
                  autocorrect: true,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    hintText: 'Full Name',
                    labelText: 'Full Name',
                    icon: Icon(Icons.person),
                  ),
                  validator: (inputValue){
                    if(inputValue == ''){
                      return null;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 13.0),
                IntlPhoneField(
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    hintText: '+237 655333333',
                    labelText: 'Phone Number',
                    icon: const Icon(Icons.phone),
                  ),
                  initialCountryCode: 'IN',
                  onChanged: (phone) {
                    phoneNumber = phone.completeNumber;
                  },
                ),
                //phonefield
                const SizedBox(height: 13.0),
                TextFormField(
                  controller: cniController,
                  autocorrect: true,
                  decoration: const InputDecoration(
                    hintText: 'CMR076400119',
                    labelText: 'CNI/Passport Number',
                    icon: Icon(Icons.card_membership),
                  ),
                  validator: (inputValue){
                    if(inputValue == ''){
                      return null;
                    }
                    return null;
                  },
                ),

                const SizedBox(height:30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    ElevatedButton(
                        child: Text ('Retour',style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(110, 35),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),),
                        onPressed: () {
                          setState(() {
                            activeIndex--;
                          });
                        }),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(110, 35),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),),
                      onPressed: () async{

                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isValidForm = true;
                            UpdateReserv();
                            //PaymentMethod();
                          });
                        } else {
                          setState(() {
                            isValidForm = false;
                          });
                        }
                      },
                      child: Text('Valider',style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),),
                  ],
                ),
              ],
            ),
          )
      );
    }

  Widget _buildAnnouncement() {
    return Container(
        margin: EdgeInsets.only(bottom: 10.0.h,left: 10.0.w, right: 10.w, top: 8.0.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xEFF2F7), Colors.white],
          ),
          border: Border.all(width: 2, color: Color(0xBDA8A8AC)),
          color: Colors.lightBlueAccent,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                children: [
                  const SizedBox(height: 25),
                  const SizedBox(width: 20,),
                  const Icon(Icons.location_pin, color: Colors.red),
                  const SizedBox(width: 5,),
                  Text("Departure Town",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 30,),
                  const Icon(Icons.location_pin, color: Colors.red),
                  const SizedBox(width: 5,),
                  Text("Arrival Town",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        departuretown,
                        style:
                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 35),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        destinationtown,
                        style:
                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(height: 25),
                  const SizedBox(width: 20,),
                  const Icon(Icons.calendar_today, color: Colors.black),
                  const SizedBox(width: 5,),
                  Text("Departure Date",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 34,),
                  const Icon(Icons.calendar_today, color: Colors.black),
                  const SizedBox(width: 5,),
                  Text("Arrival Date",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        departureDate,
                        style:
                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 35),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        arrivaldate,
                        style:
                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(height: 25),
                  const SizedBox(width: 20,),
                  const Icon(Icons.mail_outline, color: Colors.black),
                  const SizedBox(width: 5,),
                  Text("Documents?",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 60),
                  const Icon(Icons.laptop_mac, color: Colors.black),
                  const SizedBox(width: 10,),
                  Text("Computer?",style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 20),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        document.toString(),
                        style:
                        FontStyles.montserratRegular17().copyWith(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(width: 35),
                  SizedBox(
                    height: 30.0,
                    width: 150.0,
                    child: Center(
                      child: Text(
                        computer.toString(),
                        style:
                        FontStyles.montserratRegular17().copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.price_check_sharp, color: Colors.black,),
                title: Text("Price per Kilo",style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Text(price.toString(),
                  style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.production_quantity_limits, color: Colors.black,),
                title: Text("Quantity",style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Text(quantity.toString(),
                  style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.description, color: Colors.black,),
                title: Text("Restriction",style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                subtitle: Text(restriction,
                  style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black),
                ),
              ),
            ]
        )
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              readOnly: true,
              controller: quantityController,
              decoration: const InputDecoration(
                  hintText: 'Quantity in Kg',
                  labelText: 'quantity',
                  icon: Icon(Icons.production_quantity_limits, color: Colors.black)
              ),
              validator: (inputValue) {
                if (inputValue == '') {
                  return "";
                }
                return null;
              },
            ),
            const SizedBox(height: 13.0),
            Visibility(
              visible: isdocument,
              child: Row(
                children: [
                  const Icon(Icons.mail_outline),
                  const SizedBox(width: 13.0),
                  const Text("Documents?"),
                  Checkbox(
                    value: isChecked,
                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                        setdocquantity = true;
                      });
                      if(value!){
                        "Yes";
                      }else{
                        "No";
                      }
                    },
                  ),
                  const SizedBox(width: 13.0),
                  if(isChecked)...[
                    SizedBox(
                      width: 100.0.w,
                      child: TextFormField(
                        controller: documentQuantity,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: '1',
                          labelText: 'Enter Quantity',
                          //suffixIcon: const Icon(Icons.shopping_cart),
                        ),
                        validator: (inputValue){
                          if(inputValue!.isEmpty ) {
                            return "field Required!";
                          }
                        },
                      ),
                    )]
                ],
              ),
            ),
            isdocument ? Text(docprice + currency + '/doc',
                style:
                FontStyles.montserratRegular17().copyWith(color: Colors.deepOrangeAccent)) : const SizedBox(height: 0.0),

            const SizedBox(height: 13.0),
            Visibility(
              visible: iscomputer,
              child: Row(
                children: [
                  const Icon(Icons.laptop_mac),
                  const SizedBox(width: 13.0),
                  const Text("Computers?"),
                  Checkbox(
                    value: isChecked2,
                    onChanged: (value) {
                      setState(() {
                        isChecked2 = value!;
                        setcomputerquantity = true;
                      });
                      if(value!){
                        "Yes";
                      }else{
                        "No";
                      }
                    },
                  ),
                  const SizedBox(width: 13.0),
                  if(isChecked2)...[
                    SizedBox(
                      width: 100.0.w,
                      child: TextFormField(
                        controller: computerQuantity,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: '1',
                          labelText: 'Enter Quantity',
                          //suffixIcon: const Icon(Icons.shopping_cart),
                        ),
                        validator: (inputValue){
                          if(inputValue!.isEmpty ) {
                            return "field Required!";
                          }
                        },
                      ),
                    )]
                ],
              ),
            ),
            iscomputer ? Text(computerprice + currency + '/pc',
                style:
                FontStyles.montserratRegular17().copyWith(color: Colors.deepOrangeAccent)) : const SizedBox(width: 13.0),

            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                  hintText: 'Description',
                  labelText: 'Description',
                  icon: Icon(Icons.description, color: Colors.black)
              ),
              validator: (inputValue) {
                if (inputValue == '') {
                  return "";
                }
                return null;
              },
            ),
            const SizedBox(height: 13.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(110, 35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),),
              onPressed: () async{

                if (_formKey.currentState!.validate()) {
                  setState(() {
                    isValidForm = true;
                    setState(() {
                      activeIndex++;
                    });
                    //PaymentMethod();
                  });
                } else {
                  setState(() {
                    isValidForm = false;
                  });
                }
              },
              child: Text('Next',style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),),
            //_dropdown(context),
          ],
        ),
      ),

    );
  }

  void UpdateReserv() async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}update/reseravtion'));
    request.body = json.encode({
      "id": reservId,
      "description": descriptionController.text,
      "documents": isChecked,
      "computer": isChecked2,
      "status": "ENABLED",
      "quantitykilo": quantityController.text,
      "date": "string",
      "track": "string",
      "quantityDocument": documentQuantity.text,
      "quantityComputer": computerQuantity.text,
      "receiver": nameController.text,
      "tel": phoneNumber,
      "receivernumbercni": cniController.text,
      "userDto": {
        "id": currentUserId,
        "firstName": firstName,
        "lastName": lastName,
        "profileimgage": "string",
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
      },
      "announcementDto": {
        "id": announcementId,
        "departuredate": departureDate,
        "arrivaldate": arrivaldate,
        "departuretown": departuretown,
        "destinationtown": destinationtown,
        "quantity": quantity,
        "computer": computer,
        "restriction": restriction,
        "document": document,
        "status": "ENABLED",
        "cni": "string",
        "ticket": "string",
        "covidtest": "string",
        "price": price,
        "validation": true,
        "userDto": {
          "id": travellerId,
          "firstName": travellerfirstName,
          "lastName": travellerlastName,
          "profileimgage": "string",
          "pseudo": travellerpseudo,
          "email": travelleremail,
          "roleDtos": [
            {
              "id": 2,
              "name": "ROLE_CLIENT"
            }
          ],
          "password": "string",
          "status": "ENABLED"
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final reservekilo = await response.stream.bytesToString();
      print(reservekilo);

      Fluttertoast.showToast(
          msg: "Reservation Updated Sucessfully",
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
              builder: (context) => const MyReservations()));
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
}