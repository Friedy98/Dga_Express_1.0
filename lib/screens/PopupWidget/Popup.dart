import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smart_shop/screens/Services/Reserve_kilo.dart';

import '../../Utils/font_styles.dart';
import '../../main.dart';
import '../ListReservations.dart';
import 'package:http/http.dart' as http;

class PopupWidget extends StatefulWidget {
  const PopupWidget({Key? key}) : super(key: key);

  @override
  _PopupWidgetState createState() => _PopupWidgetState();
}

class _PopupWidgetState extends State<PopupWidget>{

  final storage = const FlutterSecureStorage();
  bool isCurrentUserPost = true;
  bool actionBtn = false;

  @override
  void initState(){
    super.initState();
    getAnnDataPopup();
  }

  String departureDate = "";
  String arrivaldate = "";
  String departuretown = "";
  String destinationtown = "";
  bool computer = false;
  bool document = false;
  int? price = 0;
  int? quantity = 0;
  String restriction = "";
  String paymentMethod = "";
  String announcementId = "";

  String id = "";
  String ownerId = "";
  bool isReadmore= false;

  void getAnnDataPopup() async {
    final announcementData = await storage.read(key: 'AnnouncementId');
    ownerId = (await storage.read(key: 'ownerId'))!;
    final profileData = await storage.read(key: 'Profile');
    if(mounted) {
      setState(() {
        departureDate = json.decode(announcementData!)['arrivaldate'];
        arrivaldate = json.decode(announcementData)['arrivaldate'];
        departuretown = json.decode(announcementData)['departuretown'];
        destinationtown = json.decode(announcementData)['destinationtown'];
        document = json.decode(announcementData)['document'];
        computer = json.decode(announcementData)['computer'];
        quantity = json.decode(announcementData)['quantity'];
        price = json.decode(announcementData)['price'];
        restriction = json.decode(announcementData)['restriction'];
        announcementId = json.decode(announcementData)['id'];
        paymentMethod = json.decode(announcementData)['paymentMethod'];

        id = json.decode(profileData!)['id'];

        if(ownerId == id){
          isCurrentUserPost = false;
          actionBtn = true;
        }
      });
    }
  }

  Future getMyReservations(String id) async{
    String? token = await storage.read(key: "accesstoken");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var request = http.Request('GET', Uri.parse('${Domain.dgaExpressPort}user/$id/reservations'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final data = await response.stream.bytesToString();

      List myReservation = json.decode(data);
      //print(data);
      myReservation.reversed;

      return myReservation.map((data) => ListReservation.fromJson(data)).toList();

    }else if(response.statusCode == 403){
      await response.stream.bytesToString();
    }
    else {
      final error = await response.stream.bytesToString();
      var errorMessage = json.decode(error)["error"];
      print(errorMessage);
    }
  }

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      scrollable: true,
      backgroundColor: Colors.grey[200],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("Departure Date",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(departureDate.toString(),
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text("Arrival Date",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(arrivaldate.toString(),
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin_drop, color: Colors.red),
            title: Text("Departure Town",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(departuretown,
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.pin_drop,color: Colors.red),
            title: Text("Arrival Town",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(destinationtown,
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          if(document)...[
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text("Document",style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("Yes",
                style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black),
              ),
            ),]else...[
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: Text("Document",style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("No",
                style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black),
              ),
            )
          ],
          if(computer)...[
            ListTile(
              leading: const Icon(Icons.laptop_mac),
              title: Text("Computer",style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("Yes",
                style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black),
              ),
            ),]else...[
            ListTile(
              leading: const Icon(Icons.laptop_mac),
              title: Text("Computer",style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
              subtitle: Text("No",
                style:
                FontStyles.montserratRegular14().copyWith(color: Colors.black),
              ),
            )
          ],
          ListTile(
            leading: const Icon(Icons.production_quantity_limits),
            title: Text("Quantity",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(quantity.toString(),
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.attach_money_rounded),
            title: Text("Price per Kilo",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(price.toString(),
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_sharp),
            title: Text("Moyen de Paiement",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(paymentMethod,
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text("Restriction",style:
            FontStyles.montserratRegular14().copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
            subtitle: Text(restriction,
              style:
              FontStyles.montserratRegular14().copyWith(color: Colors.black),
              overflow: isReadmore ? TextOverflow.visible: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Container(
                    width: 100,
                    height: 35,
                    decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                    child:  Center(
                      child: Text('Close',
                          style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),

                    )),
              ),
              Visibility(
                visible: isCurrentUserPost,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Reserve_kilo.routeName);
                  },
                  child: Container(
                      width: 100,
                      height: 35,
                      decoration: const BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.all(Radius.circular(8.0))),
                      child:  Center(
                        child: Text('Reserv',
                            style: FontStyles.montserratRegular14().copyWith(color: Colors.white)),

                      )
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}