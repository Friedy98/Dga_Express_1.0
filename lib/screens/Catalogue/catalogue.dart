import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/ListArticles.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import 'package:smart_shop/screens/Product/product.dart';

import 'package:smart_shop/screens/mainhome/mainhome.dart';

import '../../ListArticleByCategory.dart';
import '../../ListCategory.dart';
import '../../Screens/PopupWidget/PopupLogin.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../Cart/cart.dart';
import '../searchArticlePage.dart';
import '../subinformation.dart';

class Catalogue extends StatefulWidget {
  static const String routeName = 'catalogue';

  const Catalogue({Key? key}) : super(key: key);
  @override
  State<Catalogue> createState() => _CatalogueState();
}

class _CatalogueState extends State<Catalogue> {

  bool showbackArrow = true;
  List<ListArticles>? articles;
  List<ListArticleByCategory>? articlebyCategory;
  //SharedPreferences? prefs;

  final storage = const FlutterSecureStorage();
  bool isFavorite = false;

  bool isLoaded = false;
  bool showCategory = false;
  bool cathegorySelected = false;
  bool loadedarticlebyCategory = false;

  bool isSelected = false;
  String cathegoryId = "";
  String cathegoryadminId = "";
  String cathegoryName = "";
  String currentuserId = "";
  String firstName = "";
  String lastName = "";
  String tel = "";
  String email = "";
  bool search = false;
  String currency = "";
  int amount = 0;
  int sum = 0;
  int totalAmount = 0;
  int totelQty = 0;
  int quantity = 1;
  bool onChange = false;
  List<Subinformation>? subinformations;
  List product = [];
  //List individualprice = [];
  List<TextEditingController> textFieldControllers=[];

  @override
  void initState(){
    getArticleData();
    super.initState();
  }

  List<ListCategory>? category;
  int? selected;
  List<ListArticles>? cartItems;
  List articlesAdded = [];
  String? token;
  String code = "";

  void getArticleData() async{
    String? stringOfItems = await storage.read(key: 'listOfItems');
    if(stringOfItems != null) {
      articlesAdded = jsonDecode(stringOfItems);
      //print(articlesAdded);
    }
    token = await storage.read(key: "accesstoken");
    if(token != null){
      final profileData = await storage.read(key: 'Profile');
      setState(() {
        currentuserId = json.decode(profileData!)['id'];
        firstName = json.decode(profileData)['firstName'];
        lastName = json.decode(profileData)['lastName'];
        email = json.decode(profileData)['email'];
        tel = json.decode(profileData)['phone'];
      });
    }
    category = await getAllCategory();

    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      articles = await getallArticles();
      articles?.reversed;
        if (articles!.isNotEmpty) {
          setState(() {
            isLoaded = true;
          });
        } else if (showCategory != false) {
          isLoaded = true;
        }
      if(category != null){
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

  TextEditingController editingController = TextEditingController();
  TextEditingController qtyController = TextEditingController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize:
        Size(double.infinity, MediaQuery.of(context).size.height * .08),
        child: AppBar(
          title:Center(
            child: Text('Espace E-commerce',
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
        articlesAdded.isNotEmpty ? Badge(
              position: BadgePosition.topEnd(top: -4, end: -5),
              elevation: 0,
              shape: BadgeShape.circle,
              badgeColor: Colors.red,
              badgeContent:  Text(articlesAdded.length.toString(),
                  style:  FontStyles.montserratRegular14().copyWith(color: Colors.white)),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                        child: const Cart()),
                  );
                },
              ),
            ) : const Icon(
          Icons.shopping_cart,
          size: 30,
        ),
            const SizedBox(width: 20)
          ],
        )
      ),
      body: _buildItems(context),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildItems(BuildContext context) {
    //var screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(
          left: 10.0.w, right: 10.0.w, top: 5.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FocusedMenuHolder(
                      blurSize: 2.0,
                      menuItemExtent: 40,
                      menuBoxDecoration: const BoxDecoration(
                          color: Colors.white,
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
                        if(category != null)...[
                          for(var i in category!)...[
                            FocusedMenuItem(
                                title: Text(i.name, style: FontStyles.montserratRegular17().copyWith(
                                    color: Colors.blue, fontWeight: FontWeight.bold)),
                                trailingIcon: const Icon(Icons.category, color: Colors.grey),
                                onPressed: () {
                                  getCategoryById(i.id);
                                  Fluttertoast.showToast(
                                      msg: "Catégorie: " + i.name,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 2,
                                      backgroundColor: Colors.orange,
                                      textColor: Colors.white,
                                      fontSize: 20.0
                                  );
                                }
                            ),
                          ]
                        ]
                      ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.w,
                          height: 30.h,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                color: Colors.blue
                            ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Choisir  ",
                                  style: FontStyles.montserratRegular17().copyWith(color:
                                  Colors.white, fontWeight: FontWeight.bold)),
                              const Icon(Icons.arrow_drop_down, size: 30, color: Colors.white)
                            ],
                          )
                        ),
                        //const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 150.0.w,
                        height: 30.h,
                        child: TextFormField(
                          controller: editingController,
                          focusNode: FocusNode(),
                          enableInteractiveSelection: false,
                          autofocus: false,
                          decoration: const InputDecoration(
                            fillColor: Colors.white,
                            hintText: "Rechercher un Article",
                            filled: true,
                          ),
                        ),
                      ),
                      Container(
                        width: 40.w,
                        height: 30.h,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                            color: Colors.blue
                        ),
                        child: GestureDetector(
                          onTap: ()async{
                            if(editingController.text.isNotEmpty) {
                              await storage.write(
                                  key: 'cathegoryId', value: cathegoryId);
                              await storage.write(key: 'editingText',
                                  value: editingController.text);

                              Navigator.push(
                                context,
                                PageTransition(type: PageTransitionType.fade,
                                    child: const SearchArticlePage()),
                              );
                            }else{
                              Fluttertoast.showToast(
                                  msg: "No value",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 20.0
                              );
                            }
                            /*searchresults = await searchArticles(cathegoryId, editingController.text);
                            if(editingController.text.isNotEmpty){
                              setState(() {
                                search = true;
                              });
                            }*/
                          },
                          child: const Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if(!showCategory)...[
                    Text('Tous',
                        style: FontStyles.montserratRegular19().copyWith(color:
                        Colors.orange, fontWeight: FontWeight.bold)),
                  ]else...[
                    Text('Tous',
                        style: FontStyles.montserratRegular19().copyWith(color:
                        Colors.black38, fontWeight: FontWeight.bold)),
                  ],
                ],
                //searchbarc
              ),
              const SizedBox(width: 50),
              GestureDetector(
                onTap: (){
                  setState(() {
                    showCategory = !showCategory;
                    cathegorySelected = !cathegorySelected;
                  });
                },
                child: Row(
                  children: [
                    Text('filtrer par Catégorie',
                        style: FontStyles.montserratRegular17().copyWith(color:
                        Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    !showCategory ? const Icon(Icons.filter_list_rounded, color: Colors.orange) : const Icon(Icons.close, color: Colors.orange)
                  ],
                )
              ),
            ],
          ),
          Visibility(
            visible: showCategory,
              child: SizedBox(
                  height: 40.0.h,
                  child: ListView.builder(
                    itemCount: category?.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Container(
                          height: 163.h,
                          width: 163.w,
                          margin: EdgeInsets.only(right: 10.0.w, top: 8.0.h),
                          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.0),
                            color: selected == index ? Colors.orange : Colors.grey,
                          ),
                          child: Center(
                            child: Text(
                              category![index].name,
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        onTap: ()async{
                          articlebyCategory = await getArticlesByCategory(category![index].id);
                          cathegorySelected = true;
                          setState(() {
                            setState(() {
                              currentIndex = index;
                            });
                            selected = index;
                            /*Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const articlesbyCathegory(),
                              ),
                            );*/
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          const SizedBox(height: 10),
            if(!cathegorySelected)...[
              buildallitems(context)
            ]else...[
              if(articlebyCategory != null)...[
                buildarticlebycathegory(context)
              ]
            ],
          const SizedBox(height: 30),
        ],
      )
    );
  }

  Widget buildarticlebycathegory(BuildContext context){
    return Visibility(
      visible: cathegorySelected,
      child: Expanded(
        child: GridView.builder(
          itemCount: articlebyCategory?.length,
          gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisExtent: 320.0.h, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),
          itemBuilder: (context, index) {
            var date = DateTime.now().toString();

            var dateParse = DateTime.parse(date);

            var formattedDate = "${dateParse.day} / ${dateParse.month} / ${dateParse.year}";

            final item = articles![index];

            return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                      width: 3
                  ),
                    borderRadius: const BorderRadius.all(Radius.circular(15))
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: ()async{
                          product.add(item);
                          await storage.write(key: 'ownerfirstName', value: articlebyCategory![index].user.firstName);
                          await storage.write(key: 'ownerlastName', value: articlebyCategory![index].user.lastName);
                          await storage.write(key: 'ownerEmail', value: articlebyCategory![index].user.email);
                          await storage.write(key: 'ownertel', value: articlebyCategory![index].user.phone);
                          await storage.write(key: 'ownerId', value: articlebyCategory![index].user.id);

                          await storage.write(key: 'articleId', value: articlebyCategory![index].id);

                          await storage.write(key: 'product', value: jsonEncode(product));

                          Navigator.pushReplacementNamed(context, Product.routeName);

                        },
                        child: Container(
                            height: 163.h,
                            width: 172.w,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15.0),
                                  topRight: Radius.circular(15.0),
                                )
                            ),
                            child: Image.network("${Domain.dgaExpressPort}article/image?file=" + articlebyCategory![index].mainImage, fit: BoxFit.fill)
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
                                  articlebyCategory![index].quantity.toString(),
                                style: FontStyles.montserratRegular17().copyWith(
                                    color: Colors.white,fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                        if(currentuserId != articlebyCategory![index].user.id)...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(width: 10),
                              FloatingActionButton(
                                heroTag: null,
                                backgroundColor: Colors.blue,
                                onPressed: (){
                                  checkItemInCart(item);
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
                        Text(" " + formattedDate,
                          style: FontStyles.montserratRegular14().copyWith(
                              color: const Color(0xFF34283E)
                          ),
                        ),
                      ],
                    ),
                    Text(
                      articlebyCategory![index].location,
                      overflow: TextOverflow.ellipsis,
                      style: FontStyles.montserratRegular14().copyWith(
                          color: const Color(0xFF34283E)
                      ),
                    ),
                    Text(
                      articlebyCategory![index].name,
                      overflow: TextOverflow.ellipsis,
                      style: FontStyles.montserratRegular17().copyWith(
                          color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      articles![index].price.toString() + " " + currency,
                      style: FontStyles.montserratRegular17().copyWith(
                          color: Colors.red,fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                )
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
    );
  }

  Widget buildallitems(BuildContext context){
    return Visibility(
        visible: isLoaded,
        child: Expanded(
          child: GridView.builder(
              itemCount: articles?.length,
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisExtent: 340.0.h, crossAxisSpacing: 15.0, mainAxisSpacing: 15.0),
              itemBuilder: (context, index) {
                final item = articles![index];
                return Container(
                    width: 163.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        GestureDetector(
                            onTap: ()async{
                              product.add(item);

                              await storage.write(key: 'ownerfirstName', value: articles![index].user.firstName);
                              await storage.write(key: 'ownerlastName', value: articles![index].user.lastName);
                              await storage.write(key: 'ownerEmail', value: articles![index].user.email);
                              await storage.write(key: 'ownerPseudo', value: articles![index].user.pseudo);
                              await storage.write(key: 'ownertel', value: articles![index].user.phone);
                              await storage.write(key: 'ownerId', value: articles![index].user.id);
                              await storage.write(key: 'ownerprofileImage', value: articles![index].user.profileimgage);

                              await storage.write(key: 'product', value: jsonEncode(product));

                              await storage.write(key: 'articleId', value: articles![index].id);
                              Navigator.pushReplacementNamed(context, Product.routeName);

                            },
                            child: Column(
                                children: [
                                  Container(
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
                                ]
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
                                    backgroundColor: Colors.blue,
                                    onPressed: (){
                                      checkItemInCart(item);
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
                            Text(" ${articles![index].date}",
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: const Color(0xFF34283E)
                              ),
                            ),
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
                          style: FontStyles.montserratRegular19().copyWith(
                              color: const Color(0xFF34283E),fontWeight: FontWeight.bold
                          ),
                        ),
                        Text(
                          articles![index].price.toString() + " " + currency,
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
    );
  }

  getArticlesByCategory(String id) async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}article/cathegory/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List results = json.decode(data);

      return results.map((data) => ListArticleByCategory.fromJson(data)).toList();
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
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

  getallArticles() async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}articles/available'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      List products = json.decode(data);
      return products.map((data) => ListArticles.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }
  }

  void getCategoryById(String id) async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/cathegories/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      Map<String, dynamic> senderDto = json.decode(data);

      //print(senderDto["userDto"]);
      cathegoryId = senderDto["id"];
      cathegoryName = senderDto['name'];
      cathegoryadminId = senderDto["user"]["id"];

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

  getAllCategory() async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}cathegories'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List allcategories = json.decode(data);
      return allcategories.map((data) => ListCategory.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }
  }

  Future getimages(String id) async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}article/paths/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final images = await response.stream.bytesToString();
      List imageresults = json.decode(images);
      return imageresults;
    }
    else {
      print(response.reasonPhrase);
    }
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
}
