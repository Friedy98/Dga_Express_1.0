import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Common/Widgets/app_button.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/Utils/font_styles.dart';
import 'dart:io' as plateform;
import 'package:http/http.dart' as http;
import 'package:smart_shop/screens/Catalogue/articleByUser.dart';
import 'package:smart_shop/screens/Catalogue/catalogue.dart';
import 'package:smart_shop/screens/CheckOut/check_out.dart';
import 'package:smart_shop/screens/Services/MessagesArticles.dart';
import 'package:smart_shop/screens/Services/updateArticle.dart';

import '../../Common/Widgets/shimmer_effect.dart';
import '../../ListArticleByCategory.dart';
import '../../main.dart';
import '../Cart/cart.dart';
import '../PopupWidget/PopupLogin.dart';
import '../mainhome/Marketplace.dart';
import '../subinformation.dart';

// ignore: must_be_immutable
class Product extends StatefulWidget {
  static const String routeName = 'product';
  Product({Key? key}) : super(key: key);
  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {

  final storage = const FlutterSecureStorage();
  String articleId = "";
  String name = "";
  String descrition = "";
  String town = "";
  List articleIds = [];

  List articlesAdded = [];
  int? quantity = 0;
  int? price = 0;
  String location = "";
  String ownerfirstName = "";
  String ownerlastName = "";
  String ownerTel = "";
  String ownerEmail = "";

  String currentUserId = "";
  String currentUserFN = "";
  String currentUserLN = "";
  String currentUserEmail = "";
  String currentUserTel = "";

  String ownerId = "";
  String ownerPseudo = "";
  String cathegory = "";
  String cathegoryId = "";
  String ownerprofileImage = "";
  String articleImage = "";

  bool iscategoryDress = false;
  bool ismyArticle = true;
  bool loadedarticlebyCategory = false;
  bool isFavorite = false;
  List results = [];
  List<ListArticleByCategory>? articlebyCategory;
  bool showbackArrow = true;
  String currency = "";
  List<Subinformation>? subinformations;
  List product = [];

  @override
  void initState(){
    super.initState();
    getArticleInformation();
  }

  void getArticleInformation()async{
    articleId = (await storage.read(key: 'articleId'))!;
    String? token = await storage.read(key: "accesstoken");
    final userid = await storage.read(key: 'Profile');
    String? stringOfItems = await storage.read(key: 'listOfItems');
    String? stringOfproducts = await storage.read(key: 'product');
    if(stringOfproducts != null) {
      setState(() {
        product = jsonDecode(stringOfproducts);
      });
    }
    if(stringOfItems != null) {
      setState(() {
        articlesAdded = jsonDecode(stringOfItems);
      });
      //print(articlesAdded);
    }
    if(token != null && userid != null) {
      setState(() {
        currentUserId = json.decode(userid)['id'];
        currentUserFN = json.decode(userid)['firstName'];
        currentUserLN = json.decode(userid)['lastName'];
        currentUserEmail = json.decode(userid)['email'];
        currentUserTel = json.decode(userid)['phone'];
      });
    }
    ownerfirstName = (await storage.read(key: 'ownerfirstName'))!;
    ownerlastName = (await storage.read(key: 'ownerlastName'))!;
    ownerEmail = (await storage.read(key: 'ownerEmail'))!;
    ownerTel = (await storage.read(key: 'ownertel'))!;
    ownerId = (await storage.read(key: 'ownerId'))!;
    ownerPseudo = (await storage.read(key: 'ownerPseudo'))!;
    ownerprofileImage = (await storage.read(key: 'ownerprofileImage'))!;
    if(mounted) {
      subinformations = await getsubInfo();
      if(subinformations != null) {
        for (var i in subinformations!) {
          setState(() {
            currency = i.currency;
          });
        }
      }
      setState(() {
        getarticleById(articleId);
      });
    }
    if(currentUserId == ownerId){
      setState(() {
        ismyArticle = false;
      });
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

  void getarticleById(String id)async{

    var headers = {
      'Content-Type': 'application/json',
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}articles/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();
      results = await getimages(articleId);
      setState(() {
        name = json.decode(data)['name'];
        descrition = json.decode(data)['description'];
        price = json.decode(data)['price'];
        quantity = json.decode(data)['quantity'];
        location = json.decode(data)['location'];
        articleImage = json.decode(data)['mainImage'];
        cathegory = json.decode(data)['cathegory']['name'];
        cathegoryId = json.decode(data)['cathegory']['id'];
      });
      articlebyCategory = await getArticlesByCategory(cathegoryId);
      if(articlebyCategory!.isNotEmpty){
        setState(() {
          loadedarticlebyCategory = true;
        });
      }
    }
    else {
      print(response.reasonPhrase);
    }

  }
   int index = 0;

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)!.settings.arguments != null) {
      index = ModalRoute.of(context)!.settings.arguments as int;
    }
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      body: _buildBody(context),
      /*bottomSheet: _buildBottomSheet(
          context: context,
          onTap: () {
            Navigator.pushReplacementNamed(context, Cart.routeName);
          }),*/
    );
  }

  Widget _buildBody(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    //var screenWidth = MediaQuery.of(context).size.width;
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            backgroundColor: Colors.deepOrange,
            collapsedHeight: kToolbarHeight,
            expandedHeight: screenHeight * .40.h,
            pinned: false,
            flexibleSpace: FlexibleSpaceBar(
              background: makeSlider(),
            ),
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  child: IconButton(
                      onPressed: (){
                        Navigator.push(
                          context,
                          PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                              child: const MarketPlace()),
                        );
                      },
                      icon: Icon(showbackArrow ? plateform.Platform.isIOS
                          ? Icons.arrow_back_ios
                          : Icons.arrow_back : null)

                  ),
                ),
                articlesAdded.isNotEmpty ? Badge(
                  position: BadgePosition.topEnd(top: -4, end: -5),
                  elevation: 0,
                  shape: BadgeShape.circle,
                  badgeColor: Colors.red,
                  badgeContent:  Text(articlesAdded.length.toString(),
                      style:  FontStyles.montserratRegular14().copyWith(color: Colors.white)),
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart, size: 40),
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
                  size: 40,
                ),
              ],
            ),
            leadingWidth: 200.w,
          ),
        ];
      },
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAboutProduct(context),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Visibility(
                    visible: iscategoryDress,
                      child: _buildColorAndSizeSelection(context),
                  ),
                  SizedBox(height: 10.0.h),
                  _buildProductDetail(context),
                  SizedBox(height: 10.0.h),
                  _buildProductOwnerDetail(context),
                  SizedBox(height: 10.0.h),
                  _buildRelatedProduct(context)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget makeSlider() {
    return CarouselSlider.builder(
        unlimitedMode: true,
        autoSliderDelay: const Duration(seconds: 5),
        enableAutoSlider: true,
        slideBuilder: (index) {
          return CachedNetworkImage(
            imageUrl: "${Domain.dgaExpressPort}article/image?file=" + results[index],
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
        scrollDirection: Axis.horizontal,
        slideTransform: const DefaultTransform(),
        slideIndicator: CircularSlideIndicator(
          currentIndicatorColor: AppColors.lightGray,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 10.h, left: 20.0.w),
        ),
        itemCount: results.length);
  }

  Widget _buildAboutProduct(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Visibility(
                  visible: !ismyArticle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: (){
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  backgroundColor: Colors.grey[300],
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Center(
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            const Icon(Icons.warning_rounded, color: Colors.red,size: 70),
                                            const SizedBox(width: 15),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text( " Warning! ",
                                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold),),
                                                SizedBox(
                                                  width: 280.w,
                                                  child: Text( "Do you really want to delete this post?",
                                                      style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Divider(color: Colors.grey),
                                      const SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context, rootNavigator: true).pop();
                                            },
                                            child: Center(
                                              child: Text('Annuler',
                                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),

                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteArticle(articleId);
                                            },
                                            child: Text('Suprimer',
                                                style: FontStyles.montserratRegular17().copyWith(color: Colors.red)),

                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: const Icon(Icons.delete_rounded, size: 30),
                      ),
                      SizedBox(width: 10.0.w),
                      IconButton(
                          onPressed: ()async{
                            await storage.write(key: 'articleId', value: articleId);
                            Navigator.pushReplacementNamed(context, updateArticle.routeName);
                          },
                          icon: const Icon(Icons.update, size: 30)
                      ),
                    ],
                  )
                )
              ],
            ),
          ),
          ListTile(
                    title: Text(cathegory,style: FontStyles.montserratRegular19()),
                    subtitle: Text(name, style: FontStyles.montserratRegular17()),
                    ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildPrice(context, price.toString() + " " + currency + "  "),
              if(ismyArticle)...[
              FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.blue,
                onPressed: ()async{
                  String? token = await storage.read(key: "accesstoken");

                  for(var item in product) {
                    if(token != null) {
                        setState(() {
                          articlesAdded.add(item);
                        });
                      Fluttertoast.showToast(
                          msg: 'Ajouté au panier',
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
                },
                tooltip: 'Increment',
                child: const Icon(Icons.add_shopping_cart),
              ),
              SizedBox(width: 10.w),
              ]
            ],
          )
        ],
      ),
    );
  }

  Widget _buildColorAndSizeSelection(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0.h, vertical: 20.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildColorSelection(context),
            SizedBox(height: 20.0.h),
            _buildSizes(context),
          ],
        ),
      ),
    );
  }

  Future getimages(String id) async{
    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}article/paths/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final articleImages = await response.stream.bytesToString();
      return json.decode(articleImages);
      //print(results);

    }
    else {
      print(response.reasonPhrase);
    }
  }

  Widget _buildPrice(BuildContext context, String price) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0.w, top: 10.0.h),
      child: Text(
        price,
        style: FontStyles.montserratRegular25().copyWith(color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildColorSelection(BuildContext context) {
    List<String> colors = [
      'assets/product/pic1.png',
      'assets/product/pic2.png',
      'assets/product/pic3.png',
      'assets/product/pic4.png',
      'assets/product/pic5.png',
      'assets/product/pic6.png',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Colors',
          style: FontStyles.montserratSemiBold14(),
        ),
        SizedBox(height: 20.0.h),
        SizedBox(
          height: 47.0.h,
          child: ListView.separated(
            itemCount: colors.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Container(
                height: 47.h,
                width: 47.w,
                decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(colors[index])),
                    borderRadius: BorderRadius.circular(10.0.r)),
              );
            },
            separatorBuilder: (context, index) {
              return SizedBox(width: 10.0.w);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizes(BuildContext context) {
    List<String> titles = ['XXS', 'XS', 'S', 'M', 'L', 'XL'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sizes',
          style: FontStyles.montserratSemiBold14(),
        ),
        SizedBox(height: 20.0.h),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50.0.h,
          child: ListView.builder(
            itemCount: titles.length,
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(right: 10.0.w),
                padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                decoration: BoxDecoration(
                    color: index == 0 ? AppColors.secondary : AppColors.white,
                    borderRadius: BorderRadius.circular(5.0.r)),
                child: Center(
                  child: Text(
                    titles[index],
                    style: FontStyles.montserratRegular14().copyWith(
                        color: index == 0
                            ? AppColors.white
                            : AppColors.textLightColor),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetail(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description de l\'article',
            style: FontStyles.montserratBold19(),
          ),
          SizedBox(height: 10.0.h),
          Text(
            descrition,
            style: FontStyles.montserratRegular17(),
          )
        ],
      ),
    );
  }
  Widget _buildProductOwnerDetail(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.0.r),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(left: 10.0.w, right: 20.w, top: 10.0.h, bottom: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ProfilePicture(
                  name: ownerPseudo,
                  radius: 40,
                  fontsize: 21,
                  img: ownerprofileImage != "" ?
                '${Domain.dgaExpressPort}' + ownerprofileImage
                    : 'https://as1.ftcdn.net/v2/jpg/03/46/83/96/1000_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg',
                ),
                SizedBox(width: 10.0.w),
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: 'Posté par ',
                          style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                      if(currentUserId != ownerId)...[
                      TextSpan(text: " \n" + ownerfirstName + " " + ownerlastName,
                          style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                      ]else...[
                        TextSpan(text: " \n Vous",
                            style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                      ]
                    ],

                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0.h),
          Visibility(
            visible: ismyArticle,
              child: GestureDetector(
                        onTap: ()async{
                          String? token = await storage.read(key: "accesstoken");
                          if(token != null) {
                          await storage.write(key: "senderid", value: ownerId);
                          await storage.write(key: "cathegoryId", value: cathegoryId);

                          await storage.write(key: "articleName", value: name);
                          await storage.write(key: "articleId", value: articleId);
                          await storage.write(key: "articlePrice", value: price.toString());
                          await storage.write(key: "articleImage", value: articleImage);

                            Navigator.pushReplacementNamed(
                                context, MessagesArticles.routeName);
                          }else{
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => const PopupWidgetLogin());
                          }
                        },
                        child: ListTile(
                          leading: const Icon(Icons.chat_bubble_rounded, color: Colors.blue,),
                          title: Text(
                            "Envoyer un Message",
                            style: FontStyles.montserratRegular17(),
                          ),
                        ),
                      )
              ),
          ismyArticle ? Center(
            child: ElevatedButton(
              onPressed: ()async{
                String? token = await storage.read(key: "accesstoken");
                if(token != null) {
                  await storage.write(key: "userId", value: ownerId);
                  await storage.write(key: "userPP", value: ownerprofileImage);
                  await storage.write(key: "userfirstName", value: ownerfirstName);
                  await storage.write(key: "userlastName", value: ownerlastName);

                  Navigator.push(
                    context,
                    PageTransition(type: PageTransitionType.fade,
                        duration: const Duration(milliseconds: 300),
                        child: const UserArticles()),
                  );
                }else{
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => const PopupWidgetLogin());
                }
              },
              child: const Text("Voir plus..."),
            ),
          ) : const SizedBox(height: 10)
        ],
      ),
    );
  }

  Widget _buildRelatedProduct(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Autres produits similaires',
            style: FontStyles.montserratBold19()
                .copyWith(color: const Color(0xFF34283E)),
          ),
          SizedBox(height: 10.0.h),
          SizedBox(
            // color: Colors.red,
            height: 330.h,
            // width: 200,
            child: Container(
                margin: EdgeInsets.only(
                    left: 15.0.w, right: 15.0.w, bottom: 5.h,top: 5.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Visibility(
                        visible: loadedarticlebyCategory,
                        child: Expanded(
                          child: ListView.builder(
                            itemCount: articlebyCategory?.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              var date = DateTime.now().toString();

                              var dateParse = DateTime.parse(date);

                              var formattedDate = "${dateParse.day} / ${dateParse.month} / ${dateParse.year}";
                              return Container(
                                width: 163.w,
                                  margin: EdgeInsets.only(
                                      left: 10.0.w, right: 10.0.w, bottom: 5.h,top: 5.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 3
                                    ),
                                  ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: ()async{

                                        await storage.write(key: 'ownerfirstName', value: articlebyCategory![index].user.firstName);
                                        await storage.write(key: 'ownerlastName', value: articlebyCategory![index].user.lastName);
                                        await storage.write(key: 'ownerEmail', value: articlebyCategory![index].user.email);
                                        await storage.write(key: 'ownertel', value: articlebyCategory![index].user.phone);
                                        await storage.write(key: 'ownerId', value: articlebyCategory![index].user.id);
                                        await storage.write(key: 'ownerprofileImage', value: articlebyCategory![index].user.profileimgage);

                                        await storage.write(key: 'articleId', value: articlebyCategory![index].id);

                                        Navigator.pushReplacementNamed(context, Product.routeName);

                                      },
                                      child: Column(
                                          children: [
                                            Container(
                                                height: 163.h,
                                                width: 163.w,
                                                decoration: const BoxDecoration(
                                                    color: Colors.black12,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(15.0),
                                                      topRight: Radius.circular(15.0),
                                                    )
                                                ),
                                                child: Image.network("${Domain.dgaExpressPort}article/image?file=" + articlebyCategory![index].mainImage, fit: BoxFit.fill)
                                              //makeSlider(),
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
                                                  articlebyCategory![index].quantity.toString(),
                                                style: FontStyles.montserratRegular17().copyWith(
                                                    color: Colors.white,fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(Icons.date_range_rounded, size: 20),
                                        if(articlebyCategory![index].date != null)...[
                                          Text(" " + formattedDate,
                                            style: FontStyles.montserratRegular14().copyWith(
                                                color: const Color(0xFF34283E)
                                            ),
                                          ),
                                        ]
                                      ],
                                    ),
                                    Text(
                                        articlebyCategory![index].location,
                                      overflow: TextOverflow.ellipsis,
                                      style: FontStyles.montserratRegular17().copyWith(
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
                                      articlebyCategory![index].price.toString() + " " + currency,
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
                    ),
                  ],
                )
            )
          ),
          SizedBox(height: 20.0.h)
        ],
      ),
    );
  }
  Widget makeSlider2() {
    return CarouselSlider.builder(
        unlimitedMode: false,
        autoSliderDelay: const Duration(seconds: 5),
        enableAutoSlider: false,
        slideBuilder: (index) {
          return CachedNetworkImage(
            imageUrl: "${Domain.dgaExpressPort}article/image?file=" + results[index],
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
        //scrollDirection: Axis.horizontal,
        slideTransform: const DefaultTransform(),
        /*slideIndicator: CircularSlideIndicator(
          currentIndicatorColor: AppColors.lightGray,
          alignment: Alignment.bottomCenter,
          padding: EdgeInsets.only(bottom: 10.h, left: 20.0.w),
        ),*/
        itemCount: 1);
  }

  Widget _buildBottomSheet({BuildContext? context, Function()? onTap}) {
    return Container(
      width: double.infinity,
      height: 70.0.h,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0.r),
          topRight: Radius.circular(20.0.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context!, CheckOut.routeName);
              },
              child: const Icon(Icons.arrow_back)),
          AppButton.button(
            text: 'Add to cart',
            color: AppColors.secondary,
            height: 48.0.h,
            width: 215.0.w,
            onTap: onTap,
          ),
          const Icon(Icons.favorite_border),
        ],
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

  void checkItemInCart(item) async{
    if(articlesAdded.contains(item)){
      Fluttertoast.showToast(
          msg: 'Déjà dans le panier',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black38,
          textColor: Colors.white,
          fontSize: 20.0
      );
    }else{


    }
  }

  void deleteArticle(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('DELETE', Uri.parse('${Domain.dgaExpressPort}delete/article/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Fluttertoast.showToast(
          msg: "Announcement Deleted!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.amber,
          textColor: Colors.white,
          fontSize: 16.0
      );
      Navigator.pushReplacementNamed(context, Catalogue.routeName);
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
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
