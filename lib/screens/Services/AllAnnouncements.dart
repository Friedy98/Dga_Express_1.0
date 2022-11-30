
import 'dart:convert';

import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Profile/profile.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';

import '../../Announcements.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Screens/subinformation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../PopupWidget/Popup.dart';
import '../PopupWidget/PopupLogin.dart';
import '../SearchPage.dart';

class My_Posts extends StatefulWidget {
  static const String routeName = 'My_Posts';
  const My_Posts({Key? key}) : super(key: key);

  @override
  My_PostsState createState() => My_PostsState();
}

class My_PostsState extends State<My_Posts> {

  List<Announcements>? announcement;
  List profileimages = [];
  var isLoaded = false;
  bool isnotLoaded = false;
  bool showbackArrow = true;
  final storage = const FlutterSecureStorage();
  String ownerId = "";
  var someCapitalizedString = "someString".capitalize!;
  String currentUserId = "";
  bool searchtown = false;
  String countryValue = "";
  String countryValue2 = "";
  String stateValue = "";
  String stateValue2 = "";
  String cityValue = "";
  String currency = "";
  List searchResults = [];
  List<Subinformation>? subinformations;

  String prodfilepicture = "";
  @override
  void initState(){
    super.initState();
    getAnnouncementData();
  }

  String picture = "";
  bool notify = true;

  void getAnnouncementData()async{
    final profileData = await storage.read(key: 'Profile');
    announcement = await getAllAnnouncements();
    if(profileData != null){
      currentUserId = json.decode(profileData)["id"];
    }

    announcement?.reversed;
    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      if (mounted && announcement != null) {
        if (announcement!.isNotEmpty) {
          setState(() {
            isLoaded = !isLoaded;
          });
        } else {
          setState(() {
            isnotLoaded = !isnotLoaded;
          });
        }
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

    }
    else {
      print(response.reasonPhrase);
    }
  }

  TextEditingController departure = TextEditingController();
  TextEditingController destination = TextEditingController();
  TextEditingController searchController = TextEditingController();

  void filterSearchResults(String query) {
    List dummySearchList = [];
    dummySearchList.addAll(announcement!);
    if(query.isNotEmpty) {
      List dummyListData = [];
      for (var item in dummySearchList) {
        if(item.contains(query)) {
          dummyListData.add(item);
          setState(() {
            announcement!.clear();
            searchResults.add(dummyListData);
            print(searchResults);
          });
        }
      }
      return;
    } else {
      setState(() {
        announcement!.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: PreferredSize(
          preferredSize:
          Size(double.infinity, MediaQuery.of(context).size.height * .06),
          child: AppBar(
            title:Center(
              child: Text('Voyages disponible',
                  overflow: TextOverflow.ellipsis,
                  style:
                  FontStyles.montserratRegular19().copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
            ) ,
            //leadingWidth: 200.w,
            leading: IconButton(
                onPressed: (){
                  Navigator.pushReplacementNamed(context, mainhome.routeName);
                },
                icon: Icon(showbackArrow ? plateform.Platform.isIOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back : null,
                )
            ),
            actions: [
              !searchtown ? IconButton(
                  onPressed: (){
                    setState(() {
                      searchtown = !searchtown;
                    });
                  },
                  icon:  const Icon(Icons.search_rounded)) :
                  IconButton(
                    onPressed: (){
                      setState(() {
                        searchtown = !searchtown;
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
              const SizedBox(width: 20)
            ],
          )
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /*Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              controller: searchController,
              decoration: const InputDecoration(
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)))),
            ),
          ),*/
          Container(
            color: Colors.black12,
            child: Visibility(
                visible:  searchtown,
                child: DelayedAnimation(delay: 300,
                    child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 5.h),
                    Container(
                      margin: EdgeInsets.only(left: 15.0.w, right: 15.w, top: 2.0.h, bottom: 2.h),
                      child: TextFormField(
                        controller: departure,
                        autofocus: false,
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
                                              departure.text = value + ", " + countryValue;
                                            });
                                            Navigator.pop(context);
                                          }
                                        },
                                      ),
                                    )
                                );
                              });
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'ville de dépar',
                          suffixIcon: const Icon(Icons.pin_drop),
                        ),
                        validator: (inputValue){
                          if(inputValue!.isEmpty ) {
                            return "field Required!";
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      margin: EdgeInsets.only(left: 15.0.w, right: 15.w, top: 2.0.h, bottom: 2.h),
                      child: TextFormField(
                        controller: destination,
                        autofocus: false,
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
                                        onCityChanged:(value) async{
                                          if(value != null) {
                                            setState(() {
                                              destination.text = value + ", " + countryValue2;
                                            });
                                            Navigator.pop(context);
                                            if(departure.text != "" && destination.text != ""){
                                              await storage.write(key: "departure", value: departure.text);
                                              await storage.write(key: "ddestination", value: destination.text);
                                              Navigator.push(
                                                context,
                                                PageTransition(type: PageTransitionType.fade, child: const SearchPage()),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    )
                                );
                              });
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                          hintText: 'ville d\'arrivé',
                          suffixIcon: const Icon(Icons.pin_drop),
                        ),
                        validator: (inputValue){
                          if(inputValue!.isEmpty ) {
                            return "field Required!";
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ))
            )
          ),
          Visibility(
              visible: isLoaded,
              child: Expanded(
                child: DelayedAnimation(delay: 500,
                    child:
                    ListView.builder(
                  itemCount: announcement?.length,
                  itemBuilder: (context, index){
                    return Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0x00eff2f7), Colors.white],
                        ),
                        border: Border.all(width: 3, color: const Color(0xBDA8A8AC)),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: const EdgeInsets.all(5),
                      margin: EdgeInsets.only(left: 15.0.w, right: 15.w, top: 5.0.h, bottom: 5.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    await storage.write(key: 'ownerId', value: announcement![index].userDto.id);
                                    await storage.write(key: 'currency', value: currency);
                                    getAnnouncementById(announcement![index].id.toString());
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
                                        '${Domain.dgaExpressPort}' + announcement![index].userDto.profileimgage
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
                                        '${Domain.dgaExpressPort}' + announcement![index].userDto.profileimgage
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
                        ],
                      ),
                    );
                  },
                )),
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
              visible: isnotLoaded,
              child: Center(
                child: Text('Pas de voyage disponible',style:
                FontStyles.montserratRegular14().copyWith(color: Colors.grey),),
              )
          )
        ],
      )
    );
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
      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidget());
      final announcementId = await response.stream.bytesToString();

      await storage.write(key: 'AnnouncementId', value: announcementId);
    }else if(response.statusCode == 403){
      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidgetLogin());
    }
    else {
      debugPrint(response.reasonPhrase);
    }
  }

   getAllAnnouncements() async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}announcements'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List results = json.decode(data);

      return results.map((data) => Announcements.fromJson(data)).toList();
    }
    else {
      debugPrint(response.reasonPhrase);
    }
  }

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

      //Map<String, dynamic> userDto = json.decode(data);
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
}
