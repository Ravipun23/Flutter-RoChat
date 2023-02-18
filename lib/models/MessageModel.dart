class MessageModel{
  String? messageId;
  String? sender;
  String? text;
  bool? seen;
  DateTime? createdOn;

  MessageModel({required this.sender, required this.text, required this.seen, required this.createdOn});

  // Map to Object
  MessageModel.fromMap(Map<String, dynamic> map){
    this.sender = map["sender"];
    this.messageId = map["messageId"];
    this.text = map["text"];
    this.seen = map["seen"];
    this.createdOn = map["createdOn"].toDate();
  }

  // Object to Map
  Map<String,dynamic> toMap(){
    return{
      "sender" : this.sender,
      "messageId" : this.messageId,
      "text" : this.text,
      "seen" : this.seen,
      "createdOn" : this.createdOn,
    };
  }
}