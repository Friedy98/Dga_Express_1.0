
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_shop/Utils/app_colors.dart';

import '../../Common/Widgets/custom_app_bar.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../Utils/font_styles.dart';
import '../Screens/Product/product.dart';
import '../Screens/subinformation.dart';
import '../main.dart';
import 'ListArticles.dart';
import 'PopupWidget/Popup.dart';
import 'PopupWidget/PopupLogin.dart';
import 'PopupWidget/popupSearchError.dart';
import 'mainhome/Marketplace.dart';

class SearchArticlePage extends StatefulWidget {
  static const String routeName = 'SearchArticlePage';
  const SearchArticlePage({Key? key}) : super(key: key);

  @override
  SearchArticlePageState createState() => SearchArticlePageState();
}

class SearchArticlePageState extends State<SearchArticlePage> {

  bool isLoaded = false;
  bool isLoaded2 = false;
  bool showbackArrow = true;
  String cathegoryId = "";
  String searchArticle = "";
  String currentuserId = "";
  String currency = "";
  List<Subinformation>? subinformations;
  SharedPreferences? prefs;
  List<String> cartItems = [];

  final storage = const FlutterSecureStorage();
  bool searchresults = false;

  var someCapitalizedString = "someString".capitalize!;

  @override
  void initState(){
    super.initState();
    getArticleData();
  }

  List<ListArticles>? articles;
  String? token;

  void getArticleData()async{
    cathegoryId = (await storage.read(key: 'cathegoryId'))!;
    searchArticle = (await storage.read(key: 'editingText'))!;
    token = await storage.read(key: "accesstoken");
    final profileData = await storage.read(key: 'Profile');
    if(token != null){
      setState(() {
        currentuserId = json.decode(profileData!)['id'];
      });
    }

    articles = await searchArticles(cathegoryId, searchArticle);
    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      if (articles!.isNotEmpty) {
        setState(() {
          isLoaded = true;
        });
      } else {
        isLoaded2 = true;
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

  Future searchArticles(String cathegoryId, String text) async{

    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}search/cathegoies/$cathegoryId/articles/$text'));

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

      return results.map((data) => ListArticles.fromJson(data)).toList();
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(error);
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

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      appBar: _buildCustomAppBar(context),
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: EdgeInsets.only(
            left: 15.0.w, right: 15.0.w, bottom: screenHeight * .04.h,top: 5.h),
        child: Column(
                  children: [
                    Visibility(
                        visible: isLoaded,
                        child: Expanded(
                          child: GridView.builder(
                              itemCount: articles?.length,
                              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, mainAxisExtent: 320.0.h, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),
                              itemBuilder: (context, index) {
                                var date = DateTime.now().toString();

                                var dateParse = DateTime.parse(date);

                                var formattedDate = "${dateParse.day} / ${dateParse.month} / ${dateParse.year}";
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white60,
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                          onTap: ()async{

                                            await storage.write(key: 'ownerfirstName', value: articles![index].user.firstName);
                                            await storage.write(key: 'ownerlastName', value: articles![index].user.lastName);
                                            await storage.write(key: 'ownerEmail', value: articles![index].user.email);
                                            await storage.write(key: 'ownertel', value: articles![index].user.phone);
                                            await storage.write(key: 'ownerId', value: articles![index].user.id);

                                            await storage.write(key: 'articleId', value: articles![index].id);

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
                                              child: Image.network("${Domain.dgaExpressPort}article/image?file=" + articles![index].mainImage, fit: BoxFit.fill)
                                          )
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
                                                    articles![index].quantity.toString(),
                                                  style: FontStyles.montserratRegular17().copyWith(
                                                      color: Colors.white,fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if(currentuserId != articles![index].user.id)...[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                const SizedBox(width: 10),
                                                FloatingActionButton(
                                                  heroTag: null,
                                                  onPressed: (){
                                                    checkItemInCart(articles![index].id);
                                                  },
                                                  tooltip: 'Increment',
                                                  child: const Icon(Icons.add_shopping_cart),
                                                ),
                                              ],
                                            )]
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const Icon(Icons.date_range_rounded, size: 20),
                                          if(articles![index].date != null)...[
                                            Text(" " + formattedDate,
                                              style: FontStyles.montserratRegular14().copyWith(
                                                  color: const Color(0xFF34283E)
                                              ),
                                            ),
                                          ]
                                        ],
                                      ),
                                      Text(
                                        articles![index].location,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontStyles.montserratRegular14().copyWith(
                                            color: const Color(0xFF34283E)
                                        ),
                                      ),
                                      Text(
                                        articles![index].name,
                                        overflow: TextOverflow.ellipsis,
                                        style: FontStyles.montserratRegular17().copyWith(
                                            color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.attach_money_sharp, color: Colors.red),
                                          Text(
                                            articles![index].price.toString() + " " + currency,
                                            style: FontStyles.montserratRegular17().copyWith(
                                                color: Colors.red,fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
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
                        visible: isLoaded2,
                        child: Center(
                          child: Text('No Posts yet',style:
                          FontStyles.montserratRegular14().copyWith(color: Colors.black12),),
                        )
                    )
                  ],
        )
      ),
    );
  }

  PreferredSize _buildCustomAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize:
      Size(double.infinity, MediaQuery
          .of(context)
          .size
          .height * .08),
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
                PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                    child: const MarketPlace()),
              );
            });
          },
          title: 'Results for $searchArticle'
      ),
    );
  }

  void checkItemInCart(String id) async{
    if(cartItems.contains(id)){
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
            cartItems.add(id);
          });
        }
        prefs = await SharedPreferences.getInstance();
        prefs!.setStringList("cartItems", cartItems);
        Fluttertoast.showToast(
            msg: 'Item Added to Cart',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
            fontSize: 20.0
        );
      }else{
        showDialog(
            context: context,
            builder: (BuildContext context) => const PopupWidgetLogin());
      }
    }
  }

  bool isValidForm = false;

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
