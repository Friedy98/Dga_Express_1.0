import 'dart:convert';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/Another_animation.dart';
import 'package:smart_shop/screens/Services/updateAnnouncement.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Announcements.dart';
import 'package:http/http.dart' as http;
import 'dart:io' as plateform;

import '../../Screens/Login/login.dart';
import '../../Screens/Services/delayed_animation.dart';
import '../../Screens/subinformation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../PopupWidget/PopupDelete.dart';
import '../mainhome/mainhome.dart';
import 'createAnnouncement.dart';
import 'finishAnnReview.dart';

class MyTravels extends StatefulWidget {
  static const String routeName = 'MyTravels';
  const MyTravels({Key? key}) : super(key: key);

  @override
  MyTravelsState createState() => MyTravelsState();
}

class MyTravelsState extends State<MyTravels> {

  bool showbackArrow = true;
  bool authorized = false;
  bool unauthorized = false;
  final storage = const FlutterSecureStorage();
  List<Announcements>? announcement;
  bool isLoaded = false;
  bool isLoaded2 = false;
  bool actionBtn = true;
  String departureDate = "";
  String arrivaldate = "";
  String currency = "";
  List<Subinformation>? subinformations;

  String myid = "";

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final profileData = await storage.read(key: 'Profile');

    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      setState(() {
        myid = json.decode(profileData!)["id"];
      });

      announcement = await getMyTravels(myid);
      announcement!.reversed;
      if (announcement!.isNotEmpty) {
        setState(() {
          isLoaded = !isLoaded;
        });
      }else{
        setState(() {
          isLoaded2 = !isLoaded2;
        });
      }
    }
  }

  Future getsubInfo()async{

    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}sub/informations/view'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List myresults = json.decode(data);

      return myresults.map((data) => Subinformation.fromJson(data)).toList();

    }else if(response.stream == 403){

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
      print(response.reasonPhrase);
    }
  }

  Future getMyTravels(String id) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}users/$id/announcements'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List myresults = json.decode(data);
      await storage.write(key: 'TotalAnnouncements', value: myresults.length.toString());
      //print(myresults.length.toString());

      return myresults.map((data) => Announcements.fromJson(data)).toList();

    }else if(response.statusCode == 403){
      await response.stream.bytesToString();

      MotionToast.warning(
          description:  Text("Session expiré!", style: FontStyles.montserratRegular17().copyWith(
              color: Colors.black))
      ).show(context);

      await storage.delete(key: "accesstoken");
      await storage.delete(key: "email");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const login()));
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: AppBar(
        title: const Text('Mes Voyages'),
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
        actions: [
          IconButton(
            onPressed: (){

              Navigator.push(
                context,
                PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 500),
                    child: const CreateAnnouncement()),
              );

            },
            icon: const Icon(Icons.add_circle_rounded),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          Visibility(
              visible: isLoaded,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: announcement?.length,
                  itemBuilder: (context, index){

                    return AnotherDelayedAnimation(delay: 300,
                    child:Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0x00eff2f7), Colors.white],
                        ),
                        border: Border.all(width: 2, color: const Color(0xBDA8A8AC)),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: const EdgeInsets.all(4),
                      child: DelayedAnimation(delay: 500,
                    child:Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 15.w),
                              if(!announcement![index].validation)...[
                                Row(
                                  children: const[
                                    Icon(Icons.pending_actions_rounded, color: Colors.grey,),
                                    Text(' En attente...')
                                  ],
                                )
                              ]else...[
                                const Icon(Icons.check_circle_rounded, color: Colors.green)
                              ],
                               if(!announcement![index].reserved)...[
                                   PopupMenuButton(
                                     // add icon, by default "3 dot" icon
                                       shape: RoundedRectangleBorder(
                                           borderRadius: BorderRadius.circular(20)
                                               .copyWith(topRight: const Radius.circular(0))),
                                       // add icon, by default "3 dot" icon
                                       child: Container(
                                         alignment: Alignment.center,
                                         height: 30,
                                         width: 45,
                                         margin: const EdgeInsets.all(2),
                                         decoration: const BoxDecoration(
                                             boxShadow: [BoxShadow(blurRadius: 4, color: Colors.orange)],
                                             color: Colors.white,
                                             shape: BoxShape.circle),
                                         child: const Icon(
                                           Icons.more_vert,
                                           color: Colors.black,
                                         ),
                                       ),
                                       itemBuilder: (context){
                                         return [
                                           PopupMenuItem<int>(
                                             value: 0,
                                             child: Row(
                                               children: const [
                                                 Icon(Icons.update,color: Colors.orange),
                                                 Text(" Modifier"),
                                               ],
                                             ),
                                           ),

                                           PopupMenuItem<int>(
                                             value: 1,
                                             child: Row(
                                               children: const [
                                                 Icon(Icons.delete, color: Colors.red),
                                                 Text(" Suprimer"),
                                               ],
                                             ),
                                           ),
                                         ];
                                       },
                                       onSelected:(value)async{
                                         if(value == 0){
                                           await storage.write(key: 'announcementId', value: announcement![index].id.toString());
                                           await storage.write(key: "quantity", value: announcement![index].quantity.toString());
                                           await storage.write(key: "price", value: announcement![index].price.toString());
                                           await storage.write(key: "computer", value: announcement![index].computer.toString());
                                           await storage.write(key: "document", value: announcement![index].document.toString());
                                           Navigator.push(
                                             context,
                                             PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                                                 child: const updateAnnouncement()),
                                           );
                                         }else if(value == 1){
                                           await storage.write(key: 'announcementId', value: announcement![index].id.toString());
                                           showDialog(
                                               context: context,
                                               builder: (BuildContext context) => const PopupWidgetDelete());
                                         }
                                       }
                                   ),
                                ]
                               else...[
                                GestureDetector(
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
                                                    const Icon(Icons.warning_amber_rounded, size: 80,color: Colors.red),
                                                    RichText(
                                                      text: TextSpan(
                                                        style:DefaultTextStyle.of(context).style,
                                                        children: <TextSpan>[
                                                          TextSpan(text: "Désolé! Aucune Moddification authorisé! Bien vouloir ",
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                          TextSpan(text: "Contacter DGA",
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                                                          TextSpan(text: " pour plus d'information",
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                        ],

                                                      ),
                                                    ),
                                                    const Divider(
                                                      color: Colors.grey,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        TextButton(
                                                          onPressed: (){
                                                            _showWidgetContacter(context);
                                                          },
                                                          child: Text('Contacter',
                                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),),
                                                        TextButton(
                                                            onPressed: (){
                                                              Navigator.of(context, rootNavigator: true).pop();
                                                            },
                                                            child: Text('Annuler',
                                                                style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 30,
                                    width: 45,
                                    margin: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.orange)],
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),

                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 0.0.h, bottom: 10.h),
                                width: 80.0,
                                height: 80.0,
                                child: ProfilePicture(
                                    name: announcement![index].userDto.firstName,
                                    radius: 60,
                                    fontsize: 21,
                                    img: announcement![index].userDto.profileimgage != ""
                                        ? Domain.dgaExpressPort + announcement![index].userDto.profileimgage
                                        : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                ),
                              ),
                              const SizedBox(width: 15),
                              RichText(
                                text: TextSpan(
                                  style:DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(text: announcement![index].userDto.firstName.capitalize! + " " + announcement![index].userDto.lastName.capitalize!,
                                        style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    TextSpan(text: " \n ${
                                            announcement![index]
                                                .price
                                                .toString()
                                          } $currency /kg",
                                        style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                  ],

                                ),
                              ),
                            ],
                          ),
                          ListTile(
                            leading: const Icon(Icons.pin_drop, color: Colors.red),
                            title: Text(
                              "De",
                              overflow: TextOverflow.ellipsis,
                              style:
                              FontStyles.montserratRegular19().copyWith(
                                  color: Colors.red),
                            ),
                            subtitle: Text(
                              announcement![index].departuretown,
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
                              FontStyles.montserratRegular19().copyWith(
                                  color: Colors.red),
                            ),
                            subtitle: Text(
                              announcement![index].destinationtown,
                              overflow: TextOverflow.ellipsis,
                              style:
                              FontStyles.montserratRegular17().copyWith(
                                  color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange,
                                child: IconButton(
                                  onPressed: () async{

                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          var date = announcement![index].departuredate.toString();
                                          var dateParse = DateTime.parse(date);
                                          var formattedDate1 = "${dateParse.day} / ${dateParse.month} / ${dateParse.year}";

                                          var date2 = announcement![index].arrivaldate.toString();
                                          var dateParse2 = DateTime.parse(date2);
                                          var formattedDate2 = "${dateParse2.day} / ${dateParse2.month} / ${dateParse2.year}";

                                          return AlertDialog(
                                            scrollable: true,
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                            content: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: SizedBox(
                                                width: 300.0.w,
                                                child: Column(
                                                  children: [
                                                    if(announcement![index].departuredate != null)...[
                                                      ListTile(
                                                        leading: const Icon(Icons.calendar_today),
                                                        title: Text("Date de Dépar",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text(formattedDate1,
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      ),],
                                                    ListTile(
                                                      leading: const Icon(Icons.calendar_today),
                                                      title: Text("Date d'arriver",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(formattedDate2,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.location_pin, color: Colors.red),
                                                      title: Text("Ville de dépar",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].departuretown,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.location_pin,color: Colors.red),
                                                      title: Text("Ville d'arrivé",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].destinationtown,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    if(announcement![index].document)...[
                                                      ListTile(
                                                        leading: const Icon(Icons.mail_outline),
                                                        title: Text("Document",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("Oui",
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
                                                    if(announcement![index].computer)...[
                                                      ListTile(
                                                        leading: const Icon(Icons.laptop_mac),
                                                        title: Text("Pc",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("Oui",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      ),]else...[
                                                      ListTile(
                                                        leading: const Icon(Icons.laptop_mac),
                                                        title: Text("Computer",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("Non",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      )
                                                    ],
                                                    ListTile(
                                                      leading: const Icon(Icons.production_quantity_limits),
                                                      title: Text("Quantité",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].quantity.toString(),
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.attach_money_rounded),
                                                      title: Text("Prix par Kilo",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text("${
                                                          announcement![index]
                                                              .price
                                                              .toString()
                                                      } $currency",
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.insert_drive_file),
                                                      title: Text("Restriction",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].restriction,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.credit_card_sharp),
                                                      title: Text("Moyen de Paiement",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].paymentMethod,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context, rootNavigator: true).pop();
                                                      },
                                                      child: Container(
                                                          width: 120,
                                                          height: 35,
                                                          decoration: const BoxDecoration(
                                                              color: Colors.redAccent,
                                                              borderRadius: BorderRadius.all(Radius.circular(8.0))),
                                                          child:  Center(
                                                            child: Text('Fermer',
                                                                style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),

                                                          )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                  }, icon: const Icon(Icons.remove_red_eye_rounded, size: 25, color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 15.w),
                              if(!announcement![index].validation)...[
                                GestureDetector(
                                  onTap: (){
                                    storage.write(key: 'announcementId', value: announcement![index].id);

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const finishAnnReview(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white60,
                                      border: Border.all(
                                          color: Colors.blue,
                                          width: 2
                                      ),
                                      borderRadius: const BorderRadius.all(Radius.circular(15.0))
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.upload, color: Colors.blue),
                                        SizedBox(width: 5.w),
                                        Text("Ajouter un Fichier",
                                            style: FontStyles.montserratRegular14().copyWith(color: Colors.blue)),
                                      ]
                                    )
                                  )
                                )
                              ]
                            ]
                          )
                        ]
                      )
                    )));
                  }
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
                child: Text('Aucun Voyage trouvé',style:
                FontStyles.montserratRegular14().copyWith(color: Colors.grey),),
              )),
          SizedBox(height: 60.h),
        ],
      ),

    );
  }

  Future _showWidgetContacter(BuildContext context) {
    return showModalBottomSheet(
        //isScrollControlled: true,
        shape: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.white),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0.r),
              topRight: Radius.circular(20.0.r),
            )),
        context: context,
        builder: (_) {
          return Container(
            margin: const EdgeInsets.all(20.0),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20.0.r),
                  topLeft: Radius.circular(20.0.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 10.0.h,
                    width: 100.0.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0.r),
                      color: AppColors.lightGray,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.clear, size: 25,))
                        ],
                      ),
                      Center(
                        child: Text(
                          "Nous Contacter",
                          style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text("Douala", style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                        subtitle: Text("+237 682774250", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onTap: (){
                          FlutterClipboard.copy(
                              "+237 682774250").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard",
                                  toastLength: Toast
                                      .LENGTH_SHORT,
                                  gravity: ToastGravity
                                      .BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors
                                      .grey,
                                  textColor: Colors
                                      .white,
                                  fontSize: 20.0
                              ));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text("Yaoundé", style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                        subtitle: Text("+237 675851499", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onTap: (){
                          FlutterClipboard.copy(
                              "+237 675851499").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard",
                                  toastLength: Toast
                                      .LENGTH_SHORT,
                                  gravity: ToastGravity
                                      .BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors
                                      .grey,
                                  textColor: Colors
                                      .white,
                                  fontSize: 20.0
                              ));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text("Bruxelle", style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                        subtitle: Text("+32 465860367", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onTap: (){
                          FlutterClipboard.copy(
                              "+32 465860367").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard",
                                  toastLength: Toast
                                      .LENGTH_SHORT,
                                  gravity: ToastGravity
                                      .BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors
                                      .grey,
                                  textColor: Colors
                                      .white,
                                  fontSize: 20.0
                              ));
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text("Namur", style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                        subtitle: Text("+32 465853983", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onTap: (){
                          FlutterClipboard.copy(
                              "+32 465853983").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Copied to clipboard",
                                  toastLength: Toast
                                      .LENGTH_SHORT,
                                  gravity: ToastGravity
                                      .BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors
                                      .grey,
                                  textColor: Colors
                                      .white,
                                  fontSize: 20.0
                              ));
                        },
                      ),
                      GestureDetector(
                        onTap: ()async{
                          final Uri _url = Uri.parse("https://contact@dga-express.com");
                          await launchUrl(_url);
                        },
                        child: ListTile(
                            leading: const Icon(Icons.mail),
                            title: Text("contact@dga-express.com",
                                overflow: TextOverflow.ellipsis,
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline))
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
