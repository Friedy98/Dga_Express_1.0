import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Catalogue/catalogue.dart';

import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../ListCategory.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
//import '../PopupWidget/PopupLogin.dart';

class updateArticle extends StatefulWidget {
  static const String routeName = 'updateArticle';
  const updateArticle({Key? key}) : super(key: key);

  @override
  _updateArticleState createState() => _updateArticleState();
}

class _updateArticleState extends State<updateArticle> {

  int? selected;
  bool showbackArrow = true;
  bool isValidForm = false;
  bool isloading = false;
  String firstName = "";
  String lastName = "";
  String pseudo = "";
  String email = "";
  String currentUserId = "";
  String phone = "";
  String location = "";
  String articleImage = "";
  int? price = 0;
  int? quantity = 0;

  String categoryId = "";
  String categoryName = "";
  String categoryDescription = "";
  String categoryadminId = "";
  String categoryadminFN = "";
  String categoryadminLN = "";
  String categoryadminEm = "";
  String categoryadminPs = "";
  String categoryadminPh = "";
  String date = "";
  List results = [];

  String articleId = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<ListCategory>? category;
  var isLoaded = false;
  bool showCategoies = false;

  void getUserData() async {
    articleId = (await storage.read(key: 'articleId'))!;
    getarticleById(articleId);
    category = await getAllCategory();
    final profileData = await storage.read(key: 'Profile');

    date = DateTime.now().toString();
    var dateParse = DateTime.parse(date);
    var formattedDate = "${dateParse.day}/${dateParse.month}/${dateParse.year}";
    currentdate.text = formattedDate;
    setState(() {
      currentUserId = json.decode(profileData!)['id'];
      firstName = json.decode(profileData)['firstName'];
      lastName = json.decode(profileData)['lastName'];
      pseudo = json.decode(profileData)['pseudo'];
      phone = json.decode(profileData)['phone'];
      email = json.decode(profileData)['email'];
    });
    if(mounted) {
      if (category != null) {
        setState(() {
          isLoaded = true;
        });
      }
    }
  }

  List<XFile>? imageFileList = [];
  final _picker = ImagePicker();
  final GlobalKey <FormState> _formKey = GlobalKey <FormState> ();

  pickImageFromGallery() async{
    final List<XFile>? pickedImages = await _picker.pickMultiImage(imageQuality: 25);
    if (pickedImages!.isNotEmpty) {
      setState(() {
        imageFileList!.addAll(pickedImages);
      });
    }
  }

  TextEditingController articleName = TextEditingController();
  TextEditingController articlePrice = TextEditingController();
  TextEditingController articlePic = TextEditingController();
  TextEditingController articleQty = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController articleDescription = TextEditingController();
  TextEditingController currentdate = TextEditingController();
  final storage = const FlutterSecureStorage();

  Color colorContainer = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteLight,
        appBar: AppBar(
          title: const Text('Mettre à jour un Article'),
          leading: IconButton(
            icon: plateform.Platform.isIOS ? Icon(Icons.arrow_back_ios)  : Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.push(
                context,
                PageTransition(type: PageTransitionType.fade,duration: const Duration(seconds: 1),
                    child: const Catalogue()),
              );
            },
          ),
        ),
        resizeToAvoidBottomInset: true,
        body:Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Select Category',
                      style: FontStyles.montserratRegular17().copyWith(color:
                      Colors.orange, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  const Icon(Icons.category, color: Colors.orange)
                ],
              ),
              const SizedBox(height: 10),
              if(category != null)...[
                SizedBox(
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
                              getCategoryById(category![index].id);
                              setState(() {
                                selected = index;
                              });
                            },
                          );
                        },
                      ),
                )
              ],
              _buildForm(context)
            ],
          )
        )
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
        key: _formKey,
      child: Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              TextFormField(
                controller: currentdate,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                  labelText: 'Current Date',
                  icon: const Icon(Icons.date_range_rounded),
                ),
                readOnly: true,
              ),
              TextFormField(
                controller: articleName,
                decoration: const InputDecoration(
                    hintText: 'article name',
                    labelText: 'Article Name',
                    icon: Icon(Icons.drive_file_rename_outline)
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty){
                    return "Field Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: articleDescription,
                keyboardType: TextInputType.multiline,
                minLines: 1,//Normal textInputField will be displayed
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'description',
                    labelText: 'Description',
                    icon: Icon(Icons.description)
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty){
                    return "Field Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: articlePrice,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    hintText: 'price',
                    labelText: 'Price',
                    icon: Icon(Icons.price_check)
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty){
                    return "Field Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: articleQty,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                    icon: Icon(Icons.production_quantity_limits)
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty){
                    return "Field Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                    hintText: 'Location',
                    labelText: 'Location',
                    icon: Icon(Icons.location_pin)
                ),
                validator: (inputValue){
                  if(inputValue!.isEmpty){
                    return "Field Required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(120, 30),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),),
                      onPressed: () async{
                        setState(() => isloading = true);
                        await updatethisArticle();
                        setState(() => isloading = false);
                      },
                      child: (isloading)
                          ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 1.5,
                          ))
                          : const Text('Confirmer')
                  ),
                ],
              )
            ],
          )
      )
    );
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
        articleName.text = json.decode(data)['name'];
        articleDescription.text = json.decode(data)['description'];
        price = json.decode(data)['price'];
        quantity = json.decode(data)['quantity'];
        locationController.text = json.decode(data)['location'];
        articleImage = json.decode(data)['mainImage'];
        articlePrice.text = price.toString();
        articleQty.text = quantity.toString();
      });
    }
    else {
      print(response.reasonPhrase);
    }

  }

  void getCategoryById(String id) async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/cathegories/$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      Map<String, dynamic> senderDto = json.decode(data);
      //print(senderDto["userDto"]);
      categoryId = senderDto["id"];
      categoryName = senderDto["name"];
      categoryDescription = senderDto["description"];
      categoryadminFN = senderDto["user"]["firstName"];
      categoryadminLN = senderDto["user"]["lastName"];
      categoryadminPs = senderDto["user"]["pseudo"];
      categoryadminEm = senderDto["user"]["email"];
      categoryadminId = senderDto["user"]["id"];

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

    }
    else {
      print(response.reasonPhrase);
    }
  }

  updatethisArticle() async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('PUT', Uri.parse('${Domain.dgaExpressPort}update/article/'));
    request.body = json.encode({
      "id": articleId,
      "name": articleName.text,
      "description": articleDescription.text,
      "price": articlePrice.text,
      "quantity": articleQty.text,
      "mainImage": articleImage,
      "status": "ENABLED",
      "date": currentdate.text,
      "location": locationController.text,
      "user": {
        "id": currentUserId,
        "firstName": firstName,
        "lastName": lastName,
        "profileimgage": "",
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
        "stars": 0
      },
      "cathegory": {
        "id": categoryId,
        "name": categoryName,
        "description": categoryDescription,
        "status": "ENABLED",
        "user": {
          "id": categoryadminId,
          "firstName": categoryadminFN,
          "lastName": categoryadminLN,
          "profileimgage": "",
          "pseudo": categoryadminPs,
          "email": categoryadminEm,
          "phone": categoryadminPh,
          "roleDtos": [
            {
              "id": 1,
              "name": "ROLE_EMPLOYEE"
            }
          ],
          "password": "string",
          "status": "ENABLED",
          "stars": 0
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();
      Fluttertoast.showToast(
          msg: "Article Updated Sucessfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );
      Navigator.pop(context);

    }else if(response.statusCode == 403){
      Fluttertoast.showToast(
          msg: "Something Went Wrong!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 20.0
      );
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

  getAllCategory() async{

    var headers = {
      'Content-Type': 'application/json'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}cathegories'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List results = json.decode(data);

      return results.map((data) => ListCategory.fromJson(data)).toList();
    }
    else {
      print(response.reasonPhrase);
    }
  }
}
