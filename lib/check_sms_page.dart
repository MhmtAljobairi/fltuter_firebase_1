import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckSmsPage extends StatefulWidget {
  final String verificationId;
  const CheckSmsPage({super.key, required this.verificationId});

  @override
  State<CheckSmsPage> createState() => _CheckSmsPageState();
}

class _CheckSmsPageState extends State<CheckSmsPage> {
  TextEditingController _controller = TextEditingController();

  _handleCheckAction() async {
    String code = _controller.text;
    if (code.length > 1) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: code);
      await FirebaseAuth.instance.signInWithCredential(credential);
      print("DONE");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Check SMS")),
      body: Container(
          child: Center(
        child: Column(
          children: [
            TextField(
              controller: _controller,
            ),
            TextButton(onPressed: _handleCheckAction, child: Text("Submit"))
          ],
        ),
      )),
    );
  }
}
