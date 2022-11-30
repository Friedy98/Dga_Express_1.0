
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_7.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:smart_shop/ListComments.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'dart:io' as plateform;

import '../../Announcements.dart';
import '../../Common/Widgets/custom_app_bar.dart';
import '../../Screens/Services/AllAnnouncements.dart';
import '../../Screens/Services/delayed_animation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../ListArticles.dart';
import '../ListReservations.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  static const String routeName = 'profile';
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{

  final storage = const FlutterSecureStorage();

  bool showbackArrow = true;
  bool isLoading = false;
  bool password = true;
  bool editBtn = true;
  bool inutile = false;
  bool commentBtn = false;

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  int? level = 0;
  String currentUserid = "";
  String profileImg = "";
  String userId = "";
  String totalReservations = "";
  String totalAnnouncements = "";
  String hisprofileImage = "";
  String totalPosts = "";

  List<ListComments>? comments;
  List<Announcements>? announcement;
  bool isLoaded = false;
  bool listAnnouncements = false;
  var someCapitalizedString = "someString".capitalize!;

  Future <void> getUserData() async {
    final userData = await storage.read(key: 'hisData');
    password = false;
    editBtn = false;
    inutile = true;
    commentBtn = true;

    if(mounted){
      setState(() {
        userId = json.decode(userData!)['id'];
        firstName = json.decode(userData)['firstName'];
        lastName = json.decode(userData)['lastName'];
        pseudo = json.decode(userData)['pseudo'];
        email = json.decode(userData)['email'];
        hisprofileImage = json.decode(userData)['profileimgage'];
        level = json.decode(userData)['level'];
        getAnnouncementbyId(userId);
        getReservationbyId(userId);
        getmyArticles(userId);
      });
    }
    announcement = await getMyTravels(userId);

    if(announcement != null) {
      for(var i in announcement!){
        comments = await getComments(i.id);
        if (comments!.isNotEmpty) {
          setState(() {
            isLoaded = true;
            comments?.reversed;
          });
        }
      }
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
      Fluttertoast.showToast(
          msg: "Session expired!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.deepOrange,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }

  Future getComments(String id)async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/comments/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List myComments = json.decode(data);

      return myComments.map((data) => ListComments.fromJson(data)).toList();
    }
    else {
    print(response.reasonPhrase);
    }
  }

  Future <void> getAnnouncementbyId(String id) async{

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

      List announcementsTotal = json.decode(data);
      setState(() {
        totalAnnouncements = announcementsTotal.length.toString();
      });

    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future getmyArticles(String userId) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/$userId/articles/'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List results = json.decode(data);
      totalPosts = results.length.toString();
      await storage.write(key: 'totalPosts', value: totalPosts);
      return results.map((data) => ListArticles.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future getReservationbyId(String id)async{
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

      List myreservation = json.decode(data);
      //print(data);
      setState(() {
        totalReservations = myreservation.length.toString();
      });

      return myreservation.map((data) => ListReservation.fromJson(data)).toList();

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
      key: _key,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xF5E8E8FF),
                AppColors.whiteLight,
              ],
            ),
          ),
          child: DelayedAnimation(delay: 300,
              child: _buildBody(context)
          )
        ),
      backgroundColor: Colors.white70,
    );
    }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
      Size(double.infinity, MediaQuery
          .of(context)
          .size
          .height * .08),
      child: CustomAppBar(
          scaffoldKey: _key,
          isHome: false,
          // fixedHeight: 50.0,
          enableSearchField: false,
          leadingIcon: showbackArrow ? plateform.Platform.isIOS
              ? Icons.arrow_back_ios
              : Icons.arrow_back : null,
          leadingOnTap: () {
            setState(() {
              //Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const My_Posts(),
                ),
              );
            });
          },
          title: 'Profile d\'utilisateur'),
    );
  }

    Widget _buildBody(BuildContext context){
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfile(),
              const SizedBox(height: 15),
              const Divider(color: Colors.black),
              const SizedBox(height: 15),
              _buildCard(),
              const SizedBox(height: 15),
              const Divider(color: Colors.black),
              const SizedBox(height: 15),
              Center(
                child: Text("Messages",
                    style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              isLoaded ? _buildComment() : Center(
                  child: Text("pas de messages",
                      style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)
                  )
              ),
              const SizedBox(height: 30),
            ],
          )
        );
    }

    Widget _buildProfile(){
      return SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 8.0.w, right: 8.w),
                decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('assets/images/Final logo dga sans fond.png'),
                      fit: BoxFit.fill
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.white, Colors.lightBlueAccent],
                  ),
                  border: Border.all(width: 2, color: Colors.white24),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 200.h,
                  child: Container(
                      alignment: plateform.Platform.isIOS ? const Alignment(0.0, 13) : const Alignment(0.0, 17),
                      child: CircleAvatar(
                        backgroundColor: AppColors.whiteLight,
                        radius: 106,
                        child: ProfilePicture(
                          name: firstName,
                          radius: 100,
                          fontsize: 21,
                          img: hisprofileImage != "" ?
                            '${Domain.dgaExpressPort}$hisprofileImage'
                                : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                        ),
                      )
                  ),
                ),
              ),
              SizedBox(
                height: 80.0.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_pin),
                  const SizedBox(width: 10),
                  Text(
                      firstName + " " + lastName
                      ,style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person),
                  const SizedBox(width: 10),
                  Text(
                      "@" + pseudo
                      ,style: FontStyles.montserratRegular19().copyWith(color: Colors.black)
                  ),
                ],
              ),
            ],
          ),
      );
    }

    Widget _buildCard(){
      return Container(
          margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 8.0.h),
        child: Column(
          children: [
            Center(
                child: Text("Statistiques",
                    style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold))
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.red,
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white,
                    child: Text("$level",
                        style: FontStyles.montserratRegular25().copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Text("Note / 10",
                    style: FontStyles.montserratRegular17().copyWith(
                        color: Colors.red, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.lightBlueAccent,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child:Text(totalAnnouncements, style: FontStyles.montserratRegular25().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Voyages",style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.lightBlueAccent,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child:Text(totalReservations, style: FontStyles.montserratRegular25().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Reservations",style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.lightBlueAccent,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child:Text(totalPosts, style: FontStyles.montserratRegular25().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Ventes",style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
          ],
        )
      );
  }

  Widget _buildComment(){
    return Container(
      margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 15.0.h, bottom: 25.h),
      child: SizedBox(
        height: 300.h,
        child: Column(
          children: [
            Visibility(
                visible: isLoaded,
                child: Expanded(
                  child: ListView.builder(
                    itemCount: comments?.length,
                    itemBuilder: (context, index){
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ProfilePicture(
                                    name: comments![index].booker.pseudo,
                                    radius: 30,
                                    fontsize: 21,
                                    img: comments![index].booker.profileimgage != "" ?
                                    '${Domain.dgaExpressPort}${comments![index].booker.profileimgage}'
                                        : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                ),

                                const SizedBox(width: 10),
                                Text(comments![index].booker.firstName.capitalize! + " " + comments![index].booker.lastName.capitalize!,
                                    style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold))
                              ],
                            ),
                            ChatBubble(
                              clipper: ChatBubbleClipper7(
                                  type: BubbleType.receiverBubble),
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(
                                  top: 5),
                              backGroundColor: Colors.blue,
                              child: Text(
                                  comments![index].content,
                                  style: FontStyles
                                      .montserratRegular17()
                                      .copyWith(
                                      color: Colors.white)),
                            ),
                            const SizedBox(height: 10),
                            const Divider(color: Colors.black),
                            const SizedBox(height: 10),
                          ],
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
          ],
        ),
      )
    );
  }
}

