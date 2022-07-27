import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseHelper {
  static Future<UserModel?> getUserModelByUid(String uid) async {
    UserModel? userModel;
    DocumentSnapshot doscsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(doscsnap.data() !=null){
      userModel=UserModel.fromJson(doscsnap.data() as Map<String,dynamic>);
    }
    return userModel;
  }
}
