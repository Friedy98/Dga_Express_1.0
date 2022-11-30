
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Common/Widgets/custom_app_bar.dart';
import 'package:smart_shop/Screens/Notifications/notifications.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_shop/dummy/dummy_data.dart';
import 'package:smart_shop/Common/Widgets/shimmer_effect.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_shop/screens/Login/login.dart';
import 'package:smart_shop/screens/Profile/currentuserProfile.dart';
import 'package:smart_shop/screens/Services/AllAnnouncements.dart';
import 'package:smart_shop/screens/Services/Another_animation.dart';
import 'package:smart_shop/screens/Services/Post_Article.dart';
import 'package:smart_shop/screens/Services/createAnnouncement.dart';
import 'package:http/http.dart' as http;
import 'package:smart_shop/screens/Services/delayed_animation.dart';
import 'package:smart_shop/screens/mainhome/Marketplace.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' as plateform;

import '../../Announcements.dart';
import '../../Screens/subinformation.dart';
import '../../main.dart';
import '../ListArticles.dart';
import '../PopupWidget/PopupLogin.dart';
import '../PopupWidget/PopupLogout.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String routeName = 'HomePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final storage = const FlutterSecureStorage();
  String email = "";

  bool isLoggedIn = false;
  bool notifyMe = false;

  String userId = "";
  String totalReservations = "";
  String totalPosts = "";
  String totalAnnouncements = "";

  String userfirstName = "";
  String userlastName = "";
  String userEmail = "";
  String userprofilepic = "";
  String userPseudo = "";
  String userTel = "";
  String currency = "";
  String information = "";
  String link = "";
  List notifications = [];
  List<Subinformation>? subinformations;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    getData();
    checkUser();
  }

  void checkUser()async{
    String? token = await storage.read(key: "accesstoken");

    if(mounted) {
      if (token != null) {
        //notifications = prefs.getStringList("newNotifications")!;
        getProfile();
        email = (await storage.read(key: "email"))!;
        setState(() {
          isLoggedIn = !isLoggedIn;
        });
      }
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
            information = i.informations;
            link = i.link;
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

  List<Announcements>? announcement;
  bool isLoaded = false;

  void getData()async{
    announcement?.sort((a, b) => a.departuredate.compareTo(b.arrivaldate));

    announcement = await getAllAnnouncements();
    if(mounted) {
      if (announcement != null) {
        setState(() {
          isLoaded = true;
        });
      }
    }
  }

  TextEditingController suggestController = TextEditingController();

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

  void checkProfile() async{
    String? token = await storage.read(key: "accesstoken");
    if(token == null){
      showDialog(
          context: context,
          builder: (BuildContext context) => const PopupWidgetLogin());
    }else{
      Navigator.pushReplacementNamed(
          context, MyProfile.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: _buildCustomAppBar(context),
      drawer: _buildDrawer(context),
      body: Center(
      child: Container(
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
        child: _buildBody(context),
      ),
    ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white70,
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.white, Colors.lightBlueAccent],
              ),
            ),
            child: DelayedAnimation(delay: 400,
                child: Center(
                  child: Text(information,
                      overflow: TextOverflow.ellipsis,
                      style:
                      FontStyles.montserratRegular17().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                )
            )
          ),
          onTap: ()async{
            final Uri url = Uri.parse(link);
            await launchUrl(url);
          },
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            children: [
              AnotherDelayedAnimation(delay: 300,
                child: _buildMarketPlace(),
              ),
              DelayedAnimation(delay: 500,
                  child: _buildSellerCard(),
              ),
              AnotherDelayedAnimation(delay: 300,
                child: _buildAnnouncementTravels(),
              ),
              DelayedAnimation(delay: 500,
                  child: _buildTravels(),
              ),
              SizedBox(height: 80.h)
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width * .70,
      child: Drawer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .22,
              child: DrawerHeader(
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(!isLoggedIn)...[
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 60,
                              child: Image.asset('assets/images/Final logo dga sans fond.png'),
                            ),
                          ]else...[
                            ProfilePicture(
                                name: userPseudo,
                                radius: 55,
                                fontsize: 21,
                                img: userprofilepic != "" ?
                                '${Domain.dgaExpressPort}$userprofilepic'
                                    : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                            ),
                          ]
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(email,
                          overflow: TextOverflow.ellipsis,
                          style:
                          FontStyles.montserratRegular17().copyWith(color: Colors.white,fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    stops: [0, 1],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 1,
              height: MediaQuery
                  .of(context)
                  .size
                  .height * .70,
              child: isLoggedIn ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    onTap: () async{
                      checkProfile();
                    },
                    leading: const Icon(Icons.person,
                        color: AppColors.primaryLight),
                    title: Text(
                      'Mon Profile',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),

                  ListTile(
                      onTap: () async{
                          Navigator.pushNamed(context, CreateAnnouncement.routeName);
                      },
                      leading: const Icon(Icons.airplanemode_on_sharp,
                          color: AppColors.primaryLight),
                      title: Text(
                        'Nouveau Voyage',
                        style: FontStyles.montserratRegular18(),
                      ),
                  ),

                  ListTile(
                      onTap: () {
                        Navigator.pushNamed(context, PostArticle.routeName);
                      },
                      leading: const Icon(Icons.sell_rounded,
                          color: AppColors.primaryLight),
                      title: Text(
                        'Ajouter un Article',
                        style: FontStyles.montserratRegular18(),
                      ),
                  ),
                  ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed(NotificationScreen.routeName);
                      },
                      leading: const Icon(Icons.notifications_active_outlined,
                          color: AppColors.primaryLight),
                      title: Text(
                        'Notifications',
                        style: FontStyles.montserratRegular18(),
                      ),
                  ),
                  ListTile(
                      onTap: () {
                        _showWidgetContacter(context);
                      },
                      leading: const Icon(Icons.contact_phone_rounded,
                          color: AppColors.primaryLight),
                      title: Text(
                        'Nous contacter',
                        style: FontStyles.montserratRegular18(),
                      ),
                  ),

                  ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => const PopupWidgetLogout());
                        },
                        leading: const Icon(Icons.logout_outlined,
                            color: AppColors.primaryLight),
                        title: Text(
                          'Se Deconnecter',
                          style: FontStyles.montserratRegular18(),
                        ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  ListTile(
                    onTap: () {
                      _showAboutWidget(context);
                    },
                    leading: const Icon(Icons.info_outline_rounded,
                        color: Colors.grey),
                    title: Text(
                      'A propos',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      _showWidget(context);
                    },
                    leading: const Icon(Icons.help_outline,
                        color: Colors.grey),
                    title: Text(
                      'Aide',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),
                ],
              ) : Column(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 500),
                            child: const login()),
                      );
                    },
                    leading: const Icon(Icons.logout_outlined,
                        color: AppColors.primaryLight),
                    title: Text(
                      'Se Connecter',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),
                  const Divider(
                    color: Colors.grey,
                  ),
                  /*ListTile(
                    onTap: () {

                    },
                    leading: const Icon(Icons.share,
                        color: Colors.grey),
                    title: Text(
                      'Partager',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),*/
                  ListTile(
                    onTap: () {
                      _showAboutWidget(context);
                    },
                    leading: const Icon(Icons.info_outline_rounded,
                        color: Colors.grey),
                    title: Text(
                      'A propos',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      _showWidget(context);
                    },
                    leading: const Icon(Icons.help_outline,
                        color: Colors.grey),
                    title: Text(
                      'Aide',
                      style: FontStyles.montserratRegular18(),
                    ),
                  ),
                ]
              )
            ),
          ],
        ),
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
        isHome: true,
        enableSearchField: false,
        leadingIcon: Icons.menu,
        leadingOnTap: () {},
        trailingIcon: Icons.notifications,
        trailingOnTap: () async{

          Navigator.push(
            context,
            PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 500),
                child: const NotificationScreen()),
          );

        },
        scaffoldKey: _key,
      ),
    );
  }

  Widget _buildSellerCard() {
    var screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Container(
      margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 10.0.h),
      height: 220.h,
      width: 400.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0.r),
            child: makeSlider(),
          ),
          Positioned(
              top: screenHeight * .020.h,
              left: 20.0,
              child: Text(
                'Flash Ventes',
                style: FontStyles.montserratBold25()
                    .copyWith(color: AppColors.white),
              )),
        ],
      ),
    );
  }

  Future _showWidgetContacter(BuildContext context) {
    return showModalBottomSheet(
      isScrollControlled: true,
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
                      const SizedBox(height: 30),
                      Text('N\'hésitez pas a nous laisser vos suggestions pour nous aider a améliorer nos services',
                          style:
                          FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 250.0.w,
                        child: TextFormField(
                          controller: suggestController,
                          autofocus: false,
                          autocorrect: true,
                          minLines: 1,
                          maxLines: 5,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            hintText: 'Entrez un text',
                            labelText: 'Ajouter Suggestion',
                          ),
                          validator: (inputValue){
                            if(inputValue!.isEmpty ) {
                              return "field Required!";
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: ()async{
                          if(suggestController.text.isNotEmpty){
                            submitSuggestion();
                          }else{
                            Fluttertoast.showToast(
                                msg: "Entrez un text",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 2,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                                fontSize: 20.0
                            );
                          }
                        },
                        child: Container(
                            width: 120.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                              border: Border.all(width: 3, color: Colors.orange),
                            ),
                            child:  Center(
                              child: Text('Envoyer',
                                  style: FontStyles.montserratRegular19().copyWith(color: Colors.orange, fontWeight: FontWeight.bold)),

                            )),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.contact_phone),
                        title: Text("Douala", style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                        subtitle: Text("+237 678786731", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onLongPress: (){
                          FlutterClipboard.copy(
                              "+237682774250").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Numéro Copié",
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
                        onLongPress: (){
                          FlutterClipboard.copy(
                              "+237675851499").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Numéro Copié",
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
                        onLongPress: (){
                          FlutterClipboard.copy(
                              "+32465860367").then((
                              value) =>
                              Fluttertoast.showToast(
                                  msg: "Numéro Copié",
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
                        subtitle: Text("+32 465 853 983", style: FontStyles.montserratRegular17().copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                        onLongPress: (){
                          FlutterClipboard.copy(
                              "+32 465 853 983").then((
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
                          final Uri _url = Uri.parse("https://informatique@dga-express.com");
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

  Widget _buildTravels() {
    var screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return Container(
      margin: EdgeInsets.only(left: 5.0.w, right: 5.w, top: 10.0.h),
      height: 280.h,
      width: 400.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0.r),
            child: announcement != null ? announcement!.isNotEmpty?
            makeSlider2() :
            Container(
              margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 8.0.h),
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
                borderRadius: const BorderRadius.all(Radius.circular(15)),
              ),
            ) : plateform.Platform.isIOS
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
          Positioned(
              top: screenHeight * .010.h,
              left: 20.0,
              child: Text('Voyages',
                  style: FontStyles.montserratRegular25().copyWith(color: Colors.orange,fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget makeSlider2(){
    return CarouselSlider.builder(
        unlimitedMode: true,
        autoSliderDelay: const Duration(seconds: 7),
        enableAutoSlider: announcement != null?
        announcement!.length == 1 ? false : true
            : false,
        slideBuilder: (index) {
          return Container(
                padding: EdgeInsets.symmetric(horizontal: 25.0.w),
                color: const Color.fromRGBO(42, 3, 75, 0.35),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10.0.h),
                    Row(
                      children: [
                        ProfilePicture(
                            name: userPseudo,
                            radius: 40,
                            fontsize: 21,
                            img: announcement![index].userDto.profileimgage != "" ?
                            '${Domain.dgaExpressPort}${announcement![index].userDto.profileimgage}'
                                : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
                        ),
                        const SizedBox(width: 15),
                        RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(text: "${announcement![index].userDto.firstName
                                  .capitalize!} ${announcement![index].userDto
                                  .lastName.capitalize!}",
                                  style: FontStyles.montserratRegular19().copyWith(
                                      color: Colors.orangeAccent,
                                      fontWeight: FontWeight.bold)),
                              TextSpan(text: " \n ${announcement![index].price} $currency /Kg",
                                  style: FontStyles.montserratRegular19().copyWith(
                                      color: Colors.black)),
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
                    const SizedBox(height: 15),
                  ],
                ),
              );
        },
        scrollDirection: Axis.horizontal,
        slideTransform: const DefaultTransform(),
        itemCount: announcement!.length);
  }

  Widget makeSlider() {
    return CarouselSlider.builder(
        unlimitedMode: true,
        autoSliderDelay: const Duration(seconds: 5),
        enableAutoSlider: true,
        slideBuilder: (index) {
          return CachedNetworkImage(
            imageUrl: DummyData.sellerImagesLink[index],
            color: const Color.fromRGBO(42, 3, 75, 0.35),
            colorBlendMode: BlendMode.srcOver,
            fit: BoxFit.fill,
            placeholder: (context, name) {
              return ShimmerEffect(
                borderRadius: 10.0.r,
                height: 88.h,
                width: 343.w,
              );
            },
            errorWidget: (context, error, child) {
              return ShimmerEffect(
                borderRadius: 10.0.r,
                height: 88.h,
                width: 343.w,
              );
            },
          );
        },
        slideTransform: const DefaultTransform(),
        slideIndicator: CircularSlideIndicator(
          currentIndicatorColor: AppColors.lightGray,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 10.h, left: 20.0.w),
        ),
        itemCount: DummyData.sellerImagesLink.length);
  }

  Future _showAboutWidget(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
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
                          'A propos de Nous',
                            style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nDGA-EXPRESS est une entreprise individuelle ( établissement) à personne physique ,doncle siège social est situé au cameroun dans la ville de douala plus précisement à bonamoussadi au lieu dit  fin goudron afriue du sud face ecole primaire Joss . elle est spécialisé dans la mise en relation entre particuliers pour un envoi 3fois plus rapide, fiable et moins couteux de leurs colis par fret aerien de partout dans le monde et dispose egalement d’une plate forme E-commerce pour faciliter les achats de sa clientèle à l’internationnal à travers son site internet et son application mobile.",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Center(
                        child: Text(
                            'Suivez nous sur les réseaux sociaux',
                            style: FontStyles.montserratRegular17().copyWith(color: Colors.black, fontWeight: FontWeight.bold)
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/images/2227.jpg'),
                                    fit: BoxFit.fill
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.white, Colors.lightBlueAccent],
                                ),
                                border: Border.all(width: 2, color: Colors.white24),
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                              ),
                              width: 80,
                              height: 80,
                            ),
                            onTap: ()async{
                              final Uri _url = Uri.parse("https://www.instagram.com/dgaexpress/");
                              setState(() {
                                launchUrl(_url);
                              });
                            },
                          ),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                image: const DecorationImage(
                                    image: AssetImage('assets/images/733547.png'),
                                    fit: BoxFit.fill
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [Colors.white, Colors.lightBlueAccent],
                                ),
                                border: Border.all(width: 2, color: Colors.white24),
                                borderRadius: const BorderRadius.all(Radius.circular(15)),
                              ),
                              width: 52,
                              height: 52,
                            ),
                            onTap: ()async{
                              final Uri _url = Uri.parse("https://www.facebook.com/DGAExpress50");
                              setState(() {
                                launchUrl(_url);
                              });
                            },
                          )
                        ],
                      ),

                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future _showWidget(BuildContext context) {
    return showModalBottomSheet(
        isScrollControlled: true,
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
                          'Aide',
                          style: FontStyles.montserratRegular25().copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \nCréer gratuitement votre compte",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \nInserer le sigle",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                            TextSpan(text: " www.dga-express.com",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.blue)),
                            TextSpan(text: " dans votre moteur de recherche , Utiliser votre adress mail pour creer  votre compte ou  telecharger l’application DGA-EXPRESS sur play store ou appli store et creer votre profil à l’aide de votre adress mail . valider la creation de votre compte en confirmant votre adress via un mail de confirmation qui  vous sera envoyer ",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nRechercher une annonce",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \n \nRechercher l’annonce qui vous convient en filtrant les annonces present sur la page d’acceuil ",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nCOMPLETER LE FORMULAIRE DE RESERVATION",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \n \nUne fois votre voyage trouver , selectionner et remplisser les informations démandées .",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nvalider votre reservation",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \n \nConfirmer votre reservation via un paiement par carte bancaire, playpal , MTN et Orange money ,vous recevrez par la suite  le contact du voyageur par mail  .",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nConfirmer la reception de votre colis",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \n \nvalidez la bonne reception de votre colis  via votre application mobile ou site internet ou encore au point relais le plus proche .  Le voyageur pourra ainsi recevoir  sa commission.",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: " \n \nLaissez une evaluation ",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: " \n \nAprès recception de votre colis vous pouvez partager votre expérience en laissant une évaluation qui nous permettra d’ameliorer la quaité de notre service  ",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildMarketPlace() {
    return Container(
      margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 8.0.h),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, MarketPlace.routeName, arguments: [true, true]);
          },
          child: Container(
              width: 400,
              height: 80,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.deepOrangeAccent, Colors.orange, Colors.yellow],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0)
                  )),
              child:  Row(
                children: [
                  const SizedBox(width: 40),
                  Text('Visitez le Market Place',
                      style: FontStyles.montserratRegular19().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 15),
                  const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ],
              )),
        ),
      ),
    );
  }

  Widget _buildAnnouncementTravels() {
    return Container(
      margin: EdgeInsets.only(left: 10.0.w, right: 10.w, top: 15.0.h),
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(
                context, My_Posts.routeName);
          },
          child: Container(
              width: 400,
              height: 80,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.blue, Colors.lightBlueAccent],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0)
                  )),
              child:  Row(
                children: [
                  const SizedBox(width: 70),
                  Text('Voyages Disponible',
                      style: FontStyles.montserratRegular19().copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 15),
                  const Icon(Icons.airplanemode_on_sharp, color: Colors.white),
                ],
              )),
        ),
      ),
    );
  }
  bool isfieldEmpty = true;
  bool isValidForm = false;

  void getProfile() async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}profile'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {

      final profile = await response.stream.bytesToString();

      await storage.write(key: 'Profile', value: profile);

      userfirstName = json.decode(profile)['firstName'];
      userlastName = json.decode(profile)['lastName'];
      userEmail = json.decode(profile)['email'];
      userprofilepic = json.decode(profile)['profileimgage'];
      userPseudo = json.decode(profile)['pseudo'];
      userTel = json.decode(profile)['phone'];
      userId = json.decode(profile)['id'];

        getAnnouncementbyId(userId);
        getReservationbyId(userId);
        getmyArticles(userId);

    }else if(response.statusCode == 403){
      //print(senderDto["userDto"]);
      if(await storage.read(key: 'refreshToken') != null){
      }else{

        MotionToast.warning(
            description:  Text("Session expiré!", style: FontStyles.montserratRegular17().copyWith(
                color: Colors.black))
        ).show(context);
      }

      await storage.delete(key: "accesstoken");
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

  void getAnnouncementbyId(String id) async {
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request(
        'GET', Uri.parse('${Domain.dgaExpressPort}users/$id/announcements'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List announcementsTotal = json.decode(data);

        totalAnnouncements = announcementsTotal.length.toString();

      await storage.write(key: 'AnnouncementTotal', value: totalAnnouncements);
    }
    else {
      print(response.reasonPhrase);
    }
  }

  getmyArticles(String userId) async{

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

  Future getReservationbyId(String id) async {
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request(
        'GET', Uri.parse('${Domain.dgaExpressPort}user/$id/reservations'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List Myreservation = json.decode(data);
      //print(data);
        totalReservations = Myreservation.length.toString();

      await storage.write(key: 'ReservationTotal', value: totalReservations);
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print("Error is: " + errorMessage);
    }
  }

  void submitSuggestion() async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}suggest'));
    request.body = json.encode({

      "content": suggestController.text,
      "user": {
        "id": userId,
        "firstName": userfirstName,
        "lastName": userlastName,
        "profileimgage": userprofilepic,
        "pseudo": userPseudo,
        "email": userEmail,
        "phone": userTel,
        "roleDtos": [
          {
            "id": 2,
            "name": "ROLE_CLIENT"
          }
        ],
        "password": "string",
        "status": "ENABLED",
        "stars": 0
      }
    });
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();

      Fluttertoast.showToast(
          msg: "Merci! Votre message à été \n prise en compte",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 20.0
      );
      suggestController.clear();
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
}
