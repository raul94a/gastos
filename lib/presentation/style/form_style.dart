import 'package:flutter/material.dart';

InputDecoration basisFormDecoration() {
  return InputDecoration(
      enabled: true,
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 28, 46, 107)),
          borderRadius: BorderRadius.circular(3)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(3),
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(3),
      ));
}
