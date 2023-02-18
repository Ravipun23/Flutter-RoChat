import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rochat/models/ChatRoomModel.dart';
import 'package:rochat/pages/ChatRoomPage.dart';

import '../main.dart';
import '../models/UserModel.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const SearchPage(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ChatRoomModel? chatRoom;

  TextEditingController emailSearchController = TextEditingController();

  Future<ChatRoomModel?> getChatRoomModel(UserModel targetUser) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("chatRooms")
        .where("participants.${widget.userModel.userId}", isEqualTo: true)
        .where("participants.${targetUser.userId}", isEqualTo: true)
        .get();
    if (snapshot.docs.length > 0) {
      //Already Existing ChatRoom
      var docData = snapshot.docs[0].data();
      ChatRoomModel exsitingChatRoom =
          ChatRoomModel.fromMap(docData as Map<String, dynamic>);
      chatRoom = exsitingChatRoom;
      log("Already Existing ChatRoom");
    } else {
      //Already Not Existing ChatRoom
      ChatRoomModel newChatRoomModel =
          ChatRoomModel(chatRoomId: uuid.v1(), lastMessage: "", participants: {
        widget.userModel.userId.toString(): true,
        targetUser.userId.toString(): true,
      },
      users: [widget.userModel.userId.toString(), targetUser.userId.toString()],
      createdOn: DateTime.now()
      
      );

      await FirebaseFirestore.instance
          .collection("chatRooms")
          .doc(newChatRoomModel.chatRoomId)
          .set(newChatRoomModel.toMap());

      chatRoom = newChatRoomModel;

      log("Created New ChatRoom");
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: emailSearchController,
                decoration: InputDecoration(
                    label: Text("Search Email"),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CupertinoButton(
                child: Text("Search"),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  setState(() {});
                }),
            SizedBox(
              height: 30,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("email", isEqualTo: emailSearchController.text.trim())
                  .where("email", isNotEqualTo: widget.userModel.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;
                    if (dataSnapshot.docs.length > 0) {
                      Map<String, dynamic> userMap =
                          dataSnapshot.docs[0].data() as Map<String, dynamic>;
                      UserModel searchedUser = UserModel.fromMap(userMap);
                      return ListTile(
                        onTap: () async {
                          ChatRoomModel? chatRoomModel =
                              await getChatRoomModel(searchedUser);
                          if (chatRoomModel != null) {
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return ChatRoomPage(
                                  targetUser: searchedUser,
                                  chatRoom: chatRoomModel,
                                  userModel: widget.userModel,
                                  firebaseUser: widget.firebaseUser);
                            }));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(searchedUser.profilePicture!),
                          backgroundColor: Colors.grey[500],
                        ),
                        title: Text(searchedUser.fullName!),
                        subtitle: Text(searchedUser.email!),
                        trailing: Icon((Icons.keyboard_arrow_right)),
                      );
                    } else {
                      return Text("No Result Found");
                    }
                  } else if (snapshot.hasError) {
                    return Text("An Errored Occured!");
                  } else {
                    return Text("No Result Found");
                  }
                } else {
                  return CircularProgressIndicator();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
