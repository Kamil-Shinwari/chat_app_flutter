import 'dart:developer';
import 'dart:io';


import 'package:chat_app_intern_work/models/User_model.dart';
import 'package:chat_app_intern_work/screens/MainHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfilePage extends StatefulWidget {
  UserModel userModel;
  User firebaseuser;
  CompleteProfilePage({Key? key, required this.userModel,required this.firebaseuser})
      : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  File? imageFile;
  TextEditingController namecontroller = TextEditingController();
  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    
    if (pickedFile != null) {
      // cropImage(pickedFile);
      setState(() {
        imageFile=File(pickedFile.path);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image seleced")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Image not seleced")));
    }
  }

  // for image crop
  // void cropImage(XFile file) async {
  //   CroppedFile? cropFile = await ImageCropper()
  //       .cropImage(sourcePath: file.path, compressQuality: 20);
  //   if (cropFile != null) {
  //     setState(() {
  //       imageFile = cropFile as File?;
  //     });
  //   }
  // }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Upload an image"),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(
                onTap: () {
                  selectImage(ImageSource.gallery);

                  Navigator.pop(context);
                },
                title: Text("Select from Gallery"),
                leading: Icon(Icons.photo),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  selectImage(ImageSource.camera);
                },
                title: Text("take a Photo"),
                leading: Icon(Icons.camera_alt),
              ),
            ]),
          );
        });
  }

  void checkValues() {
    String fullName = namecontroller.text.trim();
    if (fullName == "" || imageFile == null) {
      print("please fill all field");
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePic")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);
    TaskSnapshot snapshot = await uploadTask;
    String imageurl = await snapshot.ref.getDownloadURL();
    String FullName = namecontroller.text.trim();

    widget.userModel.fullName = FullName;
    widget.userModel.profilePic = imageurl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap()).then((value) {
          log("data Uploaded");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("completProfile"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        child: ListView(children: [
          SizedBox(
            height: 20,
          ),
          GestureDetector(
              onTap: () {
                showPhotoOptions();
              },
              child: CircleAvatar(
                radius: 70,
                backgroundImage:(imageFile!=null)?FileImage(imageFile!):null,
                child:(imageFile!=null)? Icon(
                  Icons.person,
                  size: 70,
                ):null,
              )),
          Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15, top: 15, bottom: 15),
            child: TextField(
              controller: namecontroller,
              obscureText: false,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: "FullName"),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  uploadData();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MainHomePage(userModel: widget.userModel, firebaseUser: widget.firebaseuser)));
                  
                },
                child: Text("Submit"),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }
}
