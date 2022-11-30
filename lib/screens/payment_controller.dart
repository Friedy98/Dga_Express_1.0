import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;

  PaymentMethod? paymentMethod;

  Future<void> makePayment(
      {required String amount, required String currency, required String clientId}) async {
    try {
      paymentIntentData = await createPaymentIntent(amount, currency, clientId);

      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              customFlow: true,
              merchantDisplayName: 'DGA_EXPRESS',
              customerId: paymentIntentData!['customer'],
              paymentIntentClientSecret: paymentIntentData!['client_secret'],
              customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
              appearance: const PaymentSheetAppearance(
                colors: PaymentSheetAppearanceColors(
                  background: Colors.white,
                  primary: Colors.green,
                  componentBorder: Colors.lightBlueAccent,
                ),
                shapes: PaymentSheetShape(
                  borderWidth: 4,
                  shadow: PaymentSheetShadowParams(color: Colors.red),
                ),
              )
            ));
        //print(paymentIntentData!['customer']);
        displayPaymentSheet();
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      paymentIntentData = null;
      /*Fluttertoast.showToast(
          msg: "Payment Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 20.0
      );*/

    } on Exception catch (e) {
      if (e is StripeException) {
        print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        print("Unforeseen error: ${e}");
      }
    } catch (e) {
      print("exception is :$e");
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency, String clientId) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'customer':clientId,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization': 'Bearer sk_test_51LjiQQCZjIzC8XowwibBwvo0gxAvqYEOPaJRp8CAaXok9ZgjIau2mv5ntcScpulJ5E8d5hqzWu9odNTxR40E3tSq000zxFgGDf',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
        body: body,
      );
      print(jsonDecode(response.body));
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }

  void _handlePayPress() async{
    await Stripe.instance.confirmPayment(
      paymentIntentData!['client_secret'],
      PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(

        ),
      ),
    );
  }
}