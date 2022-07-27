import 'dart:developer';

import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/screens/MainHomePage.dart';
import 'package:chat_app_intern_work/screens/SignUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  UserModel? userModel;
  User? user;
   LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  void checkValues(String email, String Password) {
    String email = emailController.text.trim();
    String password = passController.text.trim();

    if (email == "" || password == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Plz fill all the field"),
        ),
      );
    } else {
      logIn(email, password);
    }
  }

  void logIn(String email, String password) async {
    UserCredential? User1;
    try {
      User1 = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
        ),
      );
    }
    if (User1 != null) {
      String uid = User1.user!.uid;
      DocumentSnapshot Userdata =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();
      UserModel userModel =
          UserModel.fromJson(Userdata.data() as Map<String, dynamic>);
      log("Log In Successfull");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Chat App",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: "email"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: passController,
                    obscureText: true,
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        hintText: "password"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () async {
                        checkValues(emailController.text, passController.text);
                         Navigator.push(context, MaterialPageRoute(builder: (context) => MainHomePage(userModel:widget.userModel! , firebaseUser: widget.user!),));
                      },
                      child: Text("LogIn"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Haven't any account yet ?"),
          SizedBox(
            width: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignUpPage(),
                      ));
                },
                child: Text(
                  "SignUp",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.lightBlue),
                )),
          )
        ],
      )),
    );
  }
}
