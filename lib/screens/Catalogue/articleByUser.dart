import 'dart:async';
import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/mainhome/Marketplace.dart';

import 'dart:io' as plateform;

import 'package:http/http.dart' as http;
import '../../Screens/ListArticles.dart';
import '../../Screens/PopupWidget/PopupLogin.dart';
import '../../Screens/Product/product.dart';
import '../../Screens/subinformation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';

class UserArticles extends StatefulWidget {
  static const String routeName = 'UserArticles';
  const UserArticles({Key? key}) : super(key: key);

  @override
  UserArticlesState createState() => UserArticlesState();
}

class UserArticlesState extends State<UserArticles> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool showbackArrow = true;
  String profilepic = "";
  String firstName = "";
  String lastName = "";
  String currency = "";
  String userId = "";
  String userPP = "";
  bool isLoaded = false;
  List articlesAdded = [];
  String token = "";

  List<ListArticles> articles = [];
  List<Subinformation>? subinformations;
  final storage = const FlutterSecureStorage();

  @override
  void initState(){
    getArticleData();
    super.initState();
  }

  void getArticleData() async{
    token = (await storage.read(key: "accesstoken"))!;
    userId = (await storage.read(key: "userId"))!;
    firstName = (await storage.read(key: "userfirstName"))!;
    lastName = (await storage.read(key: "userlastName"))!;
    userPP = (await storage.read(key: "userPP"))!;

    String? stringOfItems = await storage.read(key: 'listOfItems');
    if(stringOfItems != null) {
      articlesAdded = jsonDecode(stringOfItems);
      //print(articlesAdded);
    }

    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      articles = await getArticlesByUser(userId);

      articles.reversed;
      if (articles.isNotEmpty) {
        setState(() {
          isLoaded = true;
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

    }
    else {
      print(response.reasonPhrase);
    }
  }

  getArticlesByUser(String userId) async{

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
      List products = json.decode(data);
      return products.map((data) => ListArticles.fromJson(data)).toList();

    }
    else {
      final error = await response.stream.bytesToString();
      String erreur = json.decode(error)["error"];
      MotionToast.warning(
          description:  Text("$erreur \nUne erreur est survenue!", style: FontStyles.montserratRegular17().copyWith(
              color: Colors.black))
      ).show(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: Text("$firstName $lastName ", style:
        FontStyles.montserratRegular17().copyWith(color: Colors.white)),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: (){
                  Navigator.push(
                    context,
                    PageTransition(type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 300),
                        child: const MarketPlace()),
                  );
                },
                icon: Icon(showbackArrow ? plateform.Platform.isIOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back : null,
                ),
              ),
              ProfilePicture(
                  name: 'User name',
                  radius: 25,
                  fontsize: 21,
                  img: userPP != ""
                      ? '${Domain.dgaExpressPort}$userPP'
                      : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg'
              ),
            ],
          )
        ),
        leadingWidth: 100.w,
        centerTitle: true,
        actions: [
          /*IconButton(
              onPressed: (){

              },
              icon: const Icon(Icons.message, color: Colors.white)
          ),*/
          articlesAdded.isNotEmpty ? Badge(
            position: BadgePosition.topEnd(top: -4, end: -5),
            elevation: 0,
            shape: BadgeShape.circle,
            badgeColor: Colors.red,
            badgeContent:  Text(articlesAdded.length.toString(),
                style:  FontStyles.montserratRegular14().copyWith(color: Colors.white)),
            child: const Icon(
              Icons.shopping_cart,
              size: 30,
            ),
          ) : const Icon(
            Icons.shopping_cart,
            size: 30,
          ),
          SizedBox(width: 15.w)
        ],
      ),
      resizeToAvoidBottomInset: false,
      body:  _bodybuilder(context),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      width: double.infinity,
      height: 50.0.h,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Bienvenue chez $firstName",
              overflow: TextOverflow.ellipsis,
              style: FontStyles.montserratRegular17().copyWith(color: Colors.white)
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _bodybuilder(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          Visibility(
            visible: isLoaded,
            child: Expanded(
              child: GridView.builder(
                  itemCount: articles.length,
                  gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisExtent: 340.0.h, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),

                  itemBuilder: (context, index) {
                    final item = articles[index];
                    return Container(
                        width: 163.w,
                        decoration: BoxDecoration(
                            color: Colors.white60,
                            border: Border.all(
                                color: Colors.grey,

                                width: 3
                            ),
                            borderRadius: const BorderRadius.all(Radius.circular(15))
                        ),
                        padding: const EdgeInsets.all(5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                                children: [
                                  GestureDetector(
                                      onTap: ()async{

                                        await storage.write(key: 'ownerfirstName', value: articles[index].user.firstName);
                                        await storage.write(key: 'ownerlastName', value: articles[index].user.lastName);
                                        await storage.write(key: 'ownerEmail', value: articles[index].user.email);
                                        await storage.write(key: 'ownertel', value: articles[index].user.phone);
                                        await storage.write(key: 'ownerId', value: articles[index].user.id);

                                        await storage.write(key: 'articleId', value: articles[index].id);

                                        Navigator.pushReplacementNamed(context, Product.routeName);

                                      },
                                      child: Container(
                                          height: 163.h,
                                          width: 172.w,
                                          decoration: const BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15.0),
                                                topRight: Radius.circular(15.0),
                                              )
                                          ),
                                          child: Image.network("h${Domain.dgaExpressPort}article/image?file=" + articles[index].mainImage, fit: BoxFit.fill)
                                      )
                                  ),
                                ]
                            ),
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 10.0),
                                  width: 70.0,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFF49763), Color(0xFFD23A3A)],
                                      stops: [0, 1],
                                      begin: Alignment.bottomRight,
                                      end: Alignment.topLeft,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.shopping_cart, color: Colors.white),
                                      Text(" " +
                                          articles[index].quantity.toString(),
                                        style: FontStyles.montserratRegular17().copyWith(
                                            color: Colors.white,fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const SizedBox(width: 10),
                                    FloatingActionButton(
                                      heroTag: null,
                                      onPressed: (){
                                        checkItemInCart(item);
                                      },
                                      tooltip: 'Increment',
                                      child: const Icon(Icons.add_shopping_cart),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(Icons.date_range_rounded, size: 20),
                                Text(" ${articles[index].date}",
                                  style: FontStyles.montserratRegular14().copyWith(
                                      color: const Color(0xFF34283E)
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              articles[index].location,
                              overflow: TextOverflow.ellipsis,
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: const Color(0xFF34283E)
                              ),
                            ),
                            Text(
                              articles[index].name,
                              overflow: TextOverflow.ellipsis,
                              style: FontStyles.montserratRegular19().copyWith(
                                  color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                              ),
                            ),
                            Text(
                              articles[index].price.toString() + " " + currency,
                              style: FontStyles.montserratRegular17().copyWith(
                                  color: Colors.red,fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        )
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
      )
    );
  }

  void checkItemInCart(item) async{
    if(articlesAdded.contains(item)){
      Fluttertoast.showToast(
          msg: 'Item Already Exists',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }else{
      if(token != null) {
        if (mounted) {
          setState(() {
            articlesAdded.add(item);
          });
        }
        Fluttertoast.showToast(
            msg: 'Item Added to Cart',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 20.0
        );
        await storage.write(key: 'listOfItems', value: jsonEncode(articlesAdded));
      }else{
        showDialog(
            context: context,
            builder: (BuildContext context) => const PopupWidgetLogin());
      }
    }
  }
}