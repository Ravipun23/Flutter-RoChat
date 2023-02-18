import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rochat/models/UserModel.dart';

class FireBaseHelper{
  static Future<UserModel?> getUserModelById(String userId) async{
    UserModel? userModel;
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if(docSnap .data()!= null){
        userModel = UserModel.fromMap(docSnap.data() as Map<String,dynamic>);
    }
    return userModel;
  }
}