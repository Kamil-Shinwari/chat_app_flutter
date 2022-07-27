class UserModel{
  String? uid;
  String? fullName;
  String? email;
  String? profilePic;
  String? fcmToken;

  UserModel({this.uid,this.fullName,this.email,this.profilePic,this.fcmToken});
//  it will make from object to map
  UserModel.fromJson(Map<String,dynamic> map){
    uid=map["uid"];
    fullName=map["fullName"];
    email=map["email"];
    profilePic=map["profilePic"];
    fcmToken=map["fcmToken"];
  }

  // from map to object
  Map<String,dynamic> toMap(){
    return {
      "uid":uid,
      "fullName":fullName,
      "email":email,
      "profilePic":profilePic,
      "fcmToken":fcmToken
    };
  }
}