import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rochat/models/ChatRoomModel.dart';
import 'package:rochat/models/UiHelper.dart';
import 'package:rochat/pages/ChatRoomPage.dart';
import 'package:rochat/pages/LoginPage.dart';
import 'package:rochat/pages/SearchPage.dart';

import '../models/FirebaseHelper.dart';
import '../models/UserModel.dart';


class HomePage extends StatefulWidget {

  final UserModel userModel;
  final User firebasesUser;


  const HomePage({Key? key, required this.userModel, required this.firebasesUser}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ro-Chat"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
                return LoginPage();
              }));
            }, 
            icon: Icon(Icons.exit_to_app))
        ],

      ),

      body: Container(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("chatRooms").where("users",arrayContains: widget.userModel.userId).orderBy("createdOn").snapshots(),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.active){
              if(snapshot.hasData){
                QuerySnapshot chatRoomSnapshot = snapshot.data as QuerySnapshot;

                return ListView.builder(
                  itemCount: chatRoomSnapshot.docs.length,
                  itemBuilder: (conyext,index){
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(chatRoomSnapshot.docs[index].data() as Map<String,dynamic>);
                    Map<String,dynamic> participants = chatRoomModel.participants!;
                    List<String> participantsKey = participants.keys.toList();
                    participantsKey.remove(widget.userModel.userId);
                    return FutureBuilder(
                      future: FireBaseHelper.getUserModelById(participantsKey[0]),
                      builder: (context, userData){
                        if (userData.connectionState == ConnectionState.done){
                        UserModel targetUser = userData.data!;
                        return ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context){
                              return ChatRoomPage(
                                targetUser: targetUser, 
                                chatRoom: chatRoomModel, 
                                userModel: widget.userModel, 
                                firebaseUser: widget.firebasesUser);
                            }));
                          },
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(targetUser.profilePicture.toString()),
                          ),
                          title: Text(targetUser.fullName.toString()),
                          subtitle: (chatRoomModel.lastMessage.toString() != '')?
                          Text(chatRoomModel.lastMessage.toString()):
                          Text("Say hi to your new friend", style: TextStyle(color: Theme.of(context).colorScheme.secondary),)
                          ,);
                        }else{
                          return Container();
                        }
                      });

                  });

              }else if(snapshot.hasError){
                return Center(child: Text(snapshot.error.toString()),);
              }else{
                return Center(child: Text("No Chats"),);
              }

            }else{
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),


      floatingActionButton: FloatingActionButton(onPressed: (){
        
        Navigator.of(context).push(MaterialPageRoute(builder: ((context) {
          return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebasesUser);
        })));
      },
      child: Icon(Icons.search),),
    );
  }
}
