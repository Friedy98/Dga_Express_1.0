
import 'package:flutter/material.dart';
import '../../Utils/font_styles.dart';
import '../Services/AllAnnouncements.dart';

class PopupWidgetSearchError extends StatefulWidget {
  const PopupWidgetSearchError({Key? key}) : super(key: key);

  @override
  _PopupWidgetSearchErrorState createState() => _PopupWidgetSearchErrorState();
}

class _PopupWidgetSearchErrorState extends State<PopupWidgetSearchError>{

  @override
  Widget build(BuildContext context){
    return Dialog(
      backgroundColor: Colors.grey[300],
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, color: Colors.grey,size: 70),
                  const SizedBox(width: 15),
                  Text("No Results found!",style:
                  FontStyles.montserratRegular17().copyWith(color: Colors.black)),
                ],
              ),
            ),
            const Divider(color: Colors.grey),
            GestureDetector(
              onTap: ()async{
                Navigator.pushReplacementNamed(
                    context, My_Posts.routeName);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("OK", style:
                  FontStyles.montserratRegular17().copyWith(color: Colors.red)),
                ],
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
    );
  }
}