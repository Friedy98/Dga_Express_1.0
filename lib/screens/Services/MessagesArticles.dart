
import 'dart:convert';
import 'dart:core';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import '../../Listmymessages.dart';
import '../../Screens/Login/login.dart';
import '../../Screens/Profile/profile.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../PopupWidget/PopupLogin.dart';
import '../mainhome/Marketplace.dart';
import '../subinformation.dart';

class MessagesArticles extends StatefulWidget {
  static const String routeName = 'MessagesArticles';
  const MessagesArticles({Key? key}) : super(key: key);

  @override
  _MessagesArticlesState createState() => _MessagesArticlesState();
}

class _MessagesArticlesState extends State<MessagesArticles> {

  bool showbackArrow = true;

  final storage = const FlutterSecureStorage();

  @override
  void initState(){
    super.initState();
    getAnnDataReserve();
  }

  List<Listmymessages>? messages;
  var isLoaded = false;
  bool isfieldEmpty = true;

  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  String profileImage = "";
  String phone = "";
  String currentUserId = "";
  String reservationId = "";

  String travellerfirstName = "";
  String travellerlastName = "";
  String travellerpseudo = "";
  String travelleremail = "";
  String travellerId = "";
  String travellerphone = "";
  String travellerprofilepic = "";

  bool sendBtn = false;
  String mainImage = "";

  String articleName = "";
  String articleId = "";
  String articlePrice = "";
  String cathegoryId = "";
  String cathegoryadminId = "";
  String cathegoryadminFN = "";
  String cathegoryadminLN = "";
  String cathegoryadminPs = "";
  String cathegoryadminPP = "";
  String cathegoryadminEm = "";
  String cathegoryadminphone = "";
  String cathegoryName = "";
  String cathegoryDescription = "";
  String currency = "";
  List<Subinformation>? subinformations;
  List sentMessages = [];

  String subject = ""; //to show the subject conversation

  final _formKey = GlobalKey<FormState>();
  var someCapitalizedString = "someString".capitalize!;

  TextEditingController messageController = TextEditingController();
  final scrollcontroller = ScrollController(initialScrollOffset: 0);

  void  getAnnDataReserve() async {
    travellerId = (await storage.read(key: "senderid"))!;
    getUserById(travellerId);

      articleName = (await storage.read(key: "articleName"))!;
      articlePrice = (await storage.read(key: 'articlePrice'))!;
      mainImage = (await storage.read(key: "articleImage"))!;
      articleId = (await storage.read(key: "articleId"))!;
      //print(articleId);
      getarticleById(articleId);

    messages = await getMessages(travellerId);

    if(messages != null && messages!.isNotEmpty){
      setState(() {
        isLoaded = true;
      });
    }

    final profileData = await storage.read(key: 'Profile');
    if(mounted) {
      subinformations = (await getsubInfo()) as List<Subinformation>?;
      for(var i in subinformations!){
        setState(() {
          currency = i.currency;
        });
      }
      setState(() {
        firstName = json.decode(profileData!)['firstName'];
        lastName = json.decode(profileData)['lastName'];
        pseudo = json.decode(profileData)['pseudo'];
        email = json.decode(profileData)['email'];
        currentUserId = json.decode(profileData)['id'];
        profileImage = json.decode(profileData)['profileimgage'];
        phone = json.decode(profileData)['phone'];

      });
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

  void getUserById(String id) async{

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
      travellerlastName = json.decode(data)['lastName'];
      travellerfirstName = json.decode(data)['firstName'];
      travellerpseudo = json.decode(data)['pseudo'];
      travelleremail = json.decode(data)['email'];
      travellerphone = json.decode(data)['phone'];
      travellerprofilepic = json.decode(data)['profileimgage'];

    }
    else {
      debugPrint(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.whiteLight,
        key: _formKey,
        appBar:AppBar(
          title: Text(travellerfirstName.capitalize! + " " + travellerlastName.capitalize!,
              overflow: TextOverflow.ellipsis,
              style:
              FontStyles.montserratRegular19().copyWith(color: Colors.white)),
          leadingWidth: 200.w,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                          child: const MarketPlace()),
                    );
                  },
                  child: Icon(showbackArrow ? plateform.Platform.isIOS
                      ? Icons.arrow_back_ios
                      : Icons.arrow_back : null,
                  ),),
                const SizedBox(width: 10.0),
                ProfilePicture(
                    name: 'Aditya Dharmawan Saputra',
                    radius: 30,
                    fontsize: 21,
                    img: travellerprofilepic != ""
                        ? '${Domain.dgaExpressPort}' + travellerprofilepic
                        : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                ),

              ],
            ),
          ),
          /*actions: [
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
                            gethisUserDto(travellerId);
                          },
                          child: Text('View Contact',
                              style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                        )
                    )
                  ];
                }
            ),
          ],*/
        ),

        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            _buildArticle(),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 10.0.w, right: 10.w),
                child: Column(
                  children: [
                    Visibility(
                      visible: isLoaded,
                      child: Expanded(
                        child: ListView.builder(
                            controller: scrollcontroller,
                            itemCount: messages?.length,
                            itemBuilder: (context, index){
                              final String time = messages![index].date;
                              String thistime = "";
                              final List<String> splitDate = time.split('. ');
                              thistime = splitDate.last;
                              //var hour = thistime.split(":");
                              //var timehour = hour.first;
                              return Column(
                                children: [
                                  if(messages![index].sendermessage.id ==
                                      currentUserId)...[
                                        if(messages![index].articleDto!.name == articleName)...[
                                    ChatBubble(
                                      clipper: ChatBubbleClipper3(
                                          type: BubbleType.sendBubble),
                                      alignment: Alignment.topRight,
                                      margin: const EdgeInsets.only(
                                          top: 20),
                                      backGroundColor: Colors.blue,
                                      child: FocusedMenuHolder(
                                        blurSize: 5.0,
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
                                        onPressed: () {},
                                        menuItems: <FocusedMenuItem>[
                                          FocusedMenuItem(
                                              title: const Text("Copy"),
                                              trailingIcon: const Icon(
                                                  Icons.copy_outlined),
                                              onPressed: () {
                                                FlutterClipboard.copy(
                                                    messages![index]
                                                        .content).then((
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
                                              }),
                                          FocusedMenuItem(
                                              title: const Text("Delete"),
                                              trailingIcon: const Icon(
                                                  Icons.delete),
                                              onPressed: () {
                                                deleteMessage(
                                                    messages![index].id);
                                              }),
                                        ],
                                        child: RichText(
                                          text: TextSpan(
                                            style:DefaultTextStyle.of(context).style,
                                            children: <TextSpan>[
                                              TextSpan(text: messages![index].content,
                                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.white)),
                                                TextSpan(text: "  " + thistime,
                                                    style: FontStyles.montserratRegular14().copyWith(color: Colors.yellow)),
                                              ]
                                          ),
                                        ),

                                      ),
                                    ),
                                          for(var i =0; i<sentMessages.length; i++)...[
                                            ChatBubble(
                                              clipper: ChatBubbleClipper3(
                                                  type: BubbleType.sendBubble),
                                              alignment: Alignment.topRight,
                                              margin: const EdgeInsets.only(
                                                  top: 20),
                                              backGroundColor: Colors.blue,
                                              child: FocusedMenuHolder(
                                                blurSize: 5.0,
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
                                                onPressed: () {},
                                                menuItems: <FocusedMenuItem>[
                                                  FocusedMenuItem(
                                                      title: const Text("Copy"),
                                                      trailingIcon: const Icon(
                                                          Icons.copy_outlined),
                                                      onPressed: () {
                                                        FlutterClipboard.copy(
                                                            sentMessages[i]).then((
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
                                                      }),
                                                  FocusedMenuItem(
                                                      title: const Text("Delete"),
                                                      trailingIcon: const Icon(
                                                          Icons.delete),
                                                      onPressed: () {
                                                        sentMessages.remove(sentMessages[i]);
                                                      }),
                                                ],
                                                child: RichText(
                                                  text: TextSpan(
                                                    style:DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: sentMessages[i],
                                                          style: FontStyles.montserratRegular17().copyWith(color: Colors.white)),
                                                      TextSpan(text: "   " + thistime,
                                                          style: FontStyles.montserratRegular11().copyWith(color: Colors.yellow)),
                                                    ],

                                                  ),
                                                ),
                                              ),
                                            )
                                          ]
                                        ]
                                  ],
                                  if(messages![index].sendermessage.id ==
                                      travellerId)...[
                                      if(messages![index].articleDto!.name == articleName)...[
                                      ChatBubble(
                                        clipper: ChatBubbleClipper3(
                                            type: BubbleType.receiverBubble),
                                        alignment: Alignment.topLeft,
                                        margin: const EdgeInsets.only(
                                            top: 20),
                                        backGroundColor: Colors.white,
                                        child: FocusedMenuHolder(
                                          blurSize: 5.0,
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
                                          onPressed: () {},
                                          menuItems: <FocusedMenuItem>[
                                            FocusedMenuItem(
                                                title: const Text("Copy"),
                                                trailingIcon: const Icon(
                                                    Icons.file_copy_rounded),
                                                onPressed: () {
                                                  FlutterClipboard.copy(
                                                      messages![index]
                                                          .content).then((
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
                                                }),
                                          ],
                                          child: RichText(
                                                  text: TextSpan(
                                                    style:DefaultTextStyle.of(context).style,
                                                    children: <TextSpan>[
                                                      TextSpan(text: messages![index].content,
                                                          style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                      TextSpan(text: "  " + thistime,
                                                          style: FontStyles.montserratRegular14().copyWith(color: Colors.orange)),
                                                    ],

                                                  ),
                                                ),
                                        ),
                                      )]
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
                    )
                  ],
                  // body: SingleChildScrollView(...)
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 5.0.w, right: 5.w, top: 5.0.h),
                  width: 300.0.w,
                  child: TextFormField(
                    controller: messageController,
                    autofocus: false,
                    minLines: 1,//Normal textInputField will be displayed
                    maxLines: 5,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                      hintText: 'Message',
                      filled: true,
                    ),
                  ),
                ),
                  GestureDetector(
                    onTap: isfieldEmpty?()async {
                      if (messageController.text.isNotEmpty) {
                        setState(() {
                          isValidForm = true;
                          sentMessages.add(messageController.text);
                          sendArticleMessage();
                        });
                      } else {
                        setState(() {
                          isValidForm = false;
                        });
                      }
                    }: null,
                    child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 25,
                        child: Stack(
                            children: const [
                              Align(
                                  alignment: Alignment.bottomRight,
                                  child: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: Colors.blue,
                                    child:  Icon(Icons.send_sharp, color: Colors.white),// change this children
                                  )
                              )
                            ]
                        )
                    ),
                  ),
                //_dropdown(context),
              ],
            ),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  bool isValidForm = false;
  bool isloading = false;

  Widget _buildArticle() {
    return Container(
        margin: EdgeInsets.only(
            bottom: 10.0.h, left: 10.0.w, right: 10.w, top: 8.0.h),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0x00eff2f7), Colors.white],
          ),
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      height: 100.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.black12,
                      ),
                      child: Image.network(
                          "${Domain.dgaExpressPort}article/image?file=" +
                              mainImage, fit: BoxFit.fill)
                  ),
                  const SizedBox(width: 15),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.label),
                          Text("  " +
                              articleName.capitalize!,
                            style:
                            FontStyles.montserratRegular17().copyWith(
                                color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.attach_money_sharp),
                          Text("  " +
                              articlePrice + " " + currency,
                            style:
                            FontStyles.montserratRegular17().copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ]
        )
    );
  }

  void sendArticleMessage() async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}add/message'));
    request.body = json.encode({
      "content": messageController.text,
      "status": "ENABLED",
      "reservationDto": {
        "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
        "description": "string",
        "documents": true,
        "computer": true,
        "status": "ENABLED",
        "quantitykilo": 0,
        "date": "string",
        "totalprice": 0,
        "track": "string",
        "paid": true,
        "confirm": true,
        "quantityDocument": 0,
        "quantityComputer": 0,
        "receiver": "string",
        "tel": "string",
        "receivernumbercni": "string",
        "userDto": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
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
          "level": 0
        },
        "announcementDto": {
          "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
          "departuredate": "2022-11-16T09:23:16.611Z",
          "arrivaldate": "2022-11-16T09:23:16.611Z",
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
          "paymentMethod": "string",
          "point": 0,
          "userDto": {
            "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
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
            "level": 0
          }
        }
      },
      "sendermessage": {
        "id": currentUserId,
        "firstName": firstName,
        "lastName": lastName,
        "profileimgage": profileImage,
        "pseudo": pseudo,
        "email": email,
        "phone": phone,
        "roleDtos": [
          {
            "id": 2,
            "name": "ROLE_CLIENT"
          }
        ],
        "password": "string",
        "status": "ENABLED",
        "level": 0
      },
      "receivermessage": {
        "id": travellerId,
        "firstName": travellerfirstName,
        "lastName": travellerlastName,
        "profileimgage": travellerprofilepic,
        "pseudo": travellerpseudo,
        "email": travelleremail,
        "phone": travellerphone,
        "roleDtos": [
          {
            "id": 2,
            "name": "ROLE_CLIENT"
          }
        ],
        "password": "string",
        "status": "ENABLED",
        "level": 0
      },
      "date": "string",
      "articleDto": {
        "id": articleId,
        "name": articleName,
        "description": "",
        "price": articlePrice,
        "quantity": 0,
        "mainImage": mainImage,
        "status": "ENABLED",
        "date": "string",
        "location": "string",
        "user": {
          "id": travellerId,
          "firstName": travellerfirstName,
          "lastName": travellerlastName,
          "profileimgage": travellerprofilepic,
          "pseudo": travellerpseudo,
          "email": travelleremail,
          "phone": travellerphone,
          "roleDtos": [
            {
              "id": 2,
              "name": "ROLE_CLIENT"
            }
          ],
          "password": "string",
          "status": "ENABLED",
          "level": 0
        },
        "cathegory": {
          "id": cathegoryId,
          "name": cathegoryName,
          "description": cathegoryDescription,
          "status": "ENABLED",
          "user": {
            "id": cathegoryadminId,
            "firstName": cathegoryadminFN,
            "lastName": cathegoryadminLN,
            "profileimgage": cathegoryadminPP,
            "pseudo": cathegoryadminPs,
            "email": cathegoryadminEm,
            "phone": cathegoryadminphone,
            "roleDtos": [
              {
                "id": 1,
                "name": "ROLE_ADMIN"
              }
            ],
            "password": "string",
            "status": "ENABLED",
            "level": 0
          }
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      messageController.clear();
      /*setState(() {
        Navigator.push(
          context,
          PageTransition(type: PageTransitionType.fade, child: const MessagesArticles()),
        );
      });*/

      Fluttertoast.showToast(
          msg: "Message Sent",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
      Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }
  }

  Future getMessages(String travellerId) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}chat/messages/$travellerId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List mymessages = json.decode(data);
      return mymessages.map((data) => Listmymessages.fromJson(data)).toList();

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
      await storage.delete(key: "accesstoken");
      await storage.delete(key: "email");
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const login()));
    }
    else {
      debugPrint(response.reasonPhrase);
    }
  }

  /*void gethisUserDto(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('http://46.105.36.240:3000/users/$id'));

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
  }*/

  void deleteMessage(String id) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.dgaExpressPort}delete/message/$id/messages'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      debugPrint(await response.stream.bytesToString());
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: const MessagesArticles()),
      );
      Fluttertoast.showToast(
          msg: "Message Deleted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0
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

  void getarticleById(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}articles/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      Map<String, dynamic> senderDto = json.decode(data);

      cathegoryId = senderDto["cathegory"]["id"];
      cathegoryadminId = senderDto['cathegory']["user"]['id'];

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);
    }
  }
}