class ChatRoomModel{
  String? chatRoomId;
  Map<String,dynamic>? participants;
  String? lastMessage;
  List<dynamic>? users;
  DateTime? createdOn;

  ChatRoomModel({required this.chatRoomId, required this.participants, required this.lastMessage, this.users, this.createdOn});

  ChatRoomModel.fromMap(Map<String, dynamic> map){
    this.chatRoomId = map["chatRoomId"];
    this.participants = map["participants"];
    this.lastMessage = map["lastMessage"];
    this.users = map["users"];
    this.createdOn = map["createdOn"].toDate();
  }

  get uuid => null;

  Map<String,dynamic> toMap(){
    return{
      "chatRoomId" : this.chatRoomId,
      "participants" : this.participants,
      "users" : this.users,
      "lastMessage" : this.lastMessage,
      "createdOn" : this.createdOn
    };
  }
}