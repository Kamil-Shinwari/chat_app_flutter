import 'dart:developer';

import 'package:chat_app_intern_work/main.dart';
import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/models/chatroom_model.dart';
import 'package:chat_app_intern_work/screens/chat_room_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;
  SearchPage({Key? key, required this.userModel, required this.firebaseUser})
      : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<ChatRoomModel?> getchatRoomModel(UserModel targetUser) async {
    ChatRoomModel chatRoom;
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatrooms")
        .where("participants.${widget.userModel.uid}", isEqualTo: true)
        .where("participants.${targetUser.uid}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      //fetch the existing one
      var docdata= snapshot.docs[0].data();
      ChatRoomModel existingChatroom=ChatRoomModel.fromMap(docdata as Map<String,dynamic>);
      chatRoom =existingChatroom;
    } else {
      ChatRoomModel newChatRoom =
          ChatRoomModel(chatRoomId: uuid.v1(), lastMessage: "", participants: {
        widget.userModel.uid.toString(): true,
        targetUser.uid.toString(): true,
      });

      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newChatRoom.chatRoomId)
          .set(newChatRoom.toMap());
          chatRoom=newChatRoom;
    }
    return chatRoom;
  }

  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: Column(children: [
        SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                hintText: "Email Address"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: GestureDetector(
              onTap: () {
                setState(() {});
              },
              child: Text(
                "Search",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.lightBlue),
              )),
        ),
        StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .where("email", isEqualTo: emailController.text)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot datasnapshot = snapshot.data as QuerySnapshot;
                  if (datasnapshot.docs.length > 0) {
                    Map<String, dynamic> userMap =
                        datasnapshot.docs[0].data() as Map<String, dynamic>;

                    UserModel searchUser = UserModel.fromJson(userMap);
                    return ListTile(
                      onTap: () async {
                        ChatRoomModel? chatRoomModel =
                            await getchatRoomModel(searchUser);
                       if(chatRoomModel!=null){
                         Navigator.pop(context);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatRoomPage(
                                  targetUser: searchUser, 
                                  chatRoom: chatRoomModel, 
                                  userModel: widget.userModel, 
                                  firebaseUser: widget.firebaseUser)));
                       }
                      },
                      leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchUser.profilePic!)),
                      title: Text(
                        searchUser.fullName.toString(),
                      ),
                      subtitle: Text(searchUser.email.toString()),
                      trailing: Icon(Icons.keyboard_arrow_right),
                    );
                  } else {
                    return Text("No Record found");
                  }
                } else if (snapshot.hasError) {
                  return Text("an error occured");
                } else {
                  return Text("No result fount");
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            })
      ]),
    );
  }
}
