import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rochat/models/FirebaseHelper.dart';
import 'package:rochat/pages/ProfileComplete.dart';
import 'package:rochat/pages/SIgnUpPage.dart';
import 'package:rochat/pages/homepage.dart';
import 'package:uuid/uuid.dart';

import 'models/UserModel.dart';
import 'pages/LoginPage.dart';


var uuid = Uuid();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   
  User? currentUser = FirebaseAuth.instance.currentUser;
  if(currentUser != null){
    UserModel? thisUserModel = await FireBaseHelper.getUserModelById(currentUser.uid);
    if(thisUserModel != null){
      runApp(MyAppLoggedIn(userModel: thisUserModel, firebaseUser: currentUser));
    }else{
    runApp(const MyApp());
    }

  }else{
    runApp(const MyApp());
  }

}

//For Not Logged In
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}


// For  Logged In
class MyAppLoggedIn extends StatelessWidget {

  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggedIn({super.key, required this.userModel, required this.firebaseUser});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(userModel: userModel,firebasesUser: firebaseUser),
    );
  }
}