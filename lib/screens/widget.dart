import 'package:flutter/material.dart';

MaterialButton longButtons(String title, Function fun,
      { Color color: Colors.orangeAccent, Color textColor: Colors.white}){
  return MaterialButton(
    onPressed: () => fun,
    textColor: textColor,
    color: color,
    child: SizedBox(
      width: double.infinity,
      child: Text(
        title,
      textAlign: TextAlign.center,
    ),
    ),
    height: 45,
    minWidth: 600,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10))),
    );
}