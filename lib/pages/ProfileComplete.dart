import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rochat/models/UiHelper.dart';
import 'package:rochat/pages/homepage.dart';

import '../models/UserModel.dart';

class ProfileComplete extends StatefulWidget {
  final UserModel userModel;
  final User fireBaseUser;

  const ProfileComplete(
      {Key? key, required this.userModel, required this.fireBaseUser})
      : super(key: key);

  @override
  State<ProfileComplete> createState() => _ProfileCompleteState();
}

class _ProfileCompleteState extends State<ProfileComplete> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? imagePicked = await ImagePicker().pickImage(source: source);
    if (imagePicked != null) {
      cropImage(imagePicked);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? imageCropped = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 20);
    File? finalCroppedImage = File(imageCropped!.path);
    setState(() {
      imageFile = finalCroppedImage;
    });
  }

  void checkValues() {
    String fullName = fullNameController.text.trim();
    if (fullName == '' || imageFile == null) {
      UiHepler.showingAlertBox(context, "Incomplete Fields", "Please fill all the Details and upload the profile picture");
    } else {
      uploadData();
    }
  }

  void uploadData() async {

    UiHepler.showDialogBox(context, "Uploading Data...");

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilePicture")
        .child(widget.userModel.userId.toString())
        .putFile(imageFile!);

    TaskSnapshot taskSnapshot = await uploadTask;
    String imgUrl = await taskSnapshot.ref.getDownloadURL();
    String fullName = fullNameController.text.trim();

    widget.userModel.fullName = fullName;
    widget.userModel.profilePicture = imgUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.userId)
        .set(widget.userModel.toMap());
    print("Data Uploaded");

    Navigator.of(context).popUntil((route) => route.isFirst);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) {
        return HomePage(
            userModel: widget.userModel, firebasesUser: widget.fireBaseUser);
      },
    ));
  }

  void showPhotoOption() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Upload Your Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.gallery);
                },
                leading: Icon(Icons.photo_album),
                title: Text("Select from Gallery"),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pop();
                  selectImage(ImageSource.camera);
                },
                leading: Icon(Icons.camera_alt),
                title: Text("Take a Photo"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Complete Profile"),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ListView(
            children: [
              SizedBox(
                height: 40,
              ),
              CupertinoButton(
                padding: EdgeInsets.all(0),
                onPressed: () {
                  print(imageFile);
                  showPhotoOption();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? Icon(
                          Icons.person,
                          size: 60,
                        )
                      : null,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                    label: Text("Full Name"),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(
                height: 20,
              ),
              CupertinoButton(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Text("Submit"),
                  onPressed: () {
                    checkValues();
                    // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) {
                    //   return HomePage();
                    // },));
                  })
            ],
          ),
        ),
      ),
    );
  }
}
