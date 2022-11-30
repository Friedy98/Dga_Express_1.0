import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smart_shop/Utils/app_colors.dart';
import 'package:smart_shop/screens/Services/Another_animation.dart';
import 'package:smart_shop/screens/Services/delayed_animation.dart';

import 'package:smart_shop/screens/mainhome/mainhome.dart';

import 'dart:io' as plateform;
import 'package:http/http.dart' as http;

import '../../ListCategory.dart';
import '../../Screens/mainhome/Marketplace.dart';
import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../subinformation.dart';

class PostArticle extends StatefulWidget {
  static const String routeName = 'PostArticle';
  const PostArticle({Key? key}) : super(key: key);

  @override
  _PostArticleState createState() => _PostArticleState();
}

class _PostArticleState extends State<PostArticle> {

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
  String articleId = "";
  File? articlemainimage;
  List categories = [];
  bool isvalide = false;
  String currency = "";
  List<Subinformation>? subinformations;
  bool momo = false;
  bool creditCard = false;
  String paymentMethod = "";

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  List<ListCategory>? category;
  var isLoaded = false;
  bool showCategoies = false;

  void getUserData() async {
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
      subinformations = await getsubInfo();
      for(var i in subinformations!){
        setState(() {
          currency = i.currency;
        });
      }
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
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  pickImageFromGallery() async{
    final List<XFile>? pickedImages = await _picker.pickMultiImage();
    if (pickedImages!.isNotEmpty) {
      setState(() {
        imageFileList!.addAll(pickedImages);
        articlemainimage = File(imageFileList!.elementAt(0).path);
        isvalide = true;
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteLight,
        key: _key,
      appBar: AppBar(
        title: const Text('Ajouter un Article'),
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
      ),
      resizeToAvoidBottomInset: true,
      body: Container(
        margin: EdgeInsets.only(
            left: 10.0.w, right: 10.0.w, bottom: 10.h,top: 5.h),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AnotherDelayedAnimation(delay: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Choisir une Catégorie',
                        style: FontStyles.montserratRegular17().copyWith(color:
                        Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Icon(Icons.category, color: Colors.orange)
                  ],
                ),
            ),
            const SizedBox(height: 10),
            if(category != null)...[
              DelayedAnimation(delay: 300,
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
                        getCategoryById(category![index].id);
                        setState(() {
                          selected = index;
                        });
                      },
                    );
                  },
                ),
              ))
            ],
            _buildForm(context)
          ],
        )
      )
    );
  }

  TextEditingController articleName = TextEditingController();
  TextEditingController articlePrice = TextEditingController();
  TextEditingController articlePic = TextEditingController();
  TextEditingController articleQty = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController articleDescription = TextEditingController();
  TextEditingController currentdate = TextEditingController();
  TextEditingController paymentMethodController = TextEditingController();

  final storage = const FlutterSecureStorage();

  Widget _buildForm(BuildContext context) {
    return Form(
        key: _formKey,
      child: Expanded(
          child: ListView(
            padding: const EdgeInsets.all(10.0),
            children: [
              DelayedAnimation(delay: 300,
                  child: TextFormField(
                    controller: currentdate,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
                      labelText: 'Date d\'Aujourdh\'hui',
                      icon: const Icon(Icons.date_range_rounded),
                    ),
                    readOnly: true,
                  ),
              ),

              DelayedAnimation(delay: 400,
                  child: TextFormField(
                    controller: articleName,
                    decoration: const InputDecoration(
                        hintText: 'Nom de l\'article',
                        labelText: 'Nom de l\'article',
                        icon: Icon(Icons.drive_file_rename_outline)
                    ),
                    maxLength: 15,
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field Required";
                      }
                      return null;
                    },
                  ),
              ),

              DelayedAnimation(delay: 500,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 150,
                          child: TextFormField(
                            controller: articlePrice,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: const InputDecoration(
                                hintText: 'prix',
                                labelText: 'Prix',
                                icon: Icon(Icons.price_check)
                            ),
                            validator: (inputValue){
                              if(inputValue!.isEmpty){
                                return "Field Required";
                              }
                              return null;
                            },
                          )
                      ),
                      SizedBox(width: 10.w),
                      Text(currency,
                          style: FontStyles.montserratRegular17().copyWith(color:
                          Colors.deepOrange, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ),

              const SizedBox(height: 15.0),
              DelayedAnimation(delay: 600,
                  child: TextFormField(
                    controller: articleQty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                        hintText: 'Quantité',
                        labelText: 'Quantité',
                        icon: Icon(Icons.production_quantity_limits)
                    ),
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field Required";
                      }
                      return null;
                    },
                  ),
              ),

              const SizedBox(height: 15.0),
              DelayedAnimation(delay: 700,
                  child: TextFormField(
                    controller: location,
                    decoration: const InputDecoration(
                        hintText: 'Localisation',
                        labelText: 'Lieu',
                        icon: Icon(Icons.location_pin)
                    ),
                    validator: (inputValue){
                      if(inputValue!.isEmpty){
                        return "Field Required";
                      }
                      return null;
                    },
                  ),
              ),
              const SizedBox(height: 15.0),
              DelayedAnimation(delay: 800,
                  child: TextFormField(
                    controller: articleDescription,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
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
                  )
              ),
              const SizedBox(height: 15.0),
              DelayedAnimation(delay: 800,
                  child: Center(
                    child: Text("Moyen de Paiement",
                        style: FontStyles.montserratRegular17().copyWith(
                            color: const Color(0xFF34283E), fontWeight: FontWeight.bold)),
                  )
              ),
              DelayedAnimation(delay: 900,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.attach_money_rounded),
                          SizedBox(width: 5.0.w),
                          Text("Mobile Money",
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: const Color(0xFF34283E))),
                          Checkbox(
                            value: momo,
                            onChanged: (value) {
                              setState(() {
                                momo = !momo;
                                creditCard = false;
                              });
                            },
                          ),
                        ],
                      ),
                      if(momo)...[
                        IntlPhoneField(
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            hintText: '+237 655333333',
                            labelText: 'Téléphone',
                            icon: const Icon(Icons.phone),
                          ),
                          initialCountryCode: 'IN',
                          onChanged: (phone) {
                            String phoneNumber = phone.completeNumber;
                            paymentMethod = "Mobile Money";
                            paymentMethodController.text = phoneNumber;
                          },
                        ),
                      ]
                    ],
                  )
              ),
              DelayedAnimation(delay: 1000,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.credit_card_sharp),
                          SizedBox(width: 5.0.w),
                          Text("Carte Bancaire",
                              style: FontStyles.montserratRegular14().copyWith(
                                  color: const Color(0xFF34283E))),
                          Checkbox(
                            value: creditCard,
                            onChanged: (value) {
                              setState(() {
                                creditCard = !creditCard;
                                momo = false;
                              });
                            },
                          ),
                        ],
                      ),
                      if(creditCard)...[
                        TextFormField(
                          controller: paymentMethodController,
                          autofocus: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                            hintText: 'Votre IBAN',
                            labelText: 'Votre IBAN',
                            //icon: CardUtils.getCardIcon(_paymentCard.type),
                          ),
                          //validator: CardUtils.validateCardNumWithLuhnAlgorithm,
                        ),
                      ]
                    ],
                  )
              ),
              const SizedBox(height: 25.0),
              DelayedAnimation(delay: 1100,
                  child: Row(
                    children: [
                      Container(
                          width: 250.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.white70,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GridView.builder(
                                        itemCount: imageFileList!.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3
                                        ),
                                        itemBuilder: (BuildContext context, int index) {
                                          return Image.file(File(imageFileList![index].path), fit: BoxFit.cover);
                                        }
                                    ),
                                  )
                              )
                            ],
                          )
                      ),
                      IconButton(
                          onPressed: (){
                            pickImageFromGallery();
                          },
                          icon: const Icon(Icons.add_a_photo, size: 50,)),
                    ],
                  )
              ),
              const SizedBox(height: 20.0),
              DelayedAnimation(delay: 1200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(120, 30),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),),
                          onPressed: () async{
                            if(isvalide) {
                              if (_formKey.currentState?.validate() ?? false) {
                                setState(() => isloading = true);
                                Fluttertoast.showToast(
                                    msg: "This will take a moment...",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 2,
                                    backgroundColor: Colors.grey,
                                    textColor: Colors.white,
                                    fontSize: 20.0
                                );
                                await postArticle();
                                //print(date);
                                setState(() => isloading = false);
                              } else {
                                setState(() {
                                  isValidForm = false;
                                });
                              }
                            }else{
                              Fluttertoast.showToast(
                                  msg: "Ajoutez au moin une photo!",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 2,
                                  backgroundColor: Colors.grey,
                                  textColor: Colors.white,
                                  fontSize: 20.0
                              );
                            }
                          },
                          child: (isloading)
                              ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 1.5,
                              ))
                              : const Text('Valider')
                      ),
                    ],
                  )
              )
            ],
          )
      )
    );
  }

  postArticle() async{

    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('POST', Uri.parse('${Domain.dgaExpressPort}add/article'));
    request.body = json.encode({
      "name": articleName.text,
      "description": articleDescription.text,
      "price": articlePrice.text,
      "quantity": articleQty.text,
      "mainImage": "string",
      "status": "ENABLED",
      "date": currentdate.text,
      "location": location.text,
      "paymentMethod": paymentMethodController.text,
      "user": {
        "id": currentUserId,
        "firstName": firstName,
        "lastName": lastName,
        "profileimgage": null,
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
        "user": {
          "id": categoryadminId,
          "firstName": categoryadminFN,
          "lastName": categoryadminLN,
          "profileimgage": "string",
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
      final data = await response.stream.bytesToString();
      setState(() {
        articleId = json.decode(data)['id'];
      });
      print(articleId);
      for(var a in imageFileList!){
        uploadPictures(a, articleId);
      }

    }else if(response.statusCode == 403){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15.0))),
              content: Padding(
                padding: const EdgeInsets.all(2.0),
                child: SizedBox(
                  width: 300.0.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 70,color: Colors.grey),
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(text: "An error occured!",
                                style: FontStyles.montserratRegular19().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                            TextSpan(text: "\nPlease make sure you selected a Cathegory for your product",
                                style: FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                          ],

                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              child: Text('OK',
                                  style: FontStyles.montserratRegular17().copyWith(color: Colors.grey)),
                              onTap: (){
                                Navigator.of(context, rootNavigator: true).pop();
                              }
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            );
          });
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

  Future mainPicture(File? mainimage, String articleId) async{

    String? accesstoken = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accesstoken'
    };
    var request = http.MultipartRequest('PUT', Uri.parse('${Domain.dgaExpressPort}upload/main/article/image'));
    request.fields.addAll({
      'articleId': articleId
    });
    request.files.add(await http.MultipartFile.fromPath('file', mainimage!.path));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await response.stream.bytesToString();

      Fluttertoast.showToast(
          msg: "Article Créé avec Succes",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );

      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.fade,duration: const Duration(milliseconds: 300),
            child: const MarketPlace()),
      );

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);

      MotionToast.error(
        description:  Text("Photo : $errorMessage" , style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        width:  300,
        height: 90,
      ).show(context);

    }
  }

  void uploadPictures(XFile xFile, String articleId) async{
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
      await mainPicture(articlemainimage, articleId);

    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      debugPrint(errorMessage);

      MotionToast.error(
        title:  Text("Erreur!!!", style: FontStyles.montserratRegular17().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
        description:  Text("Vérifiez votre connexion au serveur", style: FontStyles.montserratRegular14().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold)),
      ).show(context);

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

      debugPrint(categoryName + " " + categoryadminFN);
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

class CreditCardNumberFormater extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' '); // Add double spaces.
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}