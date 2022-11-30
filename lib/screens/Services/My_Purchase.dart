
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'dart:io' as plateform;
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../mainhome/mainhome.dart';
import '../notificationservice.dart';
import 'package:http/http.dart' as http;

class MyPurchase extends StatefulWidget {
  static const String routeName = 'My_Purchase';
  const MyPurchase({Key? key}) : super(key: key);

  @override
  MyPurchaseState createState() => MyPurchaseState();
}

class MyPurchaseState extends State<MyPurchase> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool showbackArrow = true;
  List paymentList = [];
  List paymentsReceived = [];
  bool showButton = false;
  NotificationService notificationService = NotificationService();
  final storage = const FlutterSecureStorage();
  bool isLoaded = false;
  bool hasSalary = false;
  String userId = "";
  String time = "";
  String operation = "";
  int selectedIndex = 0;
  bool showPicture = false;

  onSelected(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  void initState() {
    // TODO: implement initState
    initialisePage();
    super.initState();
  }

  initialisePage()async{
    final profileData = await storage.read(key: 'Profile');
    userId= json.decode(profileData!)["id"];
    paymentList = await getMypayments(userId);
    paymentsReceived = await getSalary(userId);

    if(paymentList.isNotEmpty){
      setState(() {
        isLoaded = true;
      });
    }
    if(paymentsReceived.isNotEmpty){
      setState(() {
        hasSalary = true;
      });

    }
  }

  getMypayments(String id)async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/payments?userid=$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final list = await response.stream.bytesToString();
      //print(json.decode(list));
      return json.decode(list);
    }
    else {
      print(response.reasonPhrase);
    }

  }

  getSalary(String id)async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}bills/paths/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final salarylist = await response.stream.bytesToString();
      //print(json.decode(salarylist));
      return json.decode(salarylist);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: Text('Historique des Finanaces',
          style: FontStyles.montserratRegular17().copyWith(
              color: Colors.white,fontWeight: FontWeight.bold
          ),),
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
      resizeToAvoidBottomInset: false,
      body:  _bodybuilder(context),
    );
  }

  int activeIndex = 0;
  int totalIndex = 2;
  bool paymentSelected = false;
  bool salarySelected =true;

  Widget _bodybuilder(BuildContext context){
    return Align(
      alignment: Alignment.topCenter,
      child:Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                child: Container(
                  height: 30.h,
                  width: 150.w,
                  margin: EdgeInsets.only(right: 10.0.w, top: 8.0.h),
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: salarySelected ? Colors.orange : Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      "Mes Ventes",
                      style: FontStyles.montserratRegular14().copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: (){
                  setState(() {
                    salarySelected = !salarySelected;
                    paymentSelected = false;
                  });
                },
              ),
              GestureDetector(
                child: Container(
                  height: 30.h,
                  width: 150.w,
                  margin: EdgeInsets.only(right: 10.0.w, top: 8.0.h),
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: paymentSelected ? Colors.orange : Colors.grey,
                  ),
                  child: Center(
                    child: Text(
                      "Mes Achats",
                      style: FontStyles.montserratRegular14().copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                onTap: (){
                  setState(() {
                    paymentSelected = !paymentSelected;
                    salarySelected = false;
                  });
                },
              ),
            ],
          ),
          if(paymentSelected)...[
            buildPayments(context)
          ]else if(salarySelected)...[
            buildSalaries(context)
          ]
        ],
      )
    );
  }

  Widget buildPayments(BuildContext context){
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text("Paiements effectué par l'utilisateur",
                  style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          isLoaded ? Expanded(
              child: ListView.builder(
                  itemCount: paymentList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0.r),
                        color: Colors.black12.withOpacity(0.08),
                      ),
                      padding: const EdgeInsets.all(5),
                      //margin: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: 5.0.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 15),
                          RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style:DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(text: "${paymentList[index]["date"]}",
                                    style: FontStyles.montserratRegular14().copyWith(color: Colors.blue)),
                                TextSpan(text: "\nLa somme de : ",
                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                TextSpan(text: "${paymentList[index]["amount"]} ${paymentList[index]["currency"]}",
                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold, letterSpacing: 3)),

                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Divider(color: Colors.black),
                          Text('Details: ${paymentList[index]["description"]}',
                              style: FontStyles.montserratRegular17().copyWith(color: Colors.black), overflow: TextOverflow.ellipsis),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  })
          ) : Center(
            child: Text('Liste Vide!',style:
            FontStyles.montserratRegular14().copyWith(color: Colors.grey)),
          ),
          SizedBox(height: 30)
        ],
      )
    );
  }

  Widget buildSalaries(BuildContext context){
    return  Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Text("Rémunérations reçcu de DGA",
                  style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
          ),
          hasSalary ? Expanded(
              child: ListView.builder(
                  itemCount: paymentsReceived.length,
                  itemBuilder: (context, index) {
                    var str = paymentsReceived[index];
                    var parts = str.split('_');
                    time = parts[2].trim();
                    operation = parts[3].toString();

                    return Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: (){
                                  setState(() {
                                    onSelected(index);
                                    showPicture = !showPicture;
                                  });
                                },
                                icon: const Icon(Icons.photo_size_select_actual_outlined, color: Colors.grey, size: 40)),
                            SizedBox(width: 20.w),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style:DefaultTextStyle.of(context).style,
                                    children: <TextSpan>[
                                      TextSpan(text: operation,
                                          style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                      TextSpan(text: "     $time",
                                          style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if(selectedIndex == index && showPicture)...[
                          Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0.r),
                                color: Colors.blue,
                              ),
                              padding: const EdgeInsets.all(5),
                              //margin: EdgeInsets.symmetric(horizontal: 2.0.w, vertical: 5.0.h),
                              child: Image.network("${Domain.dgaExpressPort}bill/image?file=${paymentsReceived[index]}", fit: BoxFit.fill)
                          )
                        ],
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Container(
                            transform: Matrix4.translationValues(0.0, 12.0, 0.0),
                            child: Container(
                              height: 0.5,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h)
                      ],
                    );

                  })
          ) : Center(
            child: Text('Liste Vide!',style:
            FontStyles.montserratRegular14().copyWith(color: Colors.grey),),
          )
        ],
      ),
    );
  }

  /*createCustomer() async {
    final PaymentController controller = Get.put(PaymentController());
    try {
      Map<String, dynamic> body = {
        'name': 'mike',
        'email': 'mike.el@gmial.com',
        'phone':'68574637426'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/customers'),
          body: body,
          headers: {
            'Authorization': 'Bearer sk_test_51LjiQQCZjIzC8XowwibBwvo0gxAvqYEOPaJRp8CAaXok9ZgjIau2mv5ntcScpulJ5E8d5hqzWu9odNTxR40E3tSq000zxFgGDf',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      print(jsonDecode(response.body)['id']);
      controller.makePayment(amount: '300', currency: 'eur', clientId: jsonDecode(response.body)['id']);
      //createPaymentMethod();
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }*/
}

