import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rochat/models/UiHelper.dart';
import 'package:rochat/models/UserModel.dart';
import 'package:rochat/pages/SIgnUpPage.dart';
import 'package:rochat/pages/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void checkValues(){
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    if(email == '' || password == ''){
      UiHepler.showingAlertBox(context, "Incomplete Fields", "Please fill all the Details");
    }else{
      login(email,password);
    }
  }

  login(String email, String password) async {
    UserCredential? credential;
    UiHepler.showDialogBox(context, "Logging in....");

    try{
      credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password);
    }on FirebaseAuthException catch(e){
      //Close the Loading Dialog
      Navigator.pop(context);

      //Show the alert dialog
      UiHepler.showingAlertBox(context,"An Error Occured",e.message.toString());
    }

    if(credential != null){
      String userId = credential.user!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection("users").doc(userId).get();
      UserModel userModel = UserModel.fromMap(userData.data() as Map<String,dynamic>);
      print("Log In Successfull");

      Navigator.of(context).popUntil((route) => route.isFirst);

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
        return HomePage(userModel: userModel, firebasesUser: credential!.user!);
      },));

    }
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/images/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(top: 140, left: 35),
          child: Stack(
            children: [
            const Text(
              "Welcome to\n     RoChat",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 33,
                  fontWeight: FontWeight.w500),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.34,
                    right: 35,
                    left: 35),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person),
                          hintText: "Email",
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Password",
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Log In",
                          style: TextStyle(
                            color: Color(0xff4c505b),
                            fontSize: 27,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 20,),
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: const Color(0xff4c505b),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              checkValues();
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Dont have an account?",
                            style: TextStyle(
                              color: Color(0xff4c505b),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                return SignUpPage();
                              },));
                            },
                            child: const Text("Sign Up",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ))),
                      ],
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
