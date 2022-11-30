import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_brand.dart';
import 'package:flutter_credit_card/credit_card_form.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_credit_card/custom_card_type_icon.dart';
import 'package:flutter_credit_card/glassmorphism_config.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'dart:io' as plateform;
import '../../Screens/mainhome/Marketplace.dart';
import '../../Utils/font_styles.dart';
import '../notificationservice.dart';
import 'package:http/http.dart' as http;

class StripePage extends StatefulWidget {
  static const String routeName = 'StripePage';
  const StripePage({Key? key}) : super(key: key);

  @override
  StripePageState createState() => StripePageState();
}

class StripePageState extends State<StripePage> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool showbackArrow = true;
  List listOfPayment = [];
  bool showButton = false;
  NotificationService notificationService = NotificationService();
  final storage = const FlutterSecureStorage();
  bool autreAddress = false;
  bool entrepotNamur = false;
  bool entrepotBruxelles = false;
  bool dropdown = false;
  String entrepotDGA = "";

  @override
  void initState() {
    // TODO: implement initState
    initializeParameters();
    super.initState();
  }

  void update() => setState(() {});
  final formKey = GlobalKey<FormState>();
  String description = "";
  double amount = 0;
  String email = "";
  bool isCvvFocused = false;
  bool useGlassMorphism = true;
  bool useBackgroundImage = false;
  bool isloading = false;
  bool isValidForm = false;
  List articleIds = [];
  List listOfQty = [];

  String countryValue = "";
  String stateValue = "";

  initializeParameters()async{
    final profileData = await storage.read(key: 'Profile');
    final prefs = await SharedPreferences.getInstance();
    final amountToPay = prefs.getDouble("totalAmount");
    final detail = prefs.getString("description");
    final listOfIds = await storage.read(key: "listOfIds");
    final listOfQties = await storage.read(key: "listOfQty");

    if(detail != null && amountToPay != null && profileData != null && listOfIds != null && listOfQties != null) {
      setState(() {
        amount = (amountToPay * 100);
        description = detail;
        email = json.decode(profileData)['email'];
        articleIds = json.decode(listOfIds);
        listOfQty = json.decode(listOfQties);
      });
    }
    print("${amount.toStringAsFixed(0)}, $description, $email, $articleIds, $listOfQty");
  }

  TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      resizeToAvoidBottomInset: false,
      body:  _bodybuilder(context),
    );
  }

  Widget _bodybuilder(BuildContext context){
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
                "assets/images/bg.png"
            ),
            fit: BoxFit.cover
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 30.h),
          Row(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: FloatingActionButton(
                  backgroundColor: Colors.grey,
                  onPressed: ()async{
                    final prefs = await SharedPreferences.getInstance();
                    setState(() {
                      prefs.clear();
                    });

                    Navigator.pop(context);
                  },
                  child: plateform.Platform.isIOS ? const Icon(Icons.arrow_back_ios)  : const Icon(Icons.arrow_back),
                ),
              ),
              SizedBox(width: 30.h),
              Text('Informations de la Carte', style: FontStyles.montserratRegular17().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 20.h),
          CreditCardWidget(
            glassmorphismConfig:
            useGlassMorphism ? Glassmorphism.defaultConfig() : null,
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            cardBgColor: Colors.red,
            isChipVisible: true,
            isHolderNameVisible: true,
            isSwipeGestureEnabled: true,
            showBackView: isCvvFocused,
            customCardTypeIcons: <CustomCardTypeIcon>[
              CustomCardTypeIcon(
                cardType: CardType.visa,
                cardImage: Image.asset(
                  'assets/images/paypal.png',
                  height: 48,
                  width: 48,
                ),
              ),
            ],

            onCreditCardWidgetChange: (CreditCardBrand creditCardBrand) {}, //true when you want to show cvv(back) view
          ),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white, Colors.white, Colors.white, Colors.white, Colors.white10],
                          ),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                              bottomLeft: Radius.circular(15.0)
                          )),
                    child: Column(
                      children: [
                        CreditCardForm(
                          formKey: formKey, // Required
                          cardNumber: cardNumber,
                          cvvCode: cvvCode,
                          expiryDate: expiryDate,
                          cardHolderName: cardHolderName,
                          onCreditCardModelChange: onCreditCardModelChange,// Required
                          themeColor: Colors.white,
                          obscureCvv: false,
                          obscureNumber: false,
                          isHolderNameVisible: true,
                          isCardNumberVisible: true,
                          isExpiryDateVisible: true,
                          cardNumberValidator: (number){
                            if(number == null){
                              return "Field required";
                            }
                          },
                          expiryDateValidator: (expiryDate){
                            if(expiryDate == null){
                              return "Field required";
                            }
                          },
                          cvvValidator: (cvv){
                            if(cvv == null){
                              return "Field required";
                            }
                          },
                          cardHolderValidator: (String? cardHolderName){},
                          onFormComplete: () {
                            setState(() {
                              print("Complete");
                            });
                          },
                          cardNumberDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            labelText: 'Numero de Carte',
                            hintText: 'XXXX XXXX XXXX XXXX',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Colors.black), //<-- SEE HERE
                            ),
                          ),
                          expiryDateDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            labelText: 'Date d\'expiration',
                            hintText: 'XX/XX',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Colors.black), //<-- SEE HERE
                            ),
                          ),
                          cvvCodeDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            labelText: 'CVV',
                            hintText: 'XXX',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Colors.black), //<-- SEE HERE
                            ),
                          ),
                          cardHolderDecoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            fillColor: Colors.white,
                            labelText: 'Titulaire de la carte',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 2, color: Colors.black), //<-- SEE HERE
                            ),
                          ),
                        ),
                        Center(
                          child: Text("Address de Livraison",
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: const Color(0xFF34283E))),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_shipping_outlined),
                                  SizedBox(width: 5.0.w),
                                  Text("Entrepot de DGA",
                                      style: FontStyles.montserratRegular14().copyWith(
                                          color: const Color(0xFF34283E))),
                                  dropdown ? IconButton(
                                      onPressed: (){
                                        setState(() {
                                          dropdown = !dropdown;
                                        });

                                      }, icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.orange)
                                  ) : IconButton(
                                      onPressed: (){
                                        setState(() {
                                          dropdown = !dropdown;
                                        });

                                      }, icon: const Icon(Icons.arrow_drop_down_circle_outlined)
                                  )
                                ],
                              ),
                              if(dropdown)...[
                                Container(
                                  padding: const EdgeInsets.fromLTRB(30, 5, 0, 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.local_shipping_rounded),
                                          SizedBox(width: 5.0.w),
                                          Text("Entrepot de Namur",
                                              style: FontStyles.montserratRegular14().copyWith(
                                                  color: const Color(0xFF34283E))),
                                          Checkbox(
                                            value: entrepotNamur,
                                            onChanged: (value) {
                                              setState(() {
                                                entrepotNamur = !entrepotNamur;
                                                entrepotDGA = "Entrepot de Namur";
                                                autreAddress = false;
                                                entrepotBruxelles = false;
                                                addressController.text = entrepotDGA;
                                              });
                                              print(addressController.text);
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.local_shipping_rounded),
                                          SizedBox(width: 5.0.w),
                                          Text("Entrepot de Bruxelles",
                                              style: FontStyles.montserratRegular14().copyWith(
                                                  color: const Color(0xFF34283E))),
                                          Checkbox(
                                            value: entrepotBruxelles,
                                            onChanged: (value) {
                                              setState(() {
                                                entrepotBruxelles = !entrepotBruxelles;
                                                entrepotDGA = "Entrepot de Bruxelle";
                                                autreAddress = false;
                                                entrepotNamur =false;
                                                addressController.text = entrepotDGA;
                                              });
                                              print(addressController.text);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.local_shipping_outlined),
                                      SizedBox(width: 5.0.w),
                                      Text("Autre",
                                          style: FontStyles.montserratRegular14().copyWith(
                                              color: const Color(0xFF34283E))),
                                      Checkbox(
                                        value: autreAddress,
                                        onChanged: (val) {
                                          setState(() {
                                            autreAddress = !autreAddress;
                                            entrepotBruxelles = false;
                                            entrepotNamur = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if(autreAddress)...[
                                    TextFormField(
                                      controller: addressController,
                                      autofocus: false,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                        hintText: 'Livrer à...',
                                        labelText: 'Address de Livraison',
                                        filled: true,
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 2, color: Colors.black), //<-- SEE HERE
                                        ),
                                      ),
                                    ),
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(15))
                              ),
                              width: 250.w,
                              height: 40.h,
                              child: isloading
                                  ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                  )) : Center(
                                child: Text("Payer", style:
                                FontStyles.montserratRegular17().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                              )
                          ),
                          onTap: () async {
                            if (formKey.currentState!.validate()) {
                              isValidForm = true;
                                setState(() => isloading = true);
                                makePayment();
                                setState(() => isloading = false);
                            }
                            else {
                              setState(() {
                                isValidForm = false;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 40.0),
                      ],
                    )
                  )
              )
          ),
        ],
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  void makePayment() async{
    String spl = expiryDate;
    var date = spl.split("/");
    var expmonth = date[0].trim();
    var expyear = date[1].trim();
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.MultipartRequest('GET', Uri.parse('http://46.105.36.240:3000/card/payment'));
    request.fields.addAll({
      'cardNumber': cardNumber,
      'exp_month': expmonth,
      'exp_year': expyear,
      'cvc': cvvCode
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      final token = jsonDecode(result)["tokenId"];
      print(token);
      description == "Article" ? proceedArticlePayment(token)
          : proceedReservationPayment(token);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void proceedArticlePayment(String tokenId) async{

    String ids = articleIds.join(",");
    String quantities = listOfQty.join(',');

    final prefs = await SharedPreferences.getInstance();
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var request = http.Request('POST', Uri.parse('http://46.105.36.240:3000/payment/articles?amount=${amount.toStringAsFixed(0)}&description=$description&token=$tokenId&currency=EUR&email=$email&address=${addressController.text}&articlesIds=$ids&quantities=$quantities'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      print(result);

      Fluttertoast.showToast(
          msg: "✅ Paiement Réussi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER ,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20
      );

      setState(() {
        prefs.clear();
      });
      storage.delete(key: "listOfItems");
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
            child: const MarketPlace()),
      );
    }
    else {
      final error = await response.stream.bytesToString();

      MotionToast.error(
        description:  Text(json.decode(error)['error'], style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);
    }
  }

  proceedReservationPayment(String tokenId) async{

    final prefs = await SharedPreferences.getInstance();

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.MultipartRequest('POST', Uri.parse('http://46.105.36.240:3000/payment/reservations?amount=${amount.toStringAsFixed(0)}&currency=EUR&token=$tokenId&description=$description&email=$email'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      print(result);

      Fluttertoast.showToast(
          msg: "✅ Paiement Réussi",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER ,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20
      );
      listOfPayment.add(result);
      await storage.write(key: 'listOfPayment', value: jsonEncode(listOfPayment));
      Navigator.pop(context);
      setState(() {
        prefs.clear();
      });
    }
    else {
      final error = await response.stream.bytesToString();

      MotionToast.error(
        description:  Text(json.decode(error)['error'], style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);
    }
  }
}

