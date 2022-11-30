
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import '../../Announcements.dart';
import '../../Common/Widgets/custom_app_bar.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Utils/font_styles.dart';
import '../Screens/ListReservations.dart';
import '../Screens/Profile/profile.dart';
import '../main.dart';
import 'PopupWidget/Popup.dart';
import 'PopupWidget/PopupLogin.dart';
import 'PopupWidget/popupSearchError.dart';
import 'Services/AllAnnouncements.dart';

class SearchPage extends StatefulWidget {
  static const String routeName = 'SearchPage';
  const SearchPage({Key? key}) : super(key: key);

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {

  List<Announcements>? announcement;
  List<ListReservation>? reservation;
  List stars = [];
  bool isLoaded = false;
  bool isLoaded2 = false;
  bool showbackArrow = true;
  String currentUserId = "";

  final storage = const FlutterSecureStorage();
  bool searchresults = false;

  var someCapitalizedString = "someString".capitalize!;

  String departureTown = "";
  String destinationTown = "";

  @override
  void initState(){
    super.initState();
    getAnnouncementData();
  }

  void getAnnouncementData()async{
    departureTown = (await storage.read(key: "departure"))!;
    destinationTown = (await storage.read(key: "ddestination"))!;
    final profileData = await storage.read(key: 'Profile');
    if(profileData != null){
      setState(() {
        currentUserId = json.decode(profileData)['id'];
      });
    }

    announcement = await searchAnnouncements(departureTown, destinationTown);
    if(announcement != null){
      setState(() {
        isLoaded = true;
      });
    }else{
      isLoaded2 = true;
    }
  }

  Future searchAnnouncements(String departure, String destination) async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}search/$departure/$destination/announcements'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List results = json.decode(data);
      //print(results);
      if(results.isEmpty){
        showDialog(
            context: context,
            builder: (BuildContext context) => const PopupWidgetSearchError());
      }

      return results.map((data) => Announcements.fromJson(data)).toList();

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: _buildCustomAppBar(context),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.orange,
            width: double.infinity,
            height: 60.h,
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Resultat de $departureTown à $destinationTown",style:
                FontStyles.montserratRegular17().copyWith(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Visibility(
              visible: isLoaded,
              child: Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: announcement?.length,
                  itemBuilder: (context, index){

                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xEFF2F7), Colors.white],
                        ),
                        border: Border.all(width: 2, color: Color(0xBDA8A8AC)),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                      margin: const EdgeInsets.all(4),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 10.w),
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.orange,
                                child: IconButton(
                                  onPressed: ()async{
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
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
                                                    ListTile(
                                                      leading: const Icon(Icons.calendar_today),
                                                      title: Text("Departure Date",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].departuredate.toString(),
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.calendar_today),
                                                      title: Text("Arrival Date",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].arrivaldate.toString(),
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.location_pin, color: Colors.red),
                                                      title: Text("Departure Town",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].departuretown,
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.location_pin,color: Colors.red),
                                                      title: Text("Arrival Town",style:
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
                                                        subtitle: Text("Yes",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      ),]else...[
                                                      ListTile(
                                                        leading: const Icon(Icons.mail_outline),
                                                        title: Text("Document",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("No",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      )
                                                    ],
                                                    if(announcement![index].computer)...[
                                                      ListTile(
                                                        leading: const Icon(Icons.laptop_mac),
                                                        title: Text("Computer",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("Yes",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      ),]else...[
                                                      ListTile(
                                                        leading: const Icon(Icons.laptop_mac),
                                                        title: Text("Computer",style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                        subtitle: Text("No",
                                                          style:
                                                          FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                        ),
                                                      )
                                                    ],
                                                    ListTile(
                                                      leading: const Icon(Icons.production_quantity_limits),
                                                      title: Text("Quantity",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].quantity.toString(),
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.price_check_sharp),
                                                      title: Text("Price per Kilo",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].price.toString(),
                                                        style:
                                                        FontStyles.montserratRegular14().copyWith(color: Colors.black),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(Icons.price_check_sharp),
                                                      title: Text("Restriction",style:
                                                      FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                                                      subtitle: Text(announcement![index].restriction,
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
                                  },
                                  icon: const Icon(Icons.remove_red_eye, size: 25,color: Colors.white),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              if(currentUserId != announcement![index].userDto.id)...[
                                GestureDetector(
                                  onTap: ()async{

                                    gethisUserDto(announcement![index].userDto.id);

                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 0.0.h, bottom: 10.h),
                                    width: 80.0,
                                    height: 80.0,
                                    child: ProfilePicture(
                                        name: announcement![index].userDto.firstName,
                                        radius: 50,
                                        fontsize: 21,
                                        img: announcement![index].userDto.profileimgage != "" ?
                                        Domain.dgaExpressPort + announcement![index].userDto.profileimgage
                                            : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                    ),
                                  ),
                                ),
                              ]else...[
                                Container(
                                  margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 0.0.h, bottom: 10.h),
                                  width: 80.0,
                                  height: 80.0,
                                  child: ProfilePicture(
                                      name: announcement![index].userDto.firstName,
                                      radius: 50,
                                      fontsize: 21,
                                      img: announcement![index].userDto.profileimgage != "" ?
                                      Domain.dgaExpressPort + announcement![index].userDto.profileimgage
                                          : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                  ),
                                ),
                              ],
                              const SizedBox(width: 15),
                              RichText(
                                text: TextSpan(
                                  style:DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(text: announcement![index].userDto.firstName.capitalize! + " " + announcement![index].userDto.lastName.capitalize!,
                                        style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    TextSpan(text: " \n" + announcement![index].price.toString() + "€ /kg",
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
                        ],
                      ),
                    );
                  },
                ),
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
                child: Text('Pas de Resultat',style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black12),),
              ))
        ],
      ),
    );
  }

  PreferredSize _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
      Size(double.infinity, MediaQuery
          .of(context)
          .size
          .height * .07),
      child: CustomAppBar(
          isHome: false,
          enableSearchField: false,
          leadingIcon: showbackArrow ? plateform.Platform.isIOS
              ? Icons.arrow_back_ios
              : Icons.arrow_back : null,
          leadingOnTap: () {
            setState(() {
              Navigator.push(
                context,
                PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                    child: const My_Posts()),
              );
            });
          },
          title: 'All Travels'
      ),
    );
  }

  bool isValidForm = false;

  void gethisUserDto(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}users/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      Map<String, dynamic> userDto = json.decode(data);
      //print(senderDto["userDto"]);
      await storage.write(key: 'hisData', value: data);
      Navigator.pushReplacementNamed(context, Profile.routeName);

    }else if(response.statusCode == 403){
      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidgetLogin());
    }
    else {
      debugPrint(response.reasonPhrase);
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

      final announcementId = await response.stream.bytesToString();

      await storage.write(key: 'AnnouncementId', value: announcementId);

      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidget());
    }else if(response.statusCode == 403){
      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidgetLogin());
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }
}
