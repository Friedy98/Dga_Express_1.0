import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Listmymessages.dart';
import '../../Screens/ListArticles.dart';
import '../../Screens/PopupWidget/PopupLogin.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../mainhome/Marketplace.dart';
import 'MessagesArticles.dart';

class MyMessages extends StatefulWidget {
  static const String routeName = 'MyMessages';
  const MyMessages({Key? key}) : super(key: key);

  @override
  MyMessagesState createState() => MyMessagesState();
}

class MyMessagesState extends State<MyMessages> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool showbackArrow = true;
  List messages = [];
  List<Listmymessages>? mymessages;
  List myresults = [];

  bool isLoaded = false;
  bool isLoaded2 = false;
  final storage = const FlutterSecureStorage();
  String myId = "";
  List<ListArticles>? myArticles;
  String userId = "";
  bool noresults = false;
  bool noToken = false;
  var popular = {};

  @override
  void initState(){
    super.initState();
    getUserData();
  }

  void getUserData() async {
    String? token = await storage.read(key: "accesstoken");

    final profileData = await storage.read(key: 'Profile');
    userId = json.decode(profileData!)['id'];
    if(mounted) {
      if(token != null) {
        mymessages = await getMyMessages();
        myArticles = await getmyArticles(userId);
        for(var i=0; i<mymessages!.length; i++){
          for(var j=0; j<myArticles!.length; j++){
            if(mymessages![i].articleDto!.id == myArticles![j].id){
              if(myresults.isEmpty) {
                myresults.add(mymessages![i].articleDto!.id);
                myresults.add(mymessages![i].sendermessage.id);
              }else{
                if(!myresults.contains(mymessages![i].articleDto!.id)){
                  myresults.add(mymessages![i].articleDto!.id);
                  myresults.add(mymessages![i].sendermessage.id);
                }
              }
              setState(() {
                isLoaded = true;
              });
            }
          }
        }
        } else {
        noToken = true;
        if (noToken) {
          showDialog(
              context: context,
              builder: (BuildContext context) => const PopupWidgetLogin());
        }
      }
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
      //print(data);
      return results.map((data) => ListArticles.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future getMyMessages()async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}current/user/messages'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List results = json.decode(data);
      print("Messages OK");

      return results.map((data) => Listmymessages.fromJson(data)).toList();
    }
    else {
      final data = await response.stream.bytesToString();
      print("Error is: " + json.decode(data)['error']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: const Text('Mes Messages'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
          onPressed: (){

            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                  child: const MarketPlace()),
            );

          },
        ),
      ),
      resizeToAvoidBottomInset: false,
      body:  _bodybuilder(context),
    );
  }

  Widget _bodybuilder(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
              visible: isLoaded,
              child: Expanded(
                child: ListView.builder(
                    itemCount: mymessages?.length,
                    itemBuilder: (context, index){
                      final String time = mymessages![index].date;
                      String thistime = "";
                      final List<String> splitDate = time.split(', ');
                      thistime = splitDate.last;

                      return Column(
                        children: [
                          for(var a in myresults)...[
                            if(a == mymessages![index].articleDto!.id)...[
                              Container(
                                  margin: const EdgeInsets.all(10.0),
                                  height: 160.h,
                                  //margin: EdgeInsets.only(left: 5.0.w, right: 5.w, top: 10.0.h, bottom: 15.h),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [Colors.black12, Colors.white54, Colors.black12],
                                    ),
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                    border: Border.all(
                                        color: Colors.grey,
                                        width: 2
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(thistime + "  ",
                                            style: FontStyles.montserratRegular14().copyWith(color: Colors.black87, fontWeight: FontWeight.bold)),
                                      ),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 10.w),
                                            CircleAvatar(
                                              radius: 33,
                                              backgroundColor: Colors.white,
                                              child: ProfilePicture(
                                                  name: mymessages![index].sendermessage.pseudo,
                                                  radius: 30,
                                                  fontsize: 21,
                                                  img: mymessages![index].sendermessage.profileimgage != "" ?
                                                  Domain.dgaExpressPort + mymessages![index].sendermessage.profileimgage
                                                      : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              text: TextSpan(
                                                style:DefaultTextStyle.of(context).style,
                                                children: <TextSpan>[
                                                  TextSpan(text: mymessages![index].sendermessage.firstName.capitalize! + " " + mymessages![index].sendermessage.lastName.capitalize!,
                                                      style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),

                                                ],
                                              ),
                                            ),
                                          ]
                                      ),
                                      SizedBox(height: 10.h),
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              CircleAvatar(
                                                radius: 33,
                                                backgroundColor: Colors.white,
                                                child: FloatingActionButton(
                                                  heroTag: null,
                                                  onPressed: ()async{
                                                    await storage.write(key: "articleName", value: mymessages![index].articleDto!.name);
                                                    await storage.write(key: "articleId", value: mymessages![index].articleDto!.id);
                                                    await storage.write(key: "articlePrice", value: mymessages![index].articleDto!.price.toString());
                                                    await storage.write(key: "articleImage", value: mymessages![index].articleDto!.mainImage);
                                                    await storage.write(key: "senderid", value: mymessages![index].sendermessage.id);
                                                    //await storage.write(key: "cathegoryId", value: mymessages![index].articleDto!.cathegory.id);

                                                    Navigator.pushReplacementNamed(
                                                        context, MessagesArticles.routeName);
                                                  },
                                                  backgroundColor: Colors.blue,
                                                  child: const Icon(Icons.chat, color: Colors.white
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                            ],
                                          ),
                                          Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [Colors.deepOrangeAccent, Colors.orangeAccent],
                                              ),
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15.0),
                                                  bottomRight: Radius.circular(15.0)
                                              ),
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            child: Text(mymessages![index].articleDto!.name,
                                                style: FontStyles.montserratRegular14().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                              )
                            ]
                          ]
                        ],
                      );
                    }
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
            visible: noresults,
            child: Center(
              child: Text("Pas de messages",
                  style: FontStyles.montserratRegular14().copyWith(color: Colors.grey)),
            ),
          ),
        ],
      );
  }
}