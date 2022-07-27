class ChatRoomModel{
  String? chatRoomId;
  Map<String,dynamic>? participants;
  String? lastMessage;

  ChatRoomModel({this.chatRoomId,this.participants,this.lastMessage});

  // from object to map

  ChatRoomModel.fromMap(Map<String,dynamic> map){
    chatRoomId=map["chatRoomId"];
    participants=map["participants"];
    lastMessage=map["lastmessage"];
  }
  // from map to object

  Map<String,dynamic> toMap(){
    return {
      "chatRoomId":chatRoomId,
      "participants":participants,
      "lastmessage":lastMessage,
    };
  }
}