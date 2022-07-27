
import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/screens/Complet_profile.dart';
import 'package:chat_app_intern_work/screens/Helperclass.dart';
import 'package:chat_app_intern_work/screens/Login_page.dart';
import 'package:chat_app_intern_work/screens/MainHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';

import 'notificationservice/local_notification_service.dart';
var uuid=Uuid();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
 User? user= FirebaseAuth.instance.currentUser;
 if(user!=null){
  UserModel? thisUserModel= await HelperClass.getuserModelById(user.uid);
  if(thisUserModel !=null){
runApp(MyAppLoggedIn(userModel:thisUserModel, Firebaseuser: user));
  }

 }else{
  runApp( MyApp());

 }

}


class MyApp extends StatefulWidget {

    
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // @override
  // void initState() {
  //   _firebaseMessaging.getInitialMessage().then((message) {if(message!=null){
  //     final routeFromMessage= message.data;
  //     print(routeFromMessage);
  //     LocalNotificationService.initialize();
  //     /*Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ProfileTabPage(),
  //         ),
  //       );*/
  //   }});
  //   //foreground message
  //   FirebaseMessaging.onMessage.listen((message) {
  //     if(message.notification!=null){
  //       print(message.notification?.body);
  //       print(message.notification?.title);
  //       LocalNotificationService.initialize();
  //     }
  //     else{
  //       print("null message");
  //     }
  //     // LocalNotificationService.display(message);
  //   });
  //   //only works when the app is in the background and open
  //   //when user tap on the notification
  //   FirebaseMessaging.onMessageOpenedApp.listen((message) {
  //     if(message.data!=null){
  //       final routeFromMesssage = message.data;
  //       /* Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => ProfileTabPage(),
  //         ),
  //       );*/
  //       LocalNotificationService.initialize();
  //       print(routeFromMesssage);
  //     }
  //   });
  //   super.initState();
  // }
 
 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
      
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
class MyAppLoggedIn extends StatelessWidget {
  final UserModel userModel;
  final User Firebaseuser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.Firebaseuser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainHomePage(userModel: userModel, firebaseUser: Firebaseuser),
    );
  }
}

