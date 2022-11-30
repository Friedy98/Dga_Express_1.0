import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import 'package:http/http.dart' as http;
import 'package:smart_shop/screens/mainhome/Marketplace.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'dart:io' as plateform;

import '../../Screens/ListArticles.dart';
import '../Services/StripePage.dart';
import '../subinformation.dart';

class Cart extends StatefulWidget {
  static const String routeName = 'cart';

  const Cart({Key? key}) : super(key: key);
  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {

  final storage = const FlutterSecureStorage();
  List? cartitems = [];
  int amount = 0;
  int sum = 0;
  int totalAmount = 0;
  int totelQty = 0;
  int quantity = 1;
  bool onChange = false;
  List<Subinformation>? subinformations;
  List<TextEditingController> textFieldControllers=[];
  String currency = "";
  int? selected;
  String? token;
  String code = "";
  String currentuserId = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String tel = "";
  List articlesAdded = [];
  List articleIds = [];
  List articleQties = [];
  bool isLoaded = false;

  @override
  void initState(){
    super.initState();
    getarticles();
  }

  Future getarticles()async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.clear();
    });
    String generateRandomString(int len) {
      var r = Random();
      const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
    }
    code = generateRandomString(40);
    final profileData = await storage.read(key: 'Profile');
    setState(() {
      currentuserId = json.decode(profileData!)['id'];
      firstName = json.decode(profileData)['firstName'];
      lastName = json.decode(profileData)['lastName'];
      email = json.decode(profileData)['email'];
      tel = json.decode(profileData)['phone'];
    });

    String? stringOfItems = await storage.read(key: 'listOfItems');
    if(stringOfItems != null) {

      articlesAdded = jsonDecode(stringOfItems);
      isLoaded = !isLoaded;
      //cartItems = articlesAdded.cast<ListArticles>();
    }
    amount = 0;
    onChange = false;

    for (var i = 0; i < articlesAdded.length; i++) {
      //print(articlesAdded[i]["name"]);
      textFieldControllers.add(TextEditingController());

      textFieldControllers[i] =  TextEditingController() ;
      textFieldControllers[i].text = "1";

    }
    if(mounted) {
      subinformations = await getsubInfo();
        if (subinformations != null) {
          for (var i in subinformations!) {
            setState(() {
              currency = i.currency;
            });
          }
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: AppBar(
        title: const Text('Mon Panier'),
        leading: IconButton(
          icon: Platform.isIOS ? const Icon(Icons.arrow_back_ios)  : const Icon(Icons.arrow_back),
          onPressed: ()async{
            if(articlesAdded.isEmpty){
              setState(() {
                storage.delete(key: "listOfItems");
              });
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_outlined),
            onPressed: (){
              if(cartitems != null){
                storage.delete(key: "listOfItems");
                Navigator.push(
                  context,
                  PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                      child: const MarketPlace()),
                );
              }else {
                Fluttertoast.showToast(
                    msg: "Votre carte est vide",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0
                );
              }
            },
          )
        ],
      ),
      body: _buildBody(context),
      bottomSheet: _buildBottomSheet(context),
    );
  }

  Future getsubInfo()async{

    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse('http://46.105.36.240:3000/sub/informations/view'));

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

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.0.h,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
              onTap: ()async{
                showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return AlertDialog(
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15.0))
                        ),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 200.h,
                            width: 300.w,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Moyen de Paiement",
                                    style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                Text("La some de 3280XAF (5€) sera inclus pour les taxes",
                                    style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                                const SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(Icons.attach_money_rounded, color: Colors.red),
                                  title: Text("Mobile Money",style:
                                  FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                  onTap: ()async{

                                    for(var i=0; i<articlesAdded.length; i++){
                                      articleIds.add(articlesAdded[i]["id"]);
                                      totelQty += int.parse(
                                          textFieldControllers[i].text) * int.parse(articlesAdded[i]["price"].toString());
                                    }

                                    amount += totelQty;
                                    if(currency == "XAF") {
                                      setState(() {
                                        totalAmount = amount + 3280;
                                      });
                                    }else if(currency == "€"){
                                      setState(() {
                                        totalAmount = (amount + 5) * 665;
                                      });

                                    }
                                    var headers = {
                                      'Content-Type': 'application/json'
                                    };
                                    var request = http.Request('POST', Uri.parse('https://api-checkout.cinetpay.com/v2/payment'));
                                    request.body = json.encode({
                                      "apikey": "105244761630ded20620d71.99923870",
                                      "site_id": "798029",
                                      "transaction_id": code,
                                      "mode": "PRODUCTION",
                                      "amount": "100",
                                      "currency": "XAF",
                                      "alternative_currency": "XAF",
                                      "description": " Pour les articles de $firstName $lastName",
                                      "customer_id": currentuserId,
                                      "customer_name": firstName,
                                      "customer_surname": lastName,
                                      "customer_email": email,
                                      "customer_phone_number": tel,
                                      "customer_address": "RAS",
                                      "customer_city": "RAS",
                                      "customer_country": "CM",
                                      "customer_state": "CM",
                                      "customer_zip_code": "065100",
                                      "notify_url": "https://webhook.site/d1dbbb89-52c7-49af-a689-b3c412df820d",
                                      "return_url": "https://webhook.site/d1dbbb89-52c7-49af-a689-b3c412df820d",
                                      "channels": "ALL",
                                      "metadata": "user1",
                                      "lang": "FR",
                                      "invoice_data": {
                                        "Vendeur": "DGA Express",
                                        "traget": "Pour les Achats",
                                        "receveur": "DGA Express"
                                      }
                                    });
                                    request.headers.addAll(headers);

                                    http.StreamedResponse response = await request.send();

                                    if (response.statusCode == 200) {

                                      final data = await response.stream.bytesToString();

                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              shape: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(20.0.r),
                                                  borderSide: const BorderSide(color: Colors.transparent)),
                                              content: Container(
                                                height: 90.0.h,
                                                width: 30.0.w,
                                                decoration: BoxDecoration(
                                                    color: AppColors.primaryDark,
                                                    gradient: const LinearGradient(
                                                        colors: [AppColors.primaryDark, AppColors.primaryLight],
                                                        begin: Alignment.bottomLeft,
                                                        end: Alignment.topRight,
                                                        stops: [0, 1]),
                                                    borderRadius: BorderRadius.only(
                                                        bottomLeft: Radius.circular(120.0.r),
                                                        bottomRight: Radius.circular(120.0.r))),
                                                child: const Center(
                                                  child: Icon(Icons.payment_outlined, size: 50, color: Colors.white),
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
                                              // actionsAlignment: MainAxisAlignment.center,
                                              actions: [
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: <Widget>[
                                                    Center(
                                                      child: Column(
                                                        children: [
                                                          Text("Effectuer le Payement!",style:
                                                          FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),

                                                          RichText(
                                                            text: TextSpan(
                                                              children: <TextSpan>[
                                                                TextSpan(text: "\nLa somme de ",
                                                                    style:
                                                                    FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                                TextSpan(text: "3280 $currency",
                                                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                                                                TextSpan(text: " sera inclus pour les frais de services. \nMerci!",
                                                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                              ],
                                                            ),
                                                          ),
                                                          RichText(
                                                            text: TextSpan(
                                                                children: <TextSpan>[
                                                                  TextSpan(text: "\nMontant = ",
                                                                      style:
                                                                      FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                                  TextSpan(text: "${
                                                                      amount.toString()
                                                                  } $currency",
                                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold))
                                                                ]
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: const EdgeInsets.all(2.0),
                                                            padding: const EdgeInsets.all(5.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text('Prix à Payer', style: FontStyles.montserratBold19()),

                                                                Text("$totalAmount $currency", style: FontStyles.montserratRegular19().copyWith(color: Colors.red, fontWeight: FontWeight.bold))
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Divider(color: Colors.black),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () async{
                                                            Navigator.pop(context);
                                                          },
                                                          child: Text('Annuler',
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),

                                                        ),
                                                        TextButton(
                                                          onPressed: () async{
                                                            var payment = json.decode(data)["data"]["payment_url"];
                                                            final Uri _url = Uri.parse(payment);
                                                            await launchUrl(_url);
                                                          },
                                                          child: Text('Payer',
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.green)),

                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          });
                                      //print(data);
                                    }
                                    else {
                                      final error = await response.stream.bytesToString();
                                      print(error);
                                    }

                                    Navigator.pop(context);
                                  },
                                ),
                                const Divider(color: Colors.grey),
                                ListTile(
                                  leading: const Icon(Icons.payment, color: Colors.red),
                                  onTap: ()async{

                                    for(var i=0; i<articlesAdded.length; i++){
                                      articleIds.add(articlesAdded[i]["id"]);
                                      articleQties.add(textFieldControllers[i].text);
                                      totelQty += int.parse(
                                          textFieldControllers[i].text) * int.parse(articlesAdded[i]["price"].toString());
                                    }

                                    final prefs = await SharedPreferences.getInstance();
                                    double amountToPay = 0;
                                    totelQty = 0;
                                    for(var i=0; i<articlesAdded.length; i++){

                                      totelQty += int.parse(
                                          textFieldControllers[i].text) * int.parse(articlesAdded[i]["price"].toString());
                                    }

                                    amount += totelQty;
                                    if(currency == "XAF") {
                                      setState(() {
                                        amountToPay = (amount + 3280)/650;
                                      });
                                    }else if(currency == "€"){
                                      setState(() {
                                        amountToPay = amount + 5;
                                      });
                                    }
                                    await prefs.setDouble('totalAmount', amountToPay);
                                    await prefs.setString('description', "Article");
                                    await storage.write(key: "listOfIds", value: jsonEncode(articleIds));
                                    await storage.write(key: "listOfQty", value: jsonEncode(articleQties));

                                    Navigator.push(
                                      context,
                                      PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 300),
                                          child: const StripePage()),
                                    );

                                  },
                                  title: Text("Carte Bancaire",style:
                                  FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });

              },
              child: Center(
                child: Container(
                    height: 40.h,
                    width: 200.w,
                    margin: EdgeInsets.only(bottom: 10.0.h),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Center(
                      child: Text("Payer",
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.white, fontWeight: FontWeight.bold) ),
                    )
                ),
              )
          ),
        ],
      ),
    );
  }

  getallArticles() async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('http://46.105.36.240:3000/articles/available'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List products = json.decode(data);
      return products.map((data) => ListArticles.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Widget _buildBody(BuildContext context) {
    return Container(
          color: Colors.black12,
          child: Visibility(
            visible: isLoaded,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0.r),
                    topLeft: Radius.circular(20.0.r)),
              ),
              child: articlesAdded.isNotEmpty ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: articlesAdded.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {

                        textFieldControllers[index] =  TextEditingController() ;
                        textFieldControllers[index].text = "1";

                        return Container(
                          margin: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0.r),
                            color: Colors.black12,
                          ),
                          padding: const EdgeInsets.all(5),
                          //margin: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: 5.0.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.topRight,
                                  child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.red,
                                      child: IconButton(
                                          onPressed: ()async{

                                            setState(() {
                                              //Navigator.pop(dialogContex);
                                              setState(() {
                                                articlesAdded.remove(articlesAdded[index]);
                                              });
                                              //if(articlesAdded[index]['id'] == )

                                              Fluttertoast.showToast(
                                                  msg: "Article retiré du Panier",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.grey,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0
                                              );
                                              //_showWidget(dialogContex);
                                            });
                                            await storage.write(key: 'listOfItems', value: jsonEncode(articlesAdded));
                                          },
                                          icon: const Icon(Icons.delete, size: 25,color: Colors.white)
                                      )
                                  )
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                      width: 100.w,
                                      height: 100.h,
                                      child: Image.network("http://46.105.36.240:3000/article/image?file=" + articlesAdded[index]["mainImage"], fit: BoxFit.fill)
                                  ),
                                  SizedBox(width: 10.0.w),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style:DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(text: articlesAdded[index]["name"],
                                            style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                        TextSpan(text: " \n " + articlesAdded[index]["price"].toString() + currency,
                                            style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),
                                        TextSpan(text: " \n Le " + articlesAdded[index]["date"].toString(),
                                            style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)),

                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text('Disponible: ${articlesAdded[index]["quantity"].toString()}',
                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                  SizedBox(
                                      width: 130,
                                      child: TextFormField(
                                        controller: textFieldControllers[index],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        decoration: const InputDecoration(
                                            fillColor: Colors.white,
                                            labelText: "Quantité",
                                            hintText: "1",
                                            icon: Icon(Icons.price_check)
                                        ),
                                        onChanged: (value){
                                          onChange = true;
                                          amount = 0;
                                          //print(value);
                                          if(int.parse(value)> articlesAdded[index]['quantity'] ) {
                                            setState(() {
                                              value = articlesAdded[index]['quantity'].toString();
                                              textFieldControllers[index].text = value;
                                            });
                                          }else{
                                            value = "${int.parse(value)}";
                                            textFieldControllers[index].text = value;
                                          }
                                        },
                                        validator: (inputValue){
                                          if(inputValue!.isEmpty){
                                            return "Field Required";
                                          }
                                          return null;
                                        },
                                      )
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ) : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 100,color: Colors.grey),
                  Text("votre panier est vide",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            )
          ),
        );
  }
}
