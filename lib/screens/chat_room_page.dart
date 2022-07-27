import 'dart:developer';

import 'package:chat_app_intern_work/main.dart';
import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/models/chatroom_model.dart';
import 'package:chat_app_intern_work/models/messageModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../notificationservice/local_notification_service.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatRoom;
  final UserModel userModel;
  final User firebaseUser;
 

  const ChatRoomPage(
      {super.key,
     
      required this.targetUser,
      required this.chatRoom,
      required this.userModel,
      required this.firebaseUser});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}
String? deviceTokenToSendPushNotification;
  FirebaseFirestore db = FirebaseFirestore.instance;
  String? senderToken;


  Future<void> updateToken() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceTokenToSendPushNotification = await token;
    print("Token Value $deviceTokenToSendPushNotification");
    db.collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({"fcmToken": deviceTokenToSendPushNotification}).then((result){
      print("the tokennn update");
    }).catchError((onError){
      print("onError");
    });
  }
  Future<void> makePostRequest(String title, String body, String token) async {
    final url = Uri.parse(
        'https://docpatient.sdtaxandfinancials.com/public/androidApi/sendCustomNotify.php');
    final json = {'title': title, 'body': body, 'token': token};
    final response = await http.post(url, body: json);
    print('Status code: ${response.statusCode}');
    print('Body: ${response.body}');
  }

class _ChatRoomPageState extends State<ChatRoomPage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateToken();
        FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          // if (message.data['_id'] != null) {
          //   Navigator.of(context).push(
          //     MaterialPageRoute(
          //       builder: (context) => DemoScreen(
          //         id: message.data['_id'],
          //       ),
          //     ),
          //   );
          // }
        }
      },
    );

    
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);

        }
      },
    );

        FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );
  
  }
  
  void SendMessage() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();
    if (msg != null) {
      MessageModel newMessag = MessageModel(
          messageId: uuid.v1(),
          sender: widget.userModel.uid,
          createdon: DateTime.now(),
          text: msg,
          seen: false);
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatRoom.chatRoomId)
          .collection("messages")
          .doc(newMessag.messageId)
          .set(newMessag.toMap());
      log("message send");
    }
  }

  TextEditingController messagecontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            backgroundImage:
                NetworkImage(widget.userModel.profilePic.toString()),
          ),
          SizedBox(
            width: 10,
          ),
          Text(widget.targetUser.fullName.toString())
        ]),
      ),
      body: Column(children: [
        Expanded(
            child: Container(
              padding: EdgeInsets.all(8),
          child: Container(
              child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("chatrooms")
                .doc(widget.chatRoom.chatRoomId)
                .collection("messages").orderBy("createdon",descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if(snapshot.connectionState==ConnectionState.active){
                  if(snapshot.hasData){
                    QuerySnapshot datasnapshot=snapshot.data as QuerySnapshot;
                   return ListView.builder(
                    reverse: true,
                      itemCount: datasnapshot.docs.length,
                      itemBuilder: (context, index) {
                        MessageModel currentmessage=MessageModel.fromJson(datasnapshot.docs[index].data() as Map<String,dynamic>);
                      return Row(
                        mainAxisAlignment: (currentmessage.sender==widget.userModel.uid)?MainAxisAlignment.end:MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                            decoration: BoxDecoration(color: (currentmessage.sender==widget.userModel.uid)?Colors.grey:Theme.of(context).colorScheme.secondary,borderRadius: BorderRadius.circular(10)),
                            margin: EdgeInsets.symmetric(vertical: 2),
                            child: Text(currentmessage.text.toString(),style: TextStyle(color: Colors.white),)),
                        ],
                      );
                    },);
                  }else if(snapshot.hasError){
                     return Text("Error");
                  }else{
                   return Text("Say hi to your new friend");
                  }
              }else{
                return Center(child: CircularProgressIndicator(),);
              }
            },
          )),
        )),
        Container(
          color: Colors.grey,
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Row(
            children: [
              Flexible(
                  child: TextField(
                maxLength: null,
                controller: messagecontroller,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Message",
                    hintStyle: TextStyle(
                      fontSize: 20,
                    )),
              )),
              IconButton(
                  onPressed: () {
                    SendMessage();
                    print("eleennnnnnnnnnnnnnnnnnnnnnnnnnnnn");

                            makePostRequest(
                                // _taskNameController.text,
                                "in App Testing",
                                "check your task ",
                                // senderToken.toString()
                                // "fwLDNMWrTWiDxPE4HXwHBW:APA91bG84blCDc6DSFVZLmbBRhx_whn9m_C1Pl8CuiDb_iXi2eGv6auv2q-2c2LIrGvT3fA3G6uDA6yyibMTIVNQK1j0JvnoY9IeOo6E_FZnDlib8AI92GYYgZ1Zr2TvdaPEP9pG6pRa"
                                // deviceTokenToSendPushNotification!
                                widget.userModel.fcmToken.toString(),
                                );
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.blue,
                  ))
            ],
          ),
        ),
      ]),
    );
  }
}
