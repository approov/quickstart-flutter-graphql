// @dart=2.9

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UtilFs {
  static showToast(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_LONG);
  }
}
