import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
class RazorpayPage extends StatefulWidget {
  const RazorpayPage({super.key});
  @override
  State<RazorpayPage> createState() => _RazorpayPageState();
}

class _RazorpayPageState extends State<RazorpayPage> {

  late Razorpay _razorpay;
  TextEditingController amountcontroller = TextEditingController();

  void opencheckout(amount) async {
    amount = amount * 100;
    var options = {
      'key': 'rzp_test_TzE5sr7rIDH2AV',
      'amount': amount,
      'name': 'Lets Chat limited',
      'prefill': {
        'contact': '9991600615',
        'email': 'lakshayuppal@gmail.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };
    try {
      _razorpay.open(options);
    }
    catch (e) {
      log('error:e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Payment Succesfull" + response.paymentId!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "Payment fail" + response.message!,
        toastLength: Toast.LENGTH_SHORT);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External wallet" + response.walletName!,
        toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              SizedBox(
                height: 70,
                  width: 70,
                  child: Image.asset('assets/images/get-money.png',color: Colors.white,)
              ),
              SizedBox(
                height: 30,
              ),
              Text('Welcome to Razorpay payment gateway integration',
                style: TextStyle(color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,), textAlign: TextAlign.center,),
              SizedBox(
                height: 30,
              ),
              Padding(padding: EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    cursorColor: Colors.white,
                    autofocus: false,
                    style: TextStyle(color: Colors.white,fontWeight: FontWeight.normal,fontSize: 17),
                    decoration: InputDecoration(
                        label: Text('Enter amount to be paid'),
                        labelStyle: TextStyle(
                            fontSize: 15.0, color: Colors.white
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 1.0,
                            )
                        ),
                        errorStyle: TextStyle(color: Colors.redAccent, fontSize: 15)
                    ),
                    controller: amountcontroller,
                    validator: (value) {
                      if (value == null  || value.isEmpty) {
                        return 'Please enter Amount to be paid';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                width: 300,
                height: 50,
                child: ElevatedButton(onPressed: () {
                  if (amountcontroller.text
                      .toString()
                      .isNotEmpty) {
                    setState(() {
                      int amount = int.parse(amountcontroller.text.toString());
                      opencheckout(amount);
                    });
                  }
                }, child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Make Payment',style: TextStyle(color: Colors.white.withOpacity(0.9)),),
                ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
