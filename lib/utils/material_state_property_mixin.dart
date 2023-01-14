import 'package:flutter/material.dart';

mixin MaterialStatePropertyMixin{
  MaterialStateProperty<T> getProperty<T>(Object o) => MaterialStateProperty.resolveWith<T>((states) => o as T);
}