import 'package:flutter/material.dart';
// ignore: library_prefixes
import 'package:oktoast/oktoast.dart' as OKToast;

void showToast(String text) {
  OKToast.showToast(text, position: OKToast.ToastPosition.bottom);
}

void showCenterToast(String text) {
  OKToast.showToast(text, position: OKToast.ToastPosition.center);
}

void showErrorToast(String text) {
  OKToast.showToast(
    text,
    backgroundColor: Colors.redAccent,
  );
}

void showCenterErrorToast(String text) {
  OKToast.showToast(
    text,
    position: OKToast.ToastPosition.center,
    backgroundColor: Colors.redAccent,
  );
}

void showTopToast(String text) {
  OKToast.showToast(text, position: OKToast.ToastPosition.top);
}
