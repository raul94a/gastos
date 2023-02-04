import 'package:flutter/material.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/auth_form_mixin.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          minimum: const EdgeInsets.all(7),
          child: SingleChildScrollView(
            child: Column(
              children: const [
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

class _AuthFormState extends State<AuthForm>
    with MaterialStatePropertyMixin, AuthFormMixin {
  final formKey = GlobalKey<FormState>();
  //the controllers for the form fields
  late AuthFormController authControllers;
  bool signUp = true;

  void toSignUp() => setState(() => {signUp = true, clear()});
  void toSignIn() => setState(() => {signUp = false, clear()});

  void clear() {
    authControllers.clearControllers();
    formKey.currentState!.reset();
  }

  @override
  void initState() {
    super.initState();
    authControllers = initAuthControllers();
  }

  @override
  void dispose() {
    authControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _SignUp(
                    formKey: formKey,
                    authControllers: authControllers,
                    validatePass: validatePass,
                    validateRepPass: validateRepPass,
                    validateName: validateName,
                    validateEmail: validateEmail,
                    outlinedDecoration: outlinedDecoration,
                    toSignIn: toSignIn)
              else
                _SignIn(
                    formKey: formKey,
                    authControllers: authControllers,
                    outlinedDecoration: outlinedDecoration,
                    toSignUp: toSignUp)
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
}

class _SignUp extends StatelessWidget with MaterialStatePropertyMixin {
  const _SignUp(
      {super.key,
      required this.formKey,
      required this.authControllers,
      required this.validatePass,
      required this.validateRepPass,
      required this.validateEmail,
      required this.validateName,
      required this.outlinedDecoration,
      required this.toSignIn});

  final AuthFormController authControllers;
  final String? Function(String?)? validatePass, validateRepPass, validateEmail, validateName;
  final InputDecoration Function() outlinedDecoration;
  final VoidCallback toSignIn;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      children: [
        Text('Nombre', style: GoogleFonts.raleway(fontSize: 14.2)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: authControllers.nameController,
          decoration: outlinedDecoration(),
          validator: validateName,
        ),
        const SizedBox(
          height: 10,
        ),
        Text('Email', style: GoogleFonts.raleway(fontSize: 14.2)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: authControllers.emailController,
          decoration: outlinedDecoration(),
          validator: validateEmail,
        ),
        const SizedBox(
          height: 10,
        ),
        Text('Contraseña', style: GoogleFonts.raleway(fontSize: 14.2)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
            controller: authControllers.passController,
            decoration: outlinedDecoration(),
            validator: validatePass),
        const SizedBox(
          height: 10,
        ),

        Text('Repite la contraseña',
            style: GoogleFonts.raleway(fontSize: 14.2)),

        const SizedBox(
          height: 10,
        ),

        TextFormField(
          controller: authControllers.passRepController,
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

                  state.createUser(
                      context,
                      authControllers.emailController.text,
                      authControllers.passController.text,
                      authControllers.nameController.text);
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      getProperty(const Color.fromARGB(255, 46, 17, 211)),
                  fixedSize: getProperty(Size(width * 0.96, 60))),
              child: state.loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : Text('Sign up')),
        ),

        TextButton(
          onPressed: () {
            toSignIn();
          },
          child: Text('Ya tengo cuenta. Iniciar sesión',
              style: GoogleFonts.raleway(fontSize: 14.2)),
        ),
       
      ],
    );
  }
}

class _SignIn extends StatelessWidget with MaterialStatePropertyMixin {
  const _SignIn(
      {super.key,
      required this.formKey,
      required this.authControllers,
      required this.outlinedDecoration,
      required this.toSignUp});

  final AuthFormController authControllers;
  final InputDecoration Function() outlinedDecoration;
  final VoidCallback toSignUp;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      children: [
//hast aqui
        Text('Email', style: GoogleFonts.raleway(fontSize: 14.2)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          controller: authControllers.emailController,
          decoration: outlinedDecoration(),
        ),
        const SizedBox(
          height: 10,
        ),
        Text('Contraseña', style: GoogleFonts.raleway(fontSize: 14.2)),
        const SizedBox(
          height: 10,
        ),
        TextFormField(
          controller: authControllers.passController,
          decoration: outlinedDecoration(),
        ),
        const SizedBox(
          height: 10,
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

                  state.login(context, authControllers.emailController.text,
                      authControllers.passController.text);
                }
              },
              style: ButtonStyle(
                  backgroundColor:
                      getProperty(const Color.fromARGB(255, 46, 17, 211)),
                  fixedSize: getProperty(Size(width * 0.96, 60))),
              child: state.loading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : const Text('Sign in')),
        ),

        TextButton(
          onPressed: () {
            toSignUp();
          },
          child: Text(' No tengo cuenta. Registrarme',
              style: GoogleFonts.raleway(fontSize: 14.2)),
        ),
        TextButton(
          onPressed: () {},
          child: Text('¿Has olvidado tu contraseña?',
              style: GoogleFonts.raleway(fontSize: 14.2)),
        )
      ],
    );
  }
}
