import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_firebase/check_sms_page.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controllerFirstName = TextEditingController();
  TextEditingController _controllerLastName = TextEditingController();
  TextEditingController _controllerEmailAddress = TextEditingController();
  TextEditingController _controllerMobileNumber = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

  final _keyForm = GlobalKey<FormState>();


  _handleAddNewDocument() async {
    if (_keyForm.currentState!.validate()) {
      CollectionReference users =
          FirebaseFirestore.instance.collection("users");

      DocumentReference insertedDocument = await users.add({
        "firstName": _controllerFirstName.text,
        "lastName": _controllerLastName.text,
        "emailAddress": _controllerEmailAddress.text,
        "mobileNumber": _controllerMobileNumber.text,
        "password": _controllerPassword.text,
        "platform": Platform.isAndroid ? "android" : "ios",
        "createdAt": DateTime.now()
      });
      if (insertedDocument != null) {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: '+962' + _controllerMobileNumber.text,
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            // if (e.code == 'invalid-phone-number') {
            //   print('The provided phone number is not valid.');
            // }
          },
          codeSent: (String verificationId, int? resendToken) async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CheckSmsPage(verificationId: verificationId)));
            // Navigate to Check SMS page.
          },
          codeAutoRetrievalTimeout: (String verificationId) {},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Register New Account")),
        body: Container(
          padding: const EdgeInsets.all(10.0),
          child: Form(
              key: _keyForm,
              child: Column(
                children: [
                  TextFormField(
                    controller: _controllerFirstName,
                    keyboardType: TextInputType.name,
                    validator: (text) {
                      if (text == null || text.length <= 2) {
                        return "Please check the first name";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("First Name *"),
                        prefixIcon: Icon(Icons.people),
                        hintText: "First Name"),
                  ),
                  TextFormField(
                    controller: _controllerLastName,
                    keyboardType: TextInputType.name,
                    validator: (text) {
                      if (text == null || text.length <= 2) {
                        return "Please check the last name";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("Last Name *"),
                        prefixIcon: Icon(Icons.people),
                        hintText: "Last Name"),
                  ),
                  TextFormField(
                    controller: _controllerEmailAddress,
                    keyboardType: TextInputType.emailAddress,
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "Please check the email address";
                      }
                      if (!GetUtils.isEmail(text)) {
                        return "Please entered a valid email address";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("Email Address *"),
                        prefixIcon: Icon(Icons.email),
                        hintText: "Email Address"),
                  ),
                  TextFormField(
                    controller: _controllerMobileNumber,
                    keyboardType: TextInputType.phone,
                    validator: (text) {
                      if (text == null || text.length != 9) {
                        return "Please check the mobile number";
                      }
                    },
                    decoration: const InputDecoration(
                        label: Text("Mobile Number *"),
                        prefixIcon: Icon(Icons.phone_android),
                        hintText: "07XXXXXXXXX"),
                  ),
                  TextFormField(
                    controller: _controllerPassword,
                    keyboardType: TextInputType.visiblePassword,
                    validator: (text) {
                      if (text == null || text.length < 6) {
                        return "Please check sure password is more than 6 chars";
                      }
                    },
                    obscureText: true,
                    decoration: const InputDecoration(
                        label: Text("Password *"),
                        prefixIcon: Icon(Icons.password),
                        hintText: "Password"),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: _handleAddNewDocument,
                          child: const Text("Register"))
                    ],
                  )
                ],
              )),
        ));
  }
}
