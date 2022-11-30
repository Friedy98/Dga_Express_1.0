import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/updateArticle.dart';
import 'dart:io' as plateform;

import '../../Screens/Services/delayed_animation.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../ListArticles.dart';
import 'package:http/http.dart' as http;

import '../mainhome/mainhome.dart';
import '../subinformation.dart';
import 'Another_animation.dart';
import 'Post_Article.dart';

class MySales extends StatefulWidget {
  static const String routeName = 'MySales';
  const MySales({Key? key}) : super(key: key);

  @override
  MySalesState createState() => MySalesState();
}

class MySalesState extends State<MySales> {

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  bool showbackArrow = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
      key: _key,
      appBar: AppBar(
        title: const Text('Mes Ventes'),
        leading: IconButton(
          icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(
              context,
              PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                  child: const mainhome()),
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: (){

                Navigator.push(
                  context,
                  PageTransition(type: PageTransitionType.topToBottom,duration: const Duration(milliseconds: 500),
                      child: const PostArticle()),
                );

              },
              icon: const Icon(Icons.add_circle_rounded),
          )
        ],
      ),
      resizeToAvoidBottomInset: false,
      body:  _bodybuilder(context),
    );
  }
  List<ListArticles>? myArticles;
  bool isLoaded = false;
  bool isnotLoaded = false;
  final storage = const FlutterSecureStorage();
  bool isFavorite = false;
  String userId = "";
  List results = [];
  String mainImage = "";
  List<Subinformation>? subinformations;
  String currency = "";
  String articleId = "";

  @override
  void initState(){
    super.initState();
    getArticleData();
  }

  Future getArticleData()async{
    final profileData = await storage.read(key: 'Profile');
    userId= json.decode(profileData!)["id"];
    myArticles = await getmyArticles(userId);
    if (mounted){

      subinformations = await getsubInfo();
      for(var i in subinformations!){
        setState(() {
          currency = i.currency;
        });
      }
      if(myArticles != null){
        setState(() {
          isLoaded = true;
        });
      }else {
        setState(() {
          isnotLoaded = true;
        });
      }
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

  List<XFile>? imageFileList = [];
  final _picker = ImagePicker();

  pickImageFromGallery(String articleId) async{
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages!.isNotEmpty) {
      setState(() {
        imageFileList!.addAll(pickedImages);
      });
      for(var a in imageFileList!){
        await uploadPictures(a, articleId);
        Navigator.push(
          context,
          PageTransition(type: PageTransitionType.fade, child: const MySales()),
        );
      }
    }
  }

  Future uploadPictures(XFile xFile, String articleId) async{
    String? accesstoken = await storage.read(key: "accesstoken");
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };

    var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Domain.dgaExpressPort}upload/article/images/$articleId'));
    request.files.add(await http.MultipartFile.fromPath('file',
        xFile.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Fluttertoast.showToast(
          msg: "Image added!",
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

  Widget _bodybuilder(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Visibility(
            visible: isLoaded,
            child: Expanded(
              child: ListView.builder(
                  itemCount: myArticles?.length,
                  itemBuilder: (context, index) {

                    return AnotherDelayedAnimation(delay: 300,
                        child:Container(
                      margin: EdgeInsets.only(
                          left: 5.0.w, right: 5.0.w, bottom: 5.h,top: 5.h),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white60,
                        border: Border.all(
                            color: Colors.grey,
                            width: 3
                        ),
                      ),
                      child: DelayedAnimation(delay: 500,
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  height: 160.h,
                                  width: 163.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Image.network("${Domain.dgaExpressPort}article/image?file=" + myArticles![index].mainImage)
                                //makeSlider(),
                              ),
                              RichText(
                                overflow: TextOverflow.ellipsis,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(text: myArticles![index].name,
                                        style: FontStyles.montserratRegular19().copyWith(color: Colors.blue, fontWeight: FontWeight.bold)),
                                    TextSpan(text: "\nLe " + myArticles![index].date,
                                        style: FontStyles.montserratRegular14().copyWith(color: Colors.black)),
                                    TextSpan(text: " \n" + myArticles![index].price.toString() + " " + currency,
                                        style: FontStyles.montserratRegular17().copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
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
                                    Text(myArticles![index].quantity.toString(),
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
                                    backgroundColor: Colors.grey,
                                    onPressed: ()async{
                                      results = await getimages(myArticles![index].id);
                                      mainImage = myArticles![index].mainImage;
                                      articleId = myArticles![index].id;
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      GestureDetector(
                                                        child: const CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor: Colors.grey,
                                                          child: Icon(
                                                            Icons.close,color: Colors.white,
                                                          ),
                                                        ),
                                                        onTap: (){
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                      SizedBox(width: 10.w),
                                                      GestureDetector(
                                                        child: const CircleAvatar(
                                                          radius: 20,
                                                          backgroundColor: Colors.blue,
                                                          child: Icon(
                                                            Icons.add_a_photo_rounded,color: Colors.white,
                                                          ),
                                                        ),
                                                        onTap: (){
                                                          pickImageFromGallery(myArticles![index].id);
                                                        },
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Expanded(
                                                    child: ListView.builder(
                                                        itemCount: results.length,
                                                        padding: const EdgeInsets.all(20),
                                                        itemBuilder: (context, index) {
                                                          return Container(
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white54,
                                                                  borderRadius: BorderRadius
                                                                      .circular(
                                                                      5)
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  if(results[index] !=
                                                                      mainImage)...[
                                                                    Align(
                                                                      alignment: Alignment.topRight,
                                                                      child: GestureDetector(
                                                                        child: const CircleAvatar(
                                                                          radius: 20,
                                                                          backgroundColor: Colors.red,
                                                                          child: Icon(
                                                                            Icons.delete,color: Colors.white,
                                                                          ),
                                                                        ),
                                                                        onTap: (){
                                                                          var name = "";
                                                                          var count = 0;
                                                                          int i;
                                                                          for(i = 0; i<results[index].length; i++) {
                                                                            if (count ==
                                                                                7) {
                                                                              name =
                                                                                  name +
                                                                                      results[index][i];
                                                                            }
                                                                            if (results[index][i] ==
                                                                                "/") {
                                                                              count =
                                                                                  count +
                                                                                      1;
                                                                            }
                                                                          }
                                                                          deleteImage(articleId, name);
                                                                        },
                                                                      ),
                                                                    ),
                                                                    Image
                                                                        .network(
                                                                        "${Domain.dgaExpressPort}article/image?file=" +
                                                                            results[index],
                                                                        fit: BoxFit
                                                                            .fill),
                                                                    const Divider(color: Colors.black)
                                                                  ],
                                                                ], //const Divider(color: Colors.grey)
                                                              )
                                                          );
                                                        }),
                                                  )
                                                ]
                                              )
                                            );
                                          });
                                    },
                                    tooltip: 'Increment',
                                    child: const Icon(Icons.image_search_outlined, color: Colors.white),
                                  ),
                                  FloatingActionButton(
                                    heroTag: null,
                                    backgroundColor: Colors.blue,
                                    onPressed: ()async{
                                      await storage.write(key: 'articleId', value: myArticles![index].id);
                                      Navigator.pushReplacementNamed(context, updateArticle.routeName);
                                    },
                                    child: const Icon(Icons.update),
                                  ),
                                  FloatingActionButton(
                                    backgroundColor: Colors.deepOrange,
                                    heroTag: null,
                                    onPressed: (){
                                      deleteArticle(myArticles![index].id);
                                    },
                                    child: const Icon(Icons.delete),
                                  )
                                ],
                              )
                            ],
                          ),
                          InkWell(
                            onTap: (){ setState(() {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                        scrollable: true,
                                        shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                                      content: Column(
                                        children: [
                                          Text(myArticles![index].name,
                                            overflow: TextOverflow.ellipsis,
                                            style: FontStyles.montserratRegular17().copyWith(
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const Divider(color: Colors.grey),
                                          ListTile(
                                            leading: const Icon(Icons.location_pin, color: Colors.red),
                                            title: Text(myArticles![index].location,
                                                //overflow: TextOverflow.ellipsis,
                                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                          ),
                                          ListTile(
                                            title: Text("Specifications",
                                                //overflow: TextOverflow.ellipsis,
                                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black,fontWeight: FontWeight.bold)),
                                            subtitle: Text(myArticles![index].description,
                                              style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                                          ),
                                        ],
                                      )
                                    );
                                  });
                            });
                              },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: const [
                                Text("Show More",style: TextStyle(color: Colors.blue)),
                                Icon(Icons.expand_more_rounded)
                              ],
                            ),
                          ),
                          ]
                      )
                    )));
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
            visible: isnotLoaded,
            child: Center(
              child: Text('Pas de Resultat',style:
              FontStyles.montserratRegular14().copyWith(color: Colors.grey)),
            )
        )
      ],
    );
  }

  bool isValidForm = false;

  Future getmyArticles(String userId) async{

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
      //print(data);
      return results.map((data) => ListArticles.fromJson(data)).toList();
    }
    if(response.statusCode == 403){

      MotionToast.warning(
          description:  Text("Votre séssion à expiré", style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);
      await storage.delete(key: 'accesstoken');
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
      final articleImages = await response.stream.bytesToString();
      return json.decode(articleImages);
      //print(results);

    }
    else {
      print(response.reasonPhrase);
    }
  }

  void deleteImage(String id, String name) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}delete/article/$id/image/$name'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();

      Navigator.pop(context);
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
      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade, child: const MySales()),
      );

      MotionToast.delete(
          description:  Text("Article Supprimé!", style: FontStyles.montserratRegular19().copyWith(
              color: Colors.black))
      ).show(context);

      //Navigator.pushReplacementNamed(context, Catalogue.routeName);
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
