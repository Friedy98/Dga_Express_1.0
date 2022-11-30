import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/Another_animation.dart';
import 'package:smart_shop/screens/Services/Message.dart';
import 'package:smart_shop/screens/Services/StripePage.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/Services/updateReservation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Common/Widgets/app_button.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import 'package:animated_icon_button/animated_icon_button.dart';
import '../../Screens/Login/login.dart';
import '../../Screens/subinformation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../ListReservations.dart';
import '../mainhome/mainhome.dart';

class MyReservations extends StatefulWidget {
  static const String routeName = 'MyReservations';
  const MyReservations({Key? key}) : super(key: key);

  @override
  MyReservationsState createState() => MyReservationsState();
}

class MyReservationsState extends State<MyReservations> {

  final storage = const FlutterSecureStorage();
  List<ListReservation>? reservation;
  var isLoaded = false;
  bool isLoaded2 = false;
  bool isMyReserv = true;
  bool toggle = false;
  String profilePic = "";
  bool popupComplete = false;

  String currentUserId = "";
  bool iscurrentuserReserv = true;
  bool iscurrentuserReserv2 = true;
  var someCapitalizedString = "someString".capitalize!;

  String announcementId = "";
  String announcementUserDto = "";
  int total = 0;
  double totalbyCart = 0;
  List<Subinformation>? subinformations;
  String subject = "";
  int docPrice = 0;
  int computerPrice = 0;
  String currency = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    subinformations = await getsubInfo();
    for(var i in subinformations!){
      setState(() {
        docPrice = int.parse(i.documentPrice);
        computerPrice = int.parse(i.computerPrice);
        currency = i.currency;
      });
    }
    final profileData = await storage.read(key: 'Profile');
    currentUserId = json.decode(profileData!)['id'];
    reservation = await getMyReservations(currentUserId);
    reservation?.reversed;
    if(mounted) {
      if (reservation!.isNotEmpty) {
        setState(() {
          isLoaded = true;
        });
      }else{
        setState(() {
          isLoaded2 = true;
        });
      }
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

  Future getMyReservations(String id) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/$id/reservations'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List myReservation = json.decode(data);
      //print(data);
      await storage.write(key: 'totalReservations', value: myReservation.length.toString());

      return myReservation.map((data) => ListReservation.fromJson(data)).toList();

    }else if(response.statusCode == 403){
      await response.stream.bytesToString();

      MotionToast.warning(
          description:  Text("Session expiré!", style: FontStyles.montserratRegular17().copyWith(
              color: Colors.black))
      ).show(context);

      await storage.deleteAll();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const login()));
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }

  bool showbackArrow = true;
  final commentController = TextEditingController();
  String noteController = "";

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: AppBar(
        title: const Text('Mes Reservations'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: isLoaded,
              child: Expanded(
                child: isLoaded ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: reservation?.length,
                    itemBuilder: (context, index){

                      return AnotherDelayedAnimation(delay: 300,
                      child:
                        Container(
                          margin: EdgeInsets.only(bottom: 10.0.h,left: 10.0.w, right: 10.w, top: 8.0.h),
                          decoration: BoxDecoration(
                            gradient: reservation![index].userDto.id != currentUserId ? const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xABD4F5FF), Colors.white],
                            ) : const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xF3F6D39F), Colors.white],
                            ),
                            border: Border.all(width: 2, color: const Color(0xABAFAFB1)),
                            borderRadius: const BorderRadius.all(Radius.circular(5)),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: DelayedAnimation(delay: 500,
                              child:
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if(reservation![index].userDto.id == currentUserId && reservation![index].announcementDto.status == "ENABLED")...[
                                      if(!reservation![index].confirm)...[
                                        GestureDetector(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.update,color: Colors.orange),
                                                Text(" Modifier ", style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                                              ],
                                            ),
                                            onTap: ()async{
                                              await storage.write(key: "reservId", value: reservation![index].id);
                                              await storage.write(key: "description", value: reservation![index].description);
                                              await storage.write(key: "quantity", value: reservation![index].quantitykilo.toString());
                                              await storage.write(key: "computer", value: reservation![index].computer.toString());
                                              await storage.write(key: "document", value: reservation![index].documents.toString());
                                              await storage.write(key: "receiver", value: reservation![index].receiver);
                                              await storage.write(key: "tel", value: reservation![index].tel.toString());
                                              await storage.write(key: "receivernumbercni", value: reservation![index].receivernumbercni);

                                              await storage.write(key: "announcementId", value: reservation![index].announcementDto.id);

                                              Navigator.pushReplacementNamed(context, UpdateReservation.routeName);
                                            }),
                                      ]
                                    ],
                                    if(reservation![index].userDto.id == currentUserId && reservation![index].announcementDto.status == "DISABLED")...[
                                      Row(
                                            children: [
                                              const Icon(Icons.update,color: Colors.grey),
                                              Text(" Modifier ", style: FontStyles.montserratRegular14().copyWith(color: Colors.grey)),
                                            ],
                                          ),
                                    ],
                                    if(reservation![index].userDto.id != currentUserId)...[
                                      if(reservation![index].track != "complete")...[
                                        GestureDetector(child: Row(
                                          children: [
                                            const Icon(Icons.chat_bubble_rounded,color: Colors.blue),
                                            Text(" Chat ", style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),

                                          ],
                                        ),
                                            onTap: ()async{
                                              await storage.write(key: "senderid", value: reservation![index].userDto.id);
                                              await storage.write(key: "reservationId", value: reservation![index].id);

                                              await storage.write(key: "Rdeparturetown", value: reservation![index].announcementDto.departuretown,);
                                              await storage.write(key: "Rarrivaltown", value: reservation![index].announcementDto.destinationtown,);
                                              await storage.write(key: "subject", value: "reservation");

                                              Navigator.pushReplacementNamed(context, Messages.routeName);
                                            }),]else...[
                                        Row(
                                          children: [
                                            const Icon(Icons.chat_bubble_rounded,color: Colors.grey),
                                            Text(" Chat ", style: FontStyles.montserratRegular14().copyWith(color: Colors.grey)),

                                          ],
                                        ),
                                      ],
                                      const SizedBox(width: 10),
                                      if(!reservation![index].confirm)...[
                                        Row(
                                          children: [
                                            IconButton(
                                                icon: const Icon(Icons.access_time),
                                                onPressed: () {
                                                  setState(() {
                                                    confirmReservation(reservation![index].id);
                                                  });
                                                }),
                                            Text("En attente...", style: FontStyles.montserratRegular14().copyWith(color: Colors.grey))
                                          ],
                                        )
                                      ]else...[
                                        const Icon(Icons.check_circle_rounded, color: Colors.green)
                                      ]
                                    ]else...[
                                      if(reservation![index].announcementDto.status != "DISABLED" && reservation![index].track != "complete")...[
                                          GestureDetector(
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.chat_bubble_rounded,color: Colors.blue),
                                                  Text(" Chat ", style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),

                                                ],
                                              ),
                                              onTap: ()async{
                                                await storage.write(key: "senderid", value: reservation![index].announcementDto.userDto.id);
                                                await storage.write(key: "reservationId", value: reservation![index].id);

                                                await storage.write(key: "Rdeparturetown", value: reservation![index].announcementDto.departuretown,);
                                                await storage.write(key: "Rarrivaltown", value: reservation![index].announcementDto.destinationtown,);
                                                await storage.write(key: "subject", value: "reservation");

                                                Navigator.pushReplacementNamed(context, Messages.routeName);
                                              })
                                      ]else...[
                                        Row(
                                              children: [
                                                const Icon(Icons.chat_bubble_rounded,color: Colors.grey),
                                                Text(" Chat ", style: FontStyles.montserratRegular14().copyWith(color: Colors.grey)),

                                              ],
                                            ),
                                      ],
                                      if(reservation![index].confirm)...[
                                        if(reservation![index].track != "complete")...[
                                          Row(
                                              children: [

                                                CircleAvatar(
                                                  radius: 25,
                                                  backgroundColor: Colors.black12,
                                                  child:
                                                AnimatedIconButton(
                                                  size: 30,
                                                  onPressed: () async{

                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            scrollable: true,
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                            content: Padding(
                                                              padding: const EdgeInsets.all(8.0),
                                                              child: SizedBox(
                                                                height: 200.h,
                                                                width: 300.0.w,
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
                                                                        int finalpriceDoc = (reservation![index].quantityDocument * docPrice);
                                                                        int finalpricePc = (reservation![index].quantityComputer * computerPrice);
                                                                        if(currency == "XAF"){
                                                                          setState(() {
                                                                            total = finalpricePc + finalpriceDoc + reservation![index].totalprice + 3280;
                                                                          });
                                                                        }else if(currency == "€"){
                                                                          total = (finalpricePc + finalpriceDoc + reservation![index].totalprice + 5) * 650;
                                                                        }

                                                                        print("$finalpriceDoc + $finalpricePc + ${reservation![index].totalprice} + 3280 = $total XAF");

                                                                        var headers = {
                                                                          'Content-Type': 'application/json'
                                                                        };
                                                                        var request = http.Request('POST', Uri.parse('https://api-checkout.cinetpay.com/v2/payment'));
                                                                        request.body = json.encode({
                                                                          "apikey": "105244761630ded20620d71.99923870",
                                                                          "site_id": "798029",
                                                                          "transaction_id": reservation![index].id,
                                                                          "mode": "PRODUCTION",
                                                                          "amount": total,
                                                                          "currency": "XAF",
                                                                          "alternative_currency": "XAF",
                                                                          "description": " Pour la reservation de ${reservation![index].userDto.firstName} ${reservation![index].userDto.lastName}",
                                                                          "customer_id": reservation![index].userDto.id,
                                                                          "customer_name": reservation![index].userDto.firstName,
                                                                          "customer_surname": reservation![index].userDto.lastName,
                                                                          "customer_email": reservation![index].userDto.email,
                                                                          "customer_phone_number": reservation![index].userDto.phone,
                                                                          "customer_address": "Antananarivo",
                                                                          "customer_city": "Antananarivo",
                                                                          "customer_country": "CM",
                                                                          "customer_state": "CM",
                                                                          "customer_zip_code": "065100",
                                                                          "notify_url": "https://webhook.site/d1dbbb89-52c7-49af-a689-b3c412df820d",
                                                                          "return_url": "https://webhook.site/d1dbbb89-52c7-49af-a689-b3c412df820d",
                                                                          "channels": "ALL",
                                                                          "metadata": "user1",
                                                                          "lang": "FR",
                                                                          "invoice_data": {
                                                                            "voyageur": reservation![index].announcementDto.userDto.firstName + " " + reservation![index].announcementDto.userDto.lastName,
                                                                            "traget": "De "+reservation![index].announcementDto.departuretown + "à " + reservation![index].announcementDto.destinationtown,
                                                                            "receveur": reservation![index].receiver + "; CNI:" + reservation![index].receivernumbercni
                                                                          }
                                                                        });
                                                                        request.headers.addAll(headers);

                                                                        http.StreamedResponse response = await request.send();

                                                                        if (response.statusCode == 200) {
                                                                          Fluttertoast.showToast(
                                                                              msg: "Un moment...",
                                                                              toastLength: Toast.LENGTH_SHORT,
                                                                              gravity: ToastGravity.BOTTOM,
                                                                              timeInSecForIosWeb: 2,
                                                                              backgroundColor: Colors.grey,
                                                                              textColor: Colors.white,
                                                                              fontSize: 20.0
                                                                          );
                                                                          final data = await response.stream.bytesToString();
                                                                          var payment = json.decode(data)["data"]["payment_url"];
                                                                          final Uri _url = Uri.parse(payment);
                                                                          await launchUrl(_url);
                                                                          //print(data);
                                                                        }
                                                                        else {
                                                                          final data = await response.stream.bytesToString();
                                                                          debugPrint(data);
                                                                        }
                                                                        Navigator.pop(context);

                                                                      },
                                                                    ),
                                                                    const Divider(color: Colors.grey),
                                                                    ListTile(
                                                                      leading: const Icon(Icons.payment, color: Colors.red),
                                                                      onTap: ()async{

                                                                        final prefs = await SharedPreferences.getInstance();

                                                                        int finalpriceDoc = (reservation![index].quantityDocument * docPrice);
                                                                        int finalpricePc = (reservation![index].quantityComputer * computerPrice);
                                                                        if(currency == "XAF"){
                                                                          setState(() {
                                                                            totalbyCart = (finalpricePc + finalpriceDoc + reservation![index].totalprice + 3280)/665;

                                                                          });
                                                                            print("${total.toStringAsFixed(3)}€");
                                                                        }else if(currency == "€"){
                                                                          totalbyCart = (finalpricePc + finalpriceDoc + reservation![index].totalprice + 5);
                                                                        }
                                                                        await prefs.setDouble('totalAmount', totalbyCart);
                                                                        await prefs.setString('description', "Resrvation: ${reservation![index].id}");

                                                                        Navigator.push(
                                                                          context,
                                                                          PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 500),
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
                                                  duration: const Duration(milliseconds: 500),
                                                  splashColor: Colors.cyanAccent,
                                                  icons: const <AnimatedIconItem>[
                                                    AnimatedIconItem(
                                                      icon: Icon(Icons.attach_money_sharp, size: 30,color: Colors.green),
                                                    ),
                                                    AnimatedIconItem(
                                                      icon: Icon(Icons.attach_money_sharp, size: 30,color: Colors.lightBlue),
                                                    ),
                                                  ],
                                                ),)
                                              ]
                                          ),
                                        ]
                                      ]else...[
                                        Row(
                                          children: const[
                                            Icon(Icons.pending_actions_rounded, color: Colors.grey,),
                                            Text(' En attente... ')
                                          ],
                                        )
                                      ]
                                    ]
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(reservation![index].userDto.id != currentUserId)...[
                                      if(reservation![index].announcementDto.status == "DISABLED")...[
                                        const Icon(Icons.lock_rounded,size: 40,color: Colors.black12)
                                      ]
                                    ]
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if(reservation![index].userDto.id == currentUserId)...[
                                      if(reservation![index].status == "DISABLED")...[
                                        const Icon(Icons.delete_rounded,size: 40,color: Colors.black12)
                                      ]
                                    ]
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 0.0.h, bottom: 5.h),
                                      width: 80.0,
                                      height: 80.0,
                                      child: GestureDetector(
                                        onTap: (){
                                          //Navigator.pushReplacementNamed(context, Mur.routeName);
                                        },
                                        child: ProfilePicture(
                                            name: reservation![index].userDto.firstName,
                                            radius: 60,
                                            fontsize: 21,
                                            img: reservation![index].userDto.profileimgage != ""
                                            ? 'http://46.105.36.240:3000/' + reservation![index].userDto.profileimgage
                                                : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                          ),
                                      ),
                                    ),
                                    RichText(
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        style:DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          if(reservation![index].userDto.id != currentUserId)...[
                                            TextSpan(text:"De: " + reservation![index].userDto.firstName.capitalize! + " " + reservation![index].userDto.lastName.capitalize!,
                                                style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                          ]else...[
                                            TextSpan(text:"De: Vous",
                                                style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                            TextSpan(text: " \n à " + reservation![index].announcementDto.userDto.firstName + " " + reservation![index].announcementDto.userDto.lastName,
                                                style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)),
                                          ],
                                          TextSpan(text: " \n Le " + reservation![index].date.toString(),
                                              style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)),

                                        ],

                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ListTile(
                                  leading: const Icon(Icons.pin_drop, color: Colors.red),
                                  title: Text(
                                    "De",
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    FontStyles.montserratRegular17().copyWith(
                                        color: Colors.red),
                                  ),
                                  subtitle: Text(
                                    reservation![index].announcementDto.departuretown,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    FontStyles.montserratRegular17().copyWith(
                                        color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.pin_drop, color: Colors.red),
                                  title: Text(
                                    "à",
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    FontStyles.montserratRegular17().copyWith(
                                        color: Colors.red),
                                  ),
                                  subtitle: Text(
                                    reservation![index].announcementDto.destinationtown,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                    FontStyles.montserratRegular17().copyWith(
                                        color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style:DefaultTextStyle.of(context).style,
                                        children: <TextSpan>[
                                          TextSpan(text: "Total Price: ",
                                              style:
                                              FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                          TextSpan(text: reservation![index].totalprice.toString() + currency,
                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),
                                        ],

                                      ),
                                    ),
                                    if(reservation![index].userDto.id != currentUserId && !reservation![index].confirm)...[
                                      GestureDetector(
                                          child: Container(
                                            padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10.0.r),
                                                  color: Colors.green
                                              ),
                                            child: Center(
                                              child: Text("Confirmer",
                                                style: FontStyles.montserratBold14()
                                                    .copyWith(color: AppColors.white, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          onTap: (){
                                            setState(() {
                                              confirmReservation(reservation![index].id);
                                            });
                                          }
                                      )
                                    ]
                                  ],
                                ),

                                const SizedBox(height: 10),
                                if(reservation![index].userDto.id == currentUserId && reservation![index].announcementDto.status == "ENABLED")...[
                                  if(reservation![index].confirm)...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(" Code ",style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold) ),
                                        SizedBox(
                                          width: 220.0.w,
                                          child: TextFormField(
                                            initialValue: reservation![index].id,
                                            focusNode: FocusNode(),
                                            enableInteractiveSelection: false,
                                            readOnly: true,
                                            autofocus: false,
                                            decoration: const InputDecoration(
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomLeft: Radius.circular(10)
                                              )),
                                              filled: true,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: 35.w,
                                          height: 52.h,
                                          decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight: Radius.circular(10),
                                              ),
                                              color: Colors.grey
                                          ),
                                          child: GestureDetector(
                                            onTap: (){
                                              FlutterClipboard.copy(reservation![index].id).then(( value ) => Fluttertoast.showToast(
                                                  msg: "Copied to clipboard",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.grey,
                                                  textColor: Colors.white,
                                                  fontSize: 20.0
                                              ));
                                            },
                                            child: const Icon(Icons.file_copy_rounded, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    )
                                  ]
                                ],
                                if(reservation![index].userDto.id == currentUserId && reservation![index].announcementDto.status == "DISABLED")...[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(" Code ",style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold) ),
                                      SizedBox(
                                        width: 220.0.w,
                                        child: TextFormField(
                                          initialValue: reservation![index].id,
                                          enabled: false,
                                          focusNode: FocusNode(),
                                          enableInteractiveSelection: false,
                                          readOnly: true,
                                          autofocus: false,
                                          decoration: const InputDecoration(
                                            fillColor: Colors.black12,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            )),
                                            filled: true,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 35.w,
                                        height: 52.h,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color: Colors.black12
                                        ),
                                        child: GestureDetector(
                                          onTap: (){
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
                                                            const Icon(Icons.warning_amber_rounded, size: 70,color: Colors.grey),
                                                            RichText(
                                                              text: TextSpan(
                                                                style:DefaultTextStyle.of(context).style,
                                                                children: <TextSpan>[
                                                                  TextSpan(text: "cette annonce à été suprimé...bien vouloir ",
                                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                                  TextSpan(text: "Nous Contacter",
                                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                                                                  TextSpan(text: " pour plus d'information",
                                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                                ],

                                                              ),
                                                            ),
                                                            const SizedBox(height: 20),
                                                            const Divider(color: Colors.grey,),
                                                            const SizedBox(height: 15),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                GestureDetector(
                                                                    child: Text('Fermer',
                                                                        style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),
                                                                    onTap: (){
                                                                      Navigator.of(context, rootNavigator: true).pop();
                                                                    }
                                                                ),
                                                                const SizedBox(width: 30),
                                                                GestureDetector(
                                                                    child: Text('Nous Contacter',
                                                                        style: FontStyles.montserratRegular17().copyWith(color: Colors.orange)),
                                                                    onTap: (){
                                                                      Navigator.of(context, rootNavigator: true).pop();
                                                                    }
                                                                ),
                                                              ],
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: const Icon(Icons.file_copy_rounded, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if(reservation![index].userDto.id == currentUserId)...[
                                      if(reservation![index].track == "complete")...[
                                        Row(
                                          children: [
                                            IconButton(
                                                onPressed: ()async{
                                                  popupComplete = true;
                                                  await storage.write(key: 'announcementId', value: reservation![index].announcementDto.id);
                                                  await storage.write(key: 'announcementUserDto', value: reservation![index].announcementDto.userDto.id);
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return makeAlert(context);
                                                      });
                                                },
                                                icon: const Icon(Icons.comment, size: 25, color: Colors.green)),
                                            if(reservation![index].announcementDto.point == 0)...[
                                              Row(
                                                children: [
                                                  FocusedMenuHolder(
                                                    blurSize: 2.0,
                                                    menuItemExtent: 40,
                                                    menuBoxDecoration: const BoxDecoration(
                                                        color: Colors.grey,
                                                        borderRadius: BorderRadius.all(
                                                            Radius.circular(15.0))),
                                                    duration: const Duration(
                                                        milliseconds: 100),
                                                    animateMenuItems: true,
                                                    blurBackgroundColor: Colors.black54,
                                                    openWithTap: true,
                                                    // Open Focused-Menu on Tap rather than Long Press
                                                    menuOffset: 10.0,
                                                    // Offset value to show menuItem from the selected item
                                                    bottomOffsetHeight: 80.0,
                                                    onPressed: () {
                                                      Fluttertoast.showToast(
                                                          msg: 'Noter ${reservation![index].announcementDto.userDto.firstName} ${reservation![index].announcementDto.userDto.lastName}',
                                                          toastLength: Toast.LENGTH_SHORT,
                                                          gravity: ToastGravity.CENTER,
                                                          timeInSecForIosWeb: 5,
                                                          backgroundColor: Colors.blue,
                                                          textColor: Colors.white,
                                                          fontSize: 20.0
                                                      );
                                                    },
                                                    menuItems: <FocusedMenuItem>[
                                                      FocusedMenuItem(title: const Text("1"),trailingIcon: const Icon(Icons.thumb_down_alt_rounded) ,onPressed: (){
                                                        noteController = "2";
                                                        launchNotation(noteController, reservation![index].announcementDto.id);
                                                      }),
                                                      FocusedMenuItem(title: const Text("2"),trailingIcon: const Icon(Icons.thumb_down_alt_rounded) ,onPressed: (){
                                                        noteController = "2";
                                                        launchNotation(noteController, reservation![index].announcementDto.id);
                                                      }),
                                                      FocusedMenuItem(title: const Text("3"),trailingIcon: const Icon(Icons.thumb_down_alt_rounded) ,onPressed: (){
                                                        noteController = "3";
                                                        launchNotation(noteController, reservation![index].announcementDto.id);
                                                      }),
                                                      FocusedMenuItem(title: const Text("4"),trailingIcon: const Icon(Icons.thumb_down_alt_rounded) ,onPressed: (){
                                                        noteController = "4";
                                                        launchNotation(noteController, reservation![index].announcementDto.id);
                                                      }),
                                                      FocusedMenuItem(title: const Text("5"),trailingIcon: const Icon(Icons.thumb_up) ,onPressed: (){
                                                        noteController = "5";
                                                        launchNotation(noteController, reservation![index].announcementDto.id);
                                                      }),
                                                    ],
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                            width: 100.w,
                                                            height: 30.h,
                                                            decoration: const BoxDecoration(
                                                                borderRadius: BorderRadius.only(
                                                                  topLeft: Radius.circular(10),
                                                                  bottomLeft: Radius.circular(10),
                                                                ),
                                                                color: Colors.blue
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Text("Noter",
                                                                    style: FontStyles.montserratRegular17().copyWith(color:
                                                                    Colors.white, fontWeight: FontWeight.bold)),
                                                                const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white)
                                                              ],
                                                            )
                                                        ),
                                                        //const SizedBox(width: 10),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ] else...[
                                              const Icon(Icons.thumb_up, color: Colors.blue, size: 25)
                                            ]
                                          ],
                                        ),
                                      ]
                                    ],
                                    Center(
                                      child: TextButton(
                                        onPressed: () async{
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  scrollable: true,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                                  content: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: SizedBox(
                                                      width: 300.0.w,
                                                      child: Column(
                                                        children: [
                                                          if(reservation![index].userDto.id != currentUserId)...[
                                                            Text(reservation![index].userDto.firstName + " " +
                                                                reservation![index].userDto.lastName,
                                                                style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                          ]else...[
                                                            Text("Vous",
                                                                style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                          ],
                                                          ListTile(
                                                            leading: const Icon(Icons.description),
                                                            title: Text("Description de l'Article :",style:
                                                            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                            subtitle: Text(reservation![index].description,
                                                              style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(Icons.shopping_cart),
                                                            title: Text("Quantité Reservé:",style:
                                                            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                            subtitle: Text(reservation![index].quantitykilo.toString() + " Kg",
                                                              style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                            ),
                                                          ),
                                                          if(reservation![index].documents)...[
                                                            ListTile(
                                                              leading: const Icon(Icons.mail_outline),
                                                              title: Text("Document",style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                              subtitle: Text(reservation![index].quantityDocument.toString(),
                                                                style:
                                                                FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                              ),
                                                            ),]else...[
                                                            ListTile(
                                                              leading: const Icon(Icons.mail_outline),
                                                              title: Text("Document",style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                              subtitle: Text("Non",
                                                                style:
                                                                FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                              ),
                                                            )
                                                          ],
                                                          if(reservation![index].computer)...[
                                                            ListTile(
                                                              leading: const Icon(Icons.laptop_mac),
                                                              title: Text("Pc",style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                              subtitle: Text(reservation![index].quantityComputer.toString(),
                                                                style:
                                                                FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                              ),
                                                            ),]else...[
                                                            ListTile(
                                                              leading: const Icon(Icons.laptop_mac),
                                                              title: Text("Pc",style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                              subtitle: Text("Non",
                                                                style:
                                                                FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                              ),
                                                            ),
                                                          ],
                                                          const SizedBox(height: 15),
                                                          const Divider(color: Colors.grey,),
                                                          const SizedBox(height: 15),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Text('Information du \ncorrespondant',
                                                                  style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 15),
                                                          ListTile(
                                                            leading: const Icon(Icons.person),
                                                            title: Text("Nom:",style:
                                                            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                            subtitle: Text(reservation![index].receiver,
                                                              style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(Icons.phone),
                                                            title: Text("Tel: ",style:
                                                            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                            subtitle: Text(reservation![index].tel.toString(),
                                                              style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                            ),
                                                          ),
                                                          ListTile(
                                                            leading: const Icon(Icons.card_membership),
                                                            title: Text("Numéro CNI/Passport ",style:
                                                            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                            subtitle: Text(reservation![index].receivernumbercni,
                                                              style:
                                                              FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              });
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text("Plus", style: FontStyles.montserratRegular17().copyWith(color: Colors.orange)),
                                            const Icon(Icons.info_outline_rounded,color: Colors.orange)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ]
                          ))
                      ));
                    }
                ) : Center(
                  child: Text('Pas de Reservations trouvé',style:
                  FontStyles.montserratRegular14().copyWith(color: Colors.black12),),
                )
              ),
              replacement: plateform.Platform.isIOS
                  ? const Center(
                child: CupertinoActivityIndicator(
                  animating: true,
                  radius: 15,
                ),
                //Text("Loading...",style: FontStyles.montserratRegular17().copyWith(color: Colors.black38)),
              ): Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(20),
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.white10,
                  color: Colors.blue,
                  strokeWidth: 5,
                ),
              ),
          ),
          Visibility(
              visible: isLoaded2,
              child: Center(
                child: Text('Pas de Reservations trouvé',style:
                FontStyles.montserratRegular14().copyWith(color: Colors.grey),),
              )
          ),
          SizedBox(height: 30.h),
        ],
      )

    );
  }

  Widget makeAlert(BuildContext context) {
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
          child: Icon(Icons.thumb_up, size: 50, color: Colors.white),
        ),
      ),
      contentPadding: EdgeInsets.only(left: 20.0.w, right: 20.0.w),
      // actionsAlignment: MainAxisAlignment.center,
      actions: [
        if(popupComplete)...[
          _buildPopComplete(context),
        ]else...[
          _buildPopContent(context),
        ]

      ],
    );
  }
   Widget _buildPopComplete(BuildContext context) {
    return Column(
      children: [
        Text(
          'Transaction Complète!',
          style: FontStyles.montserratBold19(),
        ),
        SizedBox(height: 10.0.h),
        Text(
          'Votre transaxction à été complété avec succès',
          style: FontStyles.montserratRegular14(),
        ),
        Text(
          'Bien vouloir laisser un commentaire',
          style: FontStyles.montserratRegular14(),
        ),
        SizedBox(height: 10.0.h),
        SizedBox(
          width: 250.0.w,
          child: TextFormField(
            controller: commentController,
            autofocus: false,
            autocorrect: true,
            minLines: 1,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              hintText: 'Ajouter un commentaire',
            ),
            validator: (inputValue){
              if(inputValue!.isEmpty ) {
                return "field Required!";
              }
            },
          ),
        ),
        SizedBox(height: 10.0.h),
        Container(
          margin: EdgeInsets.only(bottom: 10.0.h),
          child: AppButton.button(
            text: 'Envoyer',
            color: AppColors.secondary,
            height: 48.h,
            width: 200.w,
            onTap: () {
              // Navigator.pushReplacementNamed(context, Main.routeName);
              sendComment();
            },
          ),
        ),
        SizedBox(height: 10.0.h),
      ],
    );
  }

  Widget _buildPopContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Paiement Effectué!',
          style: FontStyles.montserratBold19(),
        ),
        SizedBox(height: 10.0.h),
        Text(
          'Vous venez de confirmer votre payement \n Bien vouloir envoyer ce code ded validation à votre correspondant',
          style: FontStyles.montserratRegular14(),
        ),
        SizedBox(height: 10.0.h),
        TextButton(onPressed:(){
          Navigator.pop(context);
        },
            child: Text('OK',
                style: FontStyles.montserratRegular19().copyWith(
                    color: Colors.blue, fontWeight: FontWeight.bold))),
        SizedBox(height: 20.0.h),
      ],
    );
  }

  bool isValidForm = false;

  void confirmReservation(String reservationid) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}confirm/reseravtion/$reservationid'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: const MyReservations(), duration: const Duration(milliseconds: 300)),
      );
      Fluttertoast.showToast(
          msg: "Reservation Confirmed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
      toggle = true;
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
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

  void sendComment() async{

    String? token = await storage.read(key: "accesstoken");

    announcementId = (await storage.read(key: 'announcementId'))!;
    announcementUserDto = (await storage.read(key: 'announcementUserDto'))!;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}user/comment/announcement'));
    request.body = json.encode({
      "content": commentController.text,
      "booker": {
        "id": currentUserId,
        "firstName": "string",
        "lastName": "string",
        "profileimgage": "string",
        "pseudo": "string",
        "email": "string",
        "phone": "string",
        "roleDtos": [
          {
            "id": 2,
            "name": "ROLE_CLIENT"
          }
        ],
        "password": "string",
        "status": "ENABLED",
        "stars": 0
      },
      "announcement": {
        "id": announcementId,
        "departuredate": "2022-08-09T09:37:43.479Z",
        "arrivaldate": "2022-08-09T09:37:43.479Z",
        "departuretown": "string",
        "destinationtown": "string",
        "quantity": 0,
        "computer": true,
        "reserved": true,
        "restriction": "string",
        "document": true,
        "status": "ENABLED",
        "cni": "string",
        "ticket": "string",
        "covidtest": "string",
        "price": 0,
        "validation": true,
        "userDto": {
          "id": announcementUserDto,
          "firstName": "string",
          "lastName": "string",
          "profileimgage": "string",
          "pseudo": "string",
          "email": "string",
          "phone": "string",
          "roleDtos": [
            {
              "id": 0,
              "name": "string"
            }
          ],
          "password": "string",
          "status": "ENABLED",
          "stars": 0
        }
      },
      "status": "ENABLED"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Fluttertoast.showToast(
          msg: "Envoyé",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
      Navigator.pop(context);
    }
    else {
      final error = await response.stream.bytesToString();
      Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }

  }

  void launchNotation(String noteController, String annId) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}announcement/point?point=$noteController&announcementId=$annId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Fluttertoast.showToast(
          msg: '👍',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.white70,
          textColor: Colors.white,
          fontSize: 80.0
      );
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: const MyReservations(), duration: const Duration(milliseconds: 300)),
      );
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
