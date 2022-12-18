// @dart=2.9

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UtilFs {
  static showToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }
  static showInfoToast(String message, BuildContext context) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG
    );
  }

  static showErrorToast(String message, BuildContext context) {
    Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG
    );
  }
}
