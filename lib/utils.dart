import 'package:flutter/material.dart';

void displaySnackBar(BuildContext context, String content) {
  var snackBar = SnackBar(
    content: Text(content),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
