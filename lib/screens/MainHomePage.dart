import 'dart:developer';

import 'package:chat_app_intern_work/models/Firebase_helper.dart';
import 'package:chat_app_intern_work/models/chatroom_model.dart';
import 'package:chat_app_intern_work/screens/LogIn_page.dart';
import 'package:chat_app_intern_work/screens/SearchPage.dart';
import 'package:chat_app_intern_work/screens/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/User_model.dart';

class MainHomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  const MainHomePage(
      {Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut().then((value) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ));
              });
            },
            icon: Icon(Icons.logout))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>widget.userModel.uid.toString() !=null?  SearchPage(
                    userModel: widget.userModel,
                    firebaseUser: widget.firebaseUser):Center(child: CircularProgressIndicator(),),
              ));
        },
        child: Icon(Icons.search),
      ),
      body: SafeArea(child: Container(
        child: StreamBuilder(stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}",isEqualTo: true).snapshots(),
        builder: (context,snapshots){
          if(snapshots.connectionState==ConnectionState.active){
            if(snapshots.hasData){

              QuerySnapshot chatRoomSnapshot=snapshots.data as QuerySnapshot;
              return ListView.builder(
                itemCount: chatRoomSnapshot.docs.length,
                itemBuilder: (context, index) {
                  ChatRoomModel chatRoomModel=ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String,dynamic>);
                  Map<String,dynamic> participants=chatRoomModel.participants!;
                  List<String> participantsKey=participants.keys.toList();
                  participants.remove(widget.userModel.uid);
                  return FutureBuilder(
                    future: FirebaseHelper.getUserModelByUid(participantsKey[0]),
                    builder: (context, userData) {
                      if(userData.connectionState==ConnectionState.done){
                        if(userData.data !=null){
                           UserModel targetUser=userData.data as UserModel;
                    return ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return ChatRoomPage(targetUser: targetUser, 
                          chatRoom: chatRoomModel, 
                          userModel: widget.userModel, 
                          firebaseUser: widget.firebaseUser);
                        },));
                      },
                      title: Text(targetUser.fullName.toString()),
                      subtitle: Text("Hii...."),
                      leading: CircleAvatar(radius: 40,backgroundImage: NetworkImage(targetUser.profilePic.toString()),),
                    );
                        }
                        else{
                          return Text("error occured");
                        }
                   
                      }else{
                        return Container();
                      }
                   
                  },);
              },);
            }else if(snapshots.hasError){
              return Text(snapshots.error.toString());
            }else{
              return Center(child: Text("No Chats"),);
            }
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        },
        ),
      )),
    );
  }
}
