 import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel{
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  var createdon;
  MessageModel({this.sender,this.text,this.seen,this.createdon,this.messageId});

  // from object to map

  MessageModel.fromJson(Map<String,dynamic> map){
    messageId=map["messageId"];
    sender=map["sender"];
    text=map["text"];
    seen=map["seen"];
    createdon=map["createdon"];

    
    }
    // From map to object

    Map<String,dynamic> toMap(){
      return{
        "messageId":messageId,
        "sender":sender,
        "text":text,
        "seen":seen,
        "createdon":createdon
      };
  }

}