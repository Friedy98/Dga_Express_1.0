
import 'dart:convert';
import 'dart:io';

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
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Login/login.dart';
import 'package:smart_shop/screens/PopupWidget/PopupPassword.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';
import 'dart:io' as plateform;

import '../../Announcements.dart';
import '../../ListComments.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../PopupWidget/PopupUserUpdate.dart';
import 'package:http/http.dart' as http;

class MyProfile extends StatefulWidget {
  static const String routeName = 'MyProfile';
  const MyProfile({Key? key}) : super(key: key);

  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {

  final storage = const FlutterSecureStorage();

  bool showbackArrow = true;

  File? imageFile;
  final _picker = ImagePicker();

  pickImageFromGallery() async{
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        setProfileImage(imageFile);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  String currentUserid = "";
  String profileImg = "";
  String userId = "";
  String totalReservations = "";
  String totalAnnouncements = "";
  String totalPosts = "";
  String phone = "";
  int? level = 0;
  bool isLoaded = false;

  List<ListComments>? comments;
  List<Announcements>? announcement;

  Future <void> getUserData() async {
    final profileData = await storage.read(key: 'Profile');

    totalReservations = (await storage.read(key: 'ReservationTotal'))!;
    totalAnnouncements = (await storage.read(key: 'AnnouncementTotal'))!;
    totalPosts = (await storage.read(key: 'totalPosts'))!;

    setState(() {
      currentUserid = json.decode(profileData!)["id"];
      firstName = json.decode(profileData)['firstName'];
      lastName = json.decode(profileData)['lastName'];
      pseudo = json.decode(profileData)['pseudo'];
      email = json.decode(profileData)['email'];
      profileImg = json.decode(profileData)['profileimgage'];
      phone = json.decode(profileData)['phone'];
      level = json.decode(profileData)['level'];
    });
    announcement = await getMyTravels(currentUserid);
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

  void setProfileImage(File? imageFile) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.MultipartRequest(
        'PUT', Uri.parse('${Domain.dgaExpressPort}upload/profile/image'));
    request.files.add(await http.MultipartFile.fromPath('file',
        imageFile!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();

      Fluttertoast.showToast(
          msg: "✅ Photo de Profile miise à jour",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
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

  TextEditingController validationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mon Profile",
            overflow: TextOverflow.ellipsis,
            style:
            FontStyles.montserratRegular19().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        leadingWidth: 200.w,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.pushReplacementNamed(
                        context, mainhome.routeName);
                  },
                  icon: Icon(showbackArrow ? plateform.Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back : null,
                  ),)
            ],
          ),
        ),
        actions: [
          PopupMenuButton<String>(
              padding: const EdgeInsets.all(0),
              onSelected: (value) {
                debugPrint(value);
              },
              itemBuilder: (BuildContext contesxt) {
                return [
                  PopupMenuItem(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (
                                  BuildContext context) => const PopupWidgetUpdate());
                        },
                        child: ListTile(
                          leading: const Icon(Icons.edit_rounded),
                          title: Text('Modifier mon Compte',
                              style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                        )
                      )
                  ),
                  PopupMenuItem(
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pop(context);
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
                                              children: <TextSpan>[
                                                TextSpan(text: "Vous allez suprimer définitivement votre compte",
                                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                                                TextSpan(text: "\nCette action est irreversible...Voulez vous vraiment proceder?",
                                                    style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                              ],

                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          const Divider(color: Colors.grey),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                  child: Text('Annuler',
                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),
                                                  onTap: (){
                                                    Navigator.of(context, rootNavigator: true).pop();
                                                  }
                                              ),
                                              GestureDetector(
                                                  child: Text('Confirmer',
                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),
                                                  onTap: (){
                                                    deleteUser(currentUserid);
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
                        child: ListTile(
                          leading: const Icon(Icons.delete_rounded),
                          title: Text('Suprimer mon Compte',
                              style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                        )
                      )
                  )
                ];
              }
          ),
        ],
      ),
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
          child: Container(
            child: DelayedAnimation(delay: 300,
                child: _buildBody(context)
            )
          ),
        ),
      backgroundColor: Colors.white70,
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
              child: Text("Pas de messages",
                  style: FontStyles.montserratRegular14().copyWith(color: Colors.black45)
              )
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SafeArea(
      child: Column(
          children: [
            Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 3.0.w, right: 3.w),
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
                        alignment: const Alignment(0.0, 10),
                        child: CircleAvatar(
                          backgroundColor: AppColors.whiteLight,
                          radius: 106,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const SizedBox(height: 10),
                              GestureDetector(
                                child:  profileImg != "" ? ProfilePicture(
                                  img: '${Domain.dgaExpressPort}$profileImg',
                                  name: pseudo,
                                  fontsize: 21,
                                  radius: 100,
                                ) : const Icon(Icons.add_a_photo_rounded, color: Colors.grey,size: 80),
                                onTap: (){
                                  setState(() {
                                    pickImageFromGallery();
                                  });
                                },
                              )
                            ],
                          ),
                        )
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_pin),
                const SizedBox(width: 10),
                Text(
                    firstName + " " + lastName
                    , style: FontStyles.montserratRegular25().copyWith(
                    color: Colors.blue, fontWeight: FontWeight.bold)
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
                    , style: FontStyles.montserratRegular19().copyWith(
                    color: Colors.black)
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mail_rounded),
                const SizedBox(width: 10),
                Text(
                    email
                    , style: FontStyles.montserratRegular19().copyWith(
                    color: Colors.black)
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 10),
                Text("Tel: " + phone
                    , style: FontStyles.montserratRegular19().copyWith(
                        color: Colors.black)
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_rounded),
                const SizedBox(width: 10),
                Text(
                    "Mot de Pass: **********"
                    , style: FontStyles.montserratRegular19().copyWith(
                    color: Colors.black)
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RaisedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (
                            BuildContext context) => const PopupWidgetPassword());
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.deepOrange, Colors.orangeAccent]
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 200.0.w, maxHeight: 40.0.h,),
                      alignment: Alignment.center,
                      child: Text(
                          "Mot de Pass",
                          style: FontStyles.montserratRegular19().copyWith(
                              color: Colors.white)
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 220.0.w,
                      child: TextFormField(
                        controller: validationController,
                        focusNode: FocusNode(),
                        autofocus: false,
                        decoration: const InputDecoration(
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius
                              .only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10)
                          )),
                          filled: true,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        getTransactioncode(validationController.text);
                      },
                      child: Container(
                        width: 35.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: Colors.blue
                        ),
                        child: const Icon(
                              Icons.check_rounded, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                ProfilePicture(
                                    name: announcement![index].userDto.firstName,
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

  Widget _buildCard() {
    return Container(
        margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 15.0.h),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Statistiques",
                    style: FontStyles.montserratRegular25().copyWith(
                        color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Column(
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
                        child: Text(totalAnnouncements,
                            style: FontStyles.montserratRegular25().copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Voyages",
                        style: FontStyles.montserratRegular17().copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold))
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
                        child: Text(totalReservations,
                            style: FontStyles.montserratRegular25().copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Reservations",
                        style: FontStyles.montserratRegular17().copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold))
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
                        child: Text(totalPosts,
                            style: FontStyles.montserratRegular25().copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text("Ventes",
                        style: FontStyles.montserratRegular17().copyWith(
                            color: Colors.black, fontWeight: FontWeight.bold))
                  ],
                ),
              ],
            ),
          ],
        )
    );
  }

  void getTransactioncode(String code) async {
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/transaction/$code'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();

      MotionToast(
        animationCurve: Curves.ease,
        padding: const EdgeInsets.all(15),
        title: Text("Transaction Complète!", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        description: Text("Votre Transaction est complète! Vous allez recevoir votre paiement dans 24hours!", style: FontStyles.montserratRegular14().copyWith(
            color: Colors.white)),
        enableAnimation: true,
        animationType: AnimationType.fromLeft,
        position: MotionToastPosition.center,
        primaryColor: Colors.blueAccent,
        width: double.infinity,
        height: 120.h,
        icon: Icons.check_circle_outline,
        iconSize: 30,
      ).show(context);

      validationController.clear();
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
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

  void deleteUser(String id) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var request = http.Request('DELETE', Uri.parse('${Domain.dgaExpressPort}delete/user/$id/users'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      Fluttertoast.showToast(
          msg: "Deleted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0
      );

      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
            child: const login()),
      );

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
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
}

