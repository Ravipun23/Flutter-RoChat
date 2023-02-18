class UserModel{
  String? userId;
  String? email;
  String? fullName;
  String? profilePicture;

  UserModel({required this.userId, required this.email, required this.fullName, required this.profilePicture});

  // Map to Object
  UserModel.fromMap(Map<String, dynamic> map){
    this.userId = map["userId"];
    this.email = map["email"];
    this.fullName = map["fullName"];
    this.profilePicture = map["profilePicture"];
  }

  // Object to Map
  Map<String,dynamic> toMap(){
    return{
      "userId" : this.userId,
      "email" : this.email,
      "fullName" : this.fullName,
      "profilePicture" : this.profilePicture,
    };
  }
}