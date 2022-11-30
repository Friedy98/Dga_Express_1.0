// ignore_for_file: equal_keys_in_map

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_shop/Screens/Catalogue/catalogue.dart';
import 'package:smart_shop/Screens/CheckOut/check_out.dart';
import 'package:smart_shop/Screens/Favorite/favorite.dart';
import 'package:smart_shop/Screens/Filter/filter.dart';
import 'package:smart_shop/Screens/Items/items.dart';
import 'package:smart_shop/Screens/Login/login.dart';
import 'package:smart_shop/Screens/Notifications/notifications.dart';
import 'package:smart_shop/Screens/Orders/order.dart';
import 'package:smart_shop/Screens/PrivacyPolicy/privacy_policy.dart';
import 'package:smart_shop/Screens/Product/product.dart';
import 'package:smart_shop/Screens/Profile/profile.dart';
import 'package:smart_shop/Screens/Settings/settings.dart';
import 'package:smart_shop/Screens/ShippingAddress/shipping_address.dart';
import 'package:smart_shop/Screens/SignUp/sign_up.dart';
import 'package:smart_shop/main.dart';
import 'package:smart_shop/screens/Services/AllAnnouncements.dart';
import 'package:smart_shop/screens/Services/Post_Article.dart';
import 'package:smart_shop/screens/Services/createAnnouncement.dart';
import 'package:smart_shop/screens/Services/Reserve_kilo.dart';
import 'package:smart_shop/screens/mainhome/mainhome.dart';

import '../../screens/Catalogue/articleByUser.dart';
import '../../screens/Home/HomePage.dart';
import '../../screens/Profile/currentuserProfile.dart';
import '../../screens/SearchPage.dart';
import '../../screens/Services/Message.dart';
import '../../screens/Services/MessagesArticles.dart';
import '../../screens/Services/StripePage.dart';
import '../../screens/Services/finishAnnReview.dart';
import '../../screens/Services/updateAnnouncement.dart';
import '../../screens/Services/updateArticle.dart';
import '../../screens/Services/updateReservation.dart';
import '../../screens/mainhome/Marketplace.dart';
import '../../screens/searchArticlePage.dart';

class AppConstants {
  static Map<String, Widget Function(dynamic)> appRoutes = {
    '/': (_) => MyApp(),
    login.routeName: (_) => const login(),
    mainhome.routeName: (_) =>  const mainhome(),
    Catalogue.routeName: (_) => const Catalogue(),
    Items.routeName: (_) => const Items(),
    Filter.routeName: (_) => const Filter(),
    Product.routeName: (_) => Product(),
    Favorite.routeName: (_) => const Favorite(),
    Profile.routeName: (_) => const Profile(),
    CheckOut.routeName: (_) => const CheckOut(),
    SignUp.routeName: (_) => const SignUp(),
    Settings.routeName: (_) => const Settings(),
    Orders.routeName: (_) => const Orders(),
    PrivacyPolicy.routeName: (_) => const PrivacyPolicy(),
    NotificationScreen.routeName: (_) => const NotificationScreen(),
    ShippingAddress.routeName: (_) => const ShippingAddress(),
    HomePage.routeName: (_) => const HomePage(),
    PostArticle.routeName: (_) => const PostArticle(),
    CreateAnnouncement.routeName: (_) => const CreateAnnouncement(),
    Reserve_kilo.routeName: (_) => const Reserve_kilo(),
    My_Posts.routeName: (_) => const My_Posts(),
    SearchPage.routeName: (_) => const SearchPage(),
    updateAnnouncement.routeName: (_) => const updateAnnouncement(),
    UpdateReservation.routeName: (_) => const UpdateReservation(),
    Messages.routeName: (_) => const Messages(),
    MyProfile.routeName: (_) => const MyProfile(),
    updateArticle.routeName: (_) => const updateArticle(),
    SearchArticlePage.routeName: (_) => const SearchArticlePage(),
    finishAnnReview.routeName: (_) => const finishAnnReview(),
    MessagesArticles.routeName: (_) => const MessagesArticles(),
    MarketPlace.routeName: (_) => const MarketPlace(),
    UserArticles.routeName: (_) => const UserArticles(),
    StripePage.routeName: (_) => const StripePage()
  };

  static setSystemStyling() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light,
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  static const privacyPolicyTxt =
      'Give your E-Commerce app an outstanding look.It\'s a small but attractive and beautiful design template for your E-Commerce App.Contact us for more amazing and outstanding designs for your apps.Do share this app with your Friends and rate us if you like this.Also check your other apps';
}
