import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelperClass{
 static Future<UserModel?> getuserModelById(String uid) async{
    UserModel ? userModel;
    DocumentSnapshot snapshot=await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if(snapshot.data() !=null){
      userModel =UserModel.fromJson(snapshot.data() as Map<String,dynamic>);

    }
    return userModel;
  }
}