import 'package:flutter/material.dart';

typedef AuthFormController = _AuthFormController;

mixin AuthFormMixin {
  static AuthFormController? _authFormController;
  AuthFormController initAuthControllers() {
    final auth = _authFormController ??= _AuthFormController();
    return auth;
  }

  void dispose() {
    if (_authFormController != null) {
      _authFormController!.dispose();
    }
  }

  void clearControllers() {
    if (_authFormController != null) {
      _authFormController!.clearControllers();
    }
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'El nombre no puede estar vacío';
    return null;
  }

  String? validateEmail(String? value) {
    final reg = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value == null) return 'El email no puede estar vacío';
    if (reg.hasMatch(value)) {
      return null;
    } else {
      return 'El email no es correcto';
    }
  }

  String? validatePass(String? value) {
    if (_authFormController == null) {
      return null;
    }
    final specialChars = [
      '?',
      '¿',
      '¡',
      '!',
      '.',
      '<',
      '>',
      '_',
      '-',
      ':',
      ';',
      '=',
      '%',
      '&',
      '#',
      '@',
      '|',
    ];
    final String special = specialChars.join(' ');
    if (value == null) return 'El campo no puede estar vacío';
    if (value.length < 8) {
      return 'La contraseña debe tener una longitud mínima de 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    bool containsSpecial = false;
    for (final char in specialChars) {
      if (value.contains(char)) {
        containsSpecial = true;
        break;
      }
    }
    if (!containsSpecial) {
      return 'La contraseña debe contener algún caracter especial: $special';
    }
    return null;
  }

  String? validateRepPass(String? value) {
    if (_authFormController == null) {
      return null;
    }
    final specialChars = [
      '?',
      '¿',
      '¡',
      '!',
      '.',
      '<',
      '>',
      '_',
      '-',
      ':',
      ';',
      '=',
      '%',
      '&',
      '#',
      '@',
      '|'
    ];
    final String special = specialChars.join(' ');
    if (value == null) return 'El campo no puede estar vacío';
    if (value.length < 8) {
      return 'La contraseña debe tener una longitud mínima de 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'La contraseña debe contener al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'La contraseña debe contener al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'La contraseña debe contener al menos un número';
    }
    bool containsSpecial = false;
    for (final char in specialChars) {
      if (value.contains(char)) {
        containsSpecial = true;
        break;
      }
    }
    if (!containsSpecial) {
      return 'La contraseña debe contener algún caracter especial: $special';
    }
    if (value != _authFormController!.passController.text) {
      return 'Las contraseñas deben ser iguales';
    }
    return null;
  }
}

class _AuthFormController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final passRepController = TextEditingController();

  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passController.clear();
    passRepController.clear();
  }

  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    passRepController.dispose();
  }
}
