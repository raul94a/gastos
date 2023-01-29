import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/user.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = context.read<UserProvider>();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          minimum: EdgeInsets.all(7),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AuthForm(),
              ],
            ),
          ),
        ));
  }
}

class AuthForm extends StatefulWidget {
  const AuthForm({
    Key? key,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with MaterialStatePropertyMixin {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final passRepController = TextEditingController();
  bool signUp = true;
  void toSignUp() => setState(() => {signUp = true, clearControllers()});
  void toSignIn() => setState(() => {signUp = false, clearControllers()});
  void clearControllers() {
    nameController.clear();
    emailController.clear();
    passController.clear();
    passRepController.clear();
    formKey.currentState!.reset();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    passRepController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Container(
      padding: const EdgeInsets.all(10),
      //decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  signUp ? 'Regístrate' : 'Inicia sesión',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoSerif(fontSize: 28.2),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (signUp)
                Text('Nombre', style: GoogleFonts.raleway(fontSize: 14.2)),
              if (signUp)
                const SizedBox(
                  height: 10,
                ),

              if (signUp)
                TextFormField(
                  controller: nameController,
                  decoration: outlinedDecoration(),
                  validator: (value) {
                    if (value == null) return 'El nombre no puede estar vacío';
                    return null;
                  },
                ),
              if (signUp)
                const SizedBox(
                  height: 10,
                ),

              Text('Email', style: GoogleFonts.raleway(fontSize: 14.2)),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: outlinedDecoration(),
                validator: (value) {
                  final reg = RegExp(
                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                  if (value == null) return 'El email no puede estar vacío';
                  if (reg.hasMatch(value)) {
                    return null;
                  } else {
                    return 'El email no es correcto';
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Text('Contraseña', style: GoogleFonts.raleway(fontSize: 14.2)),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  controller: passController,
                  decoration: outlinedDecoration(),
                  validator: validatePass),
              const SizedBox(
                height: 10,
              ),
              if (signUp)
                Text('Repite la contraseña',
                    style: GoogleFonts.raleway(fontSize: 14.2)),
              if (signUp)
                const SizedBox(
                  height: 10,
                ),

              if (signUp)
                TextFormField(
                  controller: passRepController,
                  decoration: outlinedDecoration(),
                  validator: validateRepPass,
                ),

              //signIn
              const SizedBox(
                height: 10,
              ),
              Consumer<UserProvider>(
                builder: (ctx, state, _) => ElevatedButton(
                    onPressed: () {
                      if (state.loading) return;
                      if (formKey.currentState!.validate()) {
                        print('No errors found');
                        if (signUp) {
                          state.createUser(context, emailController.text,
                              passController.text, nameController.text);
                        } else {
                          state.login(context, emailController.text,
                              passController.text);
                        }
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            getProperty(Color.fromARGB(255, 46, 17, 211)),
                        fixedSize: getProperty(Size(width * 0.96, 60))),
                    child: state.loading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(signUp ? 'Sign up' : 'Sign in')),
              ),

              TextButton(
                onPressed: () {
                  if (signUp) {
                    toSignIn();
                  } else {
                    toSignUp();
                  }
                },
                child: Text(
                    signUp
                        ? 'Ya tengo cuenta. Iniciar sesión'
                        : ' No tengo cuenta. Registrarme',
                    style: GoogleFonts.raleway(fontSize: 14.2)),
              ),
              TextButton(
                onPressed: () {},
                child: Text('¿Has olvidado tu contraseña?',
                    style: GoogleFonts.raleway(fontSize: 14.2)),
              )
            ],
          )),
    );
  }

  InputDecoration outlinedDecoration() => InputDecoration(
        errorMaxLines: 2,
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue.shade200)),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent.shade200)),
        enabled: true,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.lightBlue.shade200)),
      );

  String? validatePass(String? value) {
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
    if (value != passController.text) {
      return 'Las contraseñas deben ser iguales';
    }
    return null;
  }
}
