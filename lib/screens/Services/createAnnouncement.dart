
import 'dart:convert';
import 'dart:core';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
//import 'package:maps_places_autocomplete/maps_places_autocomplete.dart';
//import 'package:maps_places_autocomplete/model/place.dart';
//import 'package:maps_places_autocomplete/model/suggestion.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/My_Announcements.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../subinformation.dart';
import 'finishAnnReview.dart';

class CreateAnnouncement extends StatefulWidget {
  static const String routeName = 'CreateAnnouncement';
  const CreateAnnouncement({Key? key}) : super(key: key);

  @override
  _CreateAnnouncementState createState() => _CreateAnnouncementState();

}

class _CreateAnnouncementState extends State<CreateAnnouncement> {

  bool showbackArrow = true;
  final storage = const FlutterSecureStorage();
  bool isChecked = false;
  bool isChecked2 = false;
  bool momo = false;
  bool creditCard = false;

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
  String docprice = "";
  String computerprice = "";
  String currency = "";
  List<Subinformation>? subinformations;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final profileData = await storage.read(key: 'Profile');
    setState(() {
      currentUserId = json.decode(profileData!)['id'];
      firstName = json.decode(profileData)['firstName'];
      lastName = json.decode(profileData)['lastName'];
      pseudo = json.decode(profileData)['pseudo'];
      email = json.decode(profileData)['email'];
    });
    subinformations = await getsubInfo();
    for(var i in subinformations!){
      setState(() {
        docprice = i.documentPrice;
        computerprice = i.computerPrice;
        currency = i.currency;
      });
    }
    //_getCardTypeFrmNumber();
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

  final GlobalKey <FormState> _formKey = GlobalKey <FormState> ();
  //final GlobalKey<ScaffoldState> _key = GlobalKey();

  TextEditingController departureController = TextEditingController();
  TextEditingController arrivalController = TextEditingController();
  TextEditingController initialdateval = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController finaldateval = TextEditingController();
  TextEditingController restrictionController = TextEditingController();
  TextEditingController documentController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController cniController = TextEditingController();
  TextEditingController paymentMethodController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      //key: _key,
      appBar: AppBar(
        title: const Text('Ajouter Un Voyage'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? const Icon(Icons.arrow_back_ios)  : const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                  child: const mainhome()),
            );
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.only(
            left: 10.0.w, right: 10.0.w, bottom: 10.h,top: 0.h),
        child: Column(
          children: [
            _buildForm(context)
          ],
        ),
      )
    );
  }

  bool isValidForm = false;
  bool isloading = false;
  String countryValue = "";
  String countryValue2 = "";
  String stateValue = "";
  String stateValue2 = "";
  String cityValue = "";
  String paymentMethod = "";

  Future _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2030));
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(pickedDate!);
    if(pickedDate != null ){
      setState(() {
        initialdateval.text = formattedDate; //set output date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }

  /*String? _city;
  String? _state;
  String? _country;

  void onSuggestionClick(Place placeDetails) {
    setState(() {
      _city = placeDetails.city;
      _state = placeDetails.state;
      _country = placeDetails.country;
    });
  }*/

  Future _selectDate2() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 0)),
        lastDate: DateTime(2030));
    String formattedDate = DateFormat("yyyy-MM-ddTHH:mm:ss").format(pickedDate!);

    if(pickedDate != null ){
      setState(() {
        finaldateval.text = formattedDate; //set output date to TextField value.
      });
    }else{
      print("Date is not selected");
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Expanded(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            DelayedAnimation(delay: 200,
                child: TextFormField(
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
                      return 'field required';
                    }
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
            ),

            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 300,
                child: TextFormField(
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
                      return 'field required';
                    }
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
            ),

            const SizedBox(height: 13.0),
            /*SizedBox(
              height: 40,
              child: MapsPlacesAutocomplete(
                  mapsApiKey: 'YOUR KEY HERE',
                  onSuggestionClick: onSuggestionClick,
                  buildItem: (Suggestion suggestion, int index) {
                    return Container(
                        margin: const EdgeInsets.fromLTRB(2, 2, 2, 0),
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        color: Colors.white,
                        child: Text(suggestion.description)
                    );
                  },
                  inputDecoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText:
                      "Departure Town ",
                      errorText: null),
                  clearButton: const Icon(Icons.close),
                  componentCountry: 'br',
                  language: 'pt-Br'
              ),
            ),*/
            DelayedAnimation(delay: 400,
                child: TextFormField(
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
                    if(inputValue!.isEmpty ){
                      return 'field required';
                    }
                    return null;
                  },
                ),
            ),

            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 500,
                child: TextFormField(
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
                    if(inputValue!.isEmpty){
                      return "field required";
                    }
                    return null;
                  },
                ),
            ),

            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 600,
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: quantityController,
                  decoration: const InputDecoration(
                      hintText: 'Quantity in Kg',
                      labelText: 'quantity',
                      icon: Icon(Icons.production_quantity_limits)
                  ),
                  validator: (inputValue){
                    if(inputValue!.isEmpty){
                      return 'field required';
                    }
                    return null;
                  },
                ),
            ),

            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 700,
                child: Row(
                  children: [
                    SizedBox(
                        width: 250.w,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          controller: priceController,
                          decoration: const InputDecoration(
                              hintText: 'Price per Kilo',
                              labelText: 'Price',
                              icon: Icon(Icons.price_check_sharp)
                          ),
                          validator: (inputValue){
                            if(inputValue!.isEmpty){
                              return 'field required';
                            }
                            return null;
                          },
                        )
                    ),
                    Text(currency,
                      style: FontStyles.montserratRegular17().copyWith(
                          color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                      ),)
                  ],
                ),
            ),

            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 800,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mail_outline),
                        SizedBox(width: 5.0.w),
                        Text("Documents?",
                            style: FontStyles.montserratRegular14().copyWith(
                                color: const Color(0xFF34283E))),
                        Checkbox(
                          value: isChecked,
                          onChanged: (value) {
                            setState(() {
                              isChecked = !isChecked;
                            });
                          },
                        ),
                        const SizedBox(width: 10.0),
                        Text(docprice + currency+ "/doc",
                          style: FontStyles.montserratRegular14().copyWith(
                              color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                          ),)
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.laptop_mac),
                        SizedBox(width: 5.0.w),
                        Text("Computers?",
                            style: FontStyles.montserratRegular14().copyWith(
                                color: const Color(0xFF34283E))),
                        Checkbox(
                          value: isChecked2,
                          onChanged: (value) {
                            setState(() {
                              isChecked2 = !isChecked2;
                            });
                          },
                        ),
                        const SizedBox(width: 10.0),
                        Text(computerprice + currency +"/Pc",
                          style: FontStyles.montserratRegular14().copyWith(
                              color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                          ),)
                      ],
                    ),
                  ],
                ),
            ),
            const SizedBox(height: 13.0),
            DelayedAnimation(delay: 900,
                child: Text("Je souhaite etre payé par",
                    style: FontStyles.montserratRegular19().copyWith(
                        color: const Color(0xFF34283E), fontWeight: FontWeight.bold)
                ),
            ),

            DelayedAnimation(delay: 300,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.attach_money_rounded),
                        SizedBox(width: 5.0.w),
                        Text("Mobile Money",
                            style: FontStyles.montserratRegular14().copyWith(
                                color: const Color(0xFF34283E))),
                        Checkbox(
                          value: momo,
                          onChanged: (value) {
                            setState(() {
                              momo = !momo;
                              creditCard = false;
                            });
                          },
                        ),
                      ],
                    ),
                    if(momo)...[
                      IntlPhoneField(
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: '+237 655333333',
                          labelText: 'Téléphone',
                          icon: const Icon(Icons.phone),
                        ),
                        initialCountryCode: 'IN',
                        onChanged: (phone) {
                          String phoneNumber = phone.completeNumber;
                          paymentMethod = "Mobile Money";
                          paymentMethodController.text = phoneNumber;
                        },
                      ),
                    ]
                  ],
                ),
            ),
            DelayedAnimation(delay: 1000,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card_sharp),
                        SizedBox(width: 5.0.w),
                        Text("Carte Bancaire",
                            style: FontStyles.montserratRegular14().copyWith(
                                color: const Color(0xFF34283E))),
                        Checkbox(
                          value: creditCard,
                          onChanged: (value) {
                            setState(() {
                              creditCard = !creditCard;
                              momo = false;
                            });
                          },
                        ),
                      ],
                    ),
                    if(creditCard)...[
                      TextFormField(
                        controller: paymentMethodController,
                        autofocus: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'Votre IBAN',
                          labelText: 'Votre IBAN',
                          //icon: CardUtils.getCardIcon(_paymentCard.type),
                        ),
                        //validator: CardUtils.validateCardNumWithLuhnAlgorithm,
                      ),
                    ]
                  ],
                ),
            ),
            DelayedAnimation(delay: 1100,
                child: TextFormField(
                  controller: restrictionController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: const InputDecoration(
                      hintText: 'Je ne veux pas Transporter...',
                      labelText: 'Restriction?',
                      icon: Icon(Icons.description_outlined)
                  ),
                  validator: (inputValue){
                    if(inputValue!.isEmpty){
                      return 'field required';
                    }
                    return null;
                  },
                ),
            ),

            const SizedBox(height: 30.0),
            DelayedAnimation(delay: 1200,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(110, 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),),
                          onPressed: () async{
                            if(_formKey.currentState?.validate() ?? false){
                              setState(() => isloading = true);
                              if(paymentMethodController.text.isNotEmpty) {
                                await _postAnnouncement();
                              }else {
                                Fluttertoast.showToast(
                                    msg: "Entrez un Moyen de Paiement",
                                    toastLength: Toast.LENGTH_SHORT,
                                    fontSize: 20,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 2
                                );
                              }
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
                              : const Text('Submit')),
                    ]
                ),
            ),
          ],
        )
      )
    );
  }

  _postAnnouncement() async {
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}createAnnouncement'));
    request.body = json.encode({
      "departuredate": initialdateval.text,
      "arrivaldate": finaldateval.text,
      "departuretown": departureController.text,
      "destinationtown": arrivalController.text,
      "quantity": quantityController.text,
      "computer": isChecked2,
      "restriction": restrictionController.text,
      "document": isChecked,
      "cni": "string",
      "ticket": "string",
      "covidtest": "string",
      "price": priceController.text,
      "paymentMethod": paymentMethodController.text,
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
        "password": "Ghost@123",
        "status": "ENABLED"
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      var id = json.decode(data)["id"];
      print(id);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 300.0.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 70,color: Colors.orange),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "Succèss! \nBien vouloir verifier le contenu des colis avant de les transporter DGA n'est pas responsable de ces colis Merci!",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \nPour completer votre annonce, bien vouloir nous fournir les documents spécifié",
                                style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                          ],

                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(
                        color: Colors.grey,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                              onPressed: (){
                                Navigator.push(
                                  context,
                                  PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                                      child: const MyTravels()),
                                );
                              },
                              child: Text('Plus tard',
                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.grey))
                          ),
                          TextButton(
                              onPressed: (){
                                storage.write(key: 'announcementId', value: id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const finishAnnReview(),
                                  ),
                                );
                              },
                              child: Text('Completer',
                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.blue))
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          });

      MotionToast.success(
        description:  Text("Voyage crée avce Succès", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

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
}

class CreditCardNumberFormater extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}