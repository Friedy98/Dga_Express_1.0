import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import '../../Screens/notificationservice.dart';
import '../../main.dart';
import 'app_title.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatefulWidget {
  const CustomAppBar(
      {this.isHome,
      this.leadingIcon,
      this.leadingOnTap,
      this.trailingIcon,
      this.trailingOnTap,
      this.title,
      this.scaffoldKey,
      this.enableSearchField,
      this.fixedHeight,
      Key? key})
      : super(key: key);
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final bool? isHome;
  final IconData? leadingIcon;
  final Function()? leadingOnTap;
  final IconData? trailingIcon;
  final Function()? trailingOnTap;
  final String? title;
  final bool? enableSearchField;
  final double? fixedHeight;
  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

  TextEditingController searchController = TextEditingController();

class _CustomAppBarState extends State<CustomAppBar> {

  final storage = const FlutterSecureStorage();
  NotificationService notificationService = NotificationService();
  String userid = "";
  List notificationData = [];
  String profilePic = "";

  @override
  void initState(){
    initialise();
    super.initState();
    notificationService.initialiseNotification();
  }

  void initialise()async{
    String? token = await storage.read(key: "accesstoken");
    String? notifications = await storage.read(key: "listOfnotifications");
    final profileData = await storage.read(key: 'Profile');
    if(token != null) {
      if(notifications != null) {
        setState(() {
          notificationData = jsonDecode(notifications);
        });
      }
      if(profileData != null){
      setState(() {
        userid = json.decode(profileData)['id'];
        profilePic = json.decode(profileData)['profileimgage'];
        testSse(userid);
      });
      }
    }
  }

  void testSse(String userid) async{
    Stream myStream;
    myStream = Sse.connect(
      uri: Uri.parse('http://46.105.36.240:3000/subcribe?userId=$userid'),
      closeOnError: true,
      withCredentials: false,
    ).stream;

    myStream.listen((event) async{
      setState(() {
        notificationData.add(json.decode(event)["newNotification"]);
      });
      print(notificationData.last);
      notificationService.sendNotification("New Notification", "Vous avez Une Nouvelle notification");

      MotionToast.info(
        animationCurve: Curves.ease,
        title: Text("Nouvelle Notification", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        description: Text("Vous avez recu une nouvelle Notification!", style: FontStyles.montserratRegular14().copyWith(
            color: Colors.white)),
        enableAnimation: true,
        animationType: AnimationType.fromTop,
        position: MotionToastPosition.top,
      ).show(context);
      await storage.write(key: 'listOfnotifications', value: json.encode(notificationData.last));

    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: widget.fixedHeight ?? 134.h,
      // height: 143.h,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.red,
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primaryDark],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          stops: [0, 1],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDrawerButton(context),

                  widget.isHome! ? _buildAppTitle() : _title(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                          _buildNotificationIcon(context),
                          _buildProfileIcon(context),
                        ]
                    )
                  ],
              ),
              widget.enableSearchField!
                  ? Positioned(
                      bottom: -85.h,
                      width: MediaQuery.of(context).size.width,
                      child: _buildSearchField(context))
                  : const SizedBox(
                      height: 10,
                      width: 0,
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerButton(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.only(top: 25.0),
      onPressed: widget.isHome!
          ? () {
              setState(
                () {
                  widget.scaffoldKey!.currentState!.openDrawer();
                },
              );
            }
          : widget.leadingOnTap,
      icon: Icon(
        widget.leadingIcon,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildAppTitle() {
    return AppTitle(
      fontStyle: FontStyles.montserratExtraBold18(),
      marginTop: 0.0,
    );
  }

  Widget _title() {
    return Text(
      widget.title!,
      style: FontStyles.montserratBold19().copyWith(
        color: AppColors.white,
      ),
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 17,
        child: Image.asset('assets/images/Final logo dga sans fond.png'),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0),
      child: notificationData.isNotEmpty ? Badge(
            position: BadgePosition.topEnd(top: 6, end: 6),
            elevation: 0,
            shape: BadgeShape.circle,
            badgeColor: Colors.red,
            badgeContent: Text(notificationData.length.toString(),
                style:  FontStyles.montserratRegular14().copyWith(color: Colors.white)),
            showBadge: true,
            child: IconButton(
              onPressed: widget.trailingOnTap,
              icon: Icon(
                  widget.trailingIcon,
                size: 30,
                color: Colors.white
              ),
            )

        ) : IconButton(
        onPressed: widget.trailingOnTap,
        icon: Icon(
            widget.trailingIcon,
            size: 30,
            color: Colors.white
        ),
      )
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 44.h,
      width: 330.w,
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(50.0.r)),
      margin: const EdgeInsets.all(20.0),
      child: TextFormField(
        controller: searchController,
        autofocus: false,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          hintText: 'What are you looking for?',
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0.r),
            borderSide: const BorderSide(color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
