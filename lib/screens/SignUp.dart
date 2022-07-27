import 'dart:developer';

import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/screens/Complet_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController ConfirmController = TextEditingController();

  void CheckValues() {
    String email = emailController.text.trim();
    String password = passController.text.trim();
    String Confirm = ConfirmController.text.trim();
    if (email == "" || password == "" || Confirm == " ") {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("plz fill all field")));
    } else if (password != Confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Password and Confirmed Password not match")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("SignUp Successfull")));
    }
  }

  void SignUp(String email, String Password) async {
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: Password);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.code.toString())));
    }
    if (credential != null) {
      String uid = credential.user!.uid;
      UserModel userModel =
          UserModel(email: email, uid: uid, fullName: "", profilePic: "");
      FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(userModel.toMap())
          .then((value) {
        log("New User created");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteProfilePage(
                userModel: userModel, firebaseuser: credential!.user!),
          ),
        );
      });
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
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                        hintText: "Email"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: passController,
                    obscureText: false,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        hintText: "Password"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: ConfirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                        hintText: "ConfirmPassword"),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        CheckValues();
                        SignUp(emailController.text, passController.text);
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => CompleteProfilePage(),));
                      },
                      child: Text("SignUp"),
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
          Text("Already Have account yet "),
          SizedBox(
            width: 15,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "LogIn",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.lightBlue),
                    ))),
          )
        ],
      )),
    );
  }
}
