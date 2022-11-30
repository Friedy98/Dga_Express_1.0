
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/screens/Cart/cart.dart';
import 'package:smart_shop/screens/Services/Post_Article.dart';

import '../../Screens/Catalogue/catalogue.dart';
import '../Services/MyMessages.dart';

class MarketPlace extends StatefulWidget {
  const MarketPlace({Key? key}) : super(key: key);
  static const String routeName = 'MarketPlace';

  @override
  _MarketPlaceState createState() => _MarketPlaceState();
}

class _MarketPlaceState extends State<MarketPlace> {
  int currentIndex = 0;
  bool isLoggedIn = false;
  final storage = const FlutterSecureStorage();

  List<Widget> myScreens = [
    const Catalogue(),
    const MyMessages(),
    const PostArticle(),
    const Cart()
  ];

  @override
  void initState() {
    super.initState();
    checkUser();
  }
  void checkUser()async{
    final token = await storage.read(key: "accesstoken");
    if(mounted) {
      if (token != null) {
        setState(() {
          isLoggedIn = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: myScreens.elementAt(currentIndex),
      bottomSheet: isLoggedIn ? _buildBottomSheet() : null,
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildBottomSheet() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          width: 300.w,
          height: 50.0.h,
          decoration: BoxDecoration(
            color: Colors.orange,
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
                  setState(() {
                    currentIndex = 0;
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.home ,
                      color: currentIndex == 0
                          ? Colors.cyanAccent
                          : Colors.white,
                    ),
                    Text(
                      'Tous',
                      style: TextStyle(
                        color: currentIndex == 0
                            ? Colors.cyanAccent
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.message ,
                      color: currentIndex == 1
                          ? Colors.cyanAccent
                          : Colors.white,
                    ),
                    Text(
                      'Messages',
                      style: TextStyle(
                        color: currentIndex == 1
                            ? Colors.cyanAccent
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                          child: const PostArticle()),
                    );
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.point_of_sale_rounded ,
                      color: currentIndex == 2
                          ? Colors.cyanAccent
                          : Colors.white,
                    ),
                    Text(
                      'Vendre',
                      style: TextStyle(
                        color: currentIndex == 2
                            ? Colors.cyanAccent
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    Navigator.push(
                      context,
                      PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
                          child: const Cart()),
                    );
                  });
                },
                child: Column(
                  children: [
                    Icon(
                      Icons.shopping_cart ,
                      color: currentIndex == 3
                          ? Colors.cyanAccent
                          : Colors.white,
                    ),
                    Text(
                      'Panier',
                      style: TextStyle(
                        color: currentIndex == 3
                            ? Colors.cyanAccent
                            : Colors.white,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

