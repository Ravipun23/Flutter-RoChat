import 'package:flutter/material.dart';

class UiHepler{
  static void showDialogBox(
    BuildContext context, String title){
    AlertDialog loadingDialog = AlertDialog(
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 30,),
            Text(title)
          ],
        ),
      ),
    );

    showDialog(
      barrierDismissible: false,
      context: context, 
      builder: (context){
        return loadingDialog;
      });
  }

  static void showingAlertBox(BuildContext context, String title, String content){
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text("0k"))
      ],
    );

    showDialog(context: context, builder: (context){
      return alertDialog;
    });

  }
}