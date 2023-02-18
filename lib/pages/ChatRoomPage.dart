import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rochat/models/ChatRoomModel.dart';
import 'package:rochat/models/MessageModel.dart';
import 'package:rochat/models/UserModel.dart';

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

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messageController = TextEditingController();

  void sendMessage() async {
    String message = messageController.text.trim();
    messageController.clear();

    if (message != "") {
      MessageModel newMessage = MessageModel(
          sender: widget.userModel.userId,
          text: message,
          seen: false,
          createdOn: DateTime.now());

      FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(widget.chatRoom.chatRoomId)
          .collection("messages")
          .doc(newMessage.messageId)
          .set(newMessage.toMap());

      widget.chatRoom.lastMessage = message;
      FirebaseFirestore.instance.collection("chatRooms").doc(widget.chatRoom.chatRoomId).set(widget.chatRoom.toMap());

      log("Message Sent");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  NetworkImage(widget.targetUser.profilePicture.toString()),
            ),
            SizedBox(
              width: 10,
            ),
            Text(widget.targetUser.fullName.toString()),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("chatRooms")
                  .doc(widget.chatRoom.chatRoomId)
                  .collection("messages")
                  .orderBy("createdOn", descending: true)
                  .snapshots(),
              builder: ((context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    return ListView.builder(
                        reverse: true,
                        itemCount: dataSnapshot.docs.length,
                        itemBuilder: (context, index) {
                          MessageModel currentMessage = MessageModel.fromMap(
                              dataSnapshot.docs[index].data()
                                  as Map<String, dynamic>);
                          return Row(
                            mainAxisAlignment: (currentMessage.sender ==
                                    widget.userModel.userId)
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                      color: (currentMessage.sender ==
                                              widget.userModel.userId)
                                          ? Theme.of(context)
                                              .colorScheme
                                              .secondary
                                          : Colors.grey,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Text(currentMessage.text.toString(),style: TextStyle(color: (currentMessage.sender == widget.userModel.userId)?Colors.white:Colors.black),)),
                            ],
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "An error Occured! Check your internet connection!"),
                    );
                  } else {
                    return Center(child: Text("Say hi to your new friend"));
                  }
                } else {
                  return CircularProgressIndicator();
                }
              }),
            ),
          )),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Enter Your Message",
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.zero),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    sendMessage();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
