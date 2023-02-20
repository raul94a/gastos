import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/manage_categories_page.dart';
import 'package:gastos/presentation/style/form_style.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool show = true;
  changeShowStatus() => setState(() => show = !show);
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: '');
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text('Categorías', style: GoogleFonts.robotoSerif(fontSize: 28.2)),
              TextButton(
                onPressed: () {
                  const opacity = Interval(0, 0.75, curve: Curves.fastLinearToSlowEaseIn);
                  Navigator.of(context).push(PageRouteBuilder(
                      transitionDuration: Duration(milliseconds: 600),
                      pageBuilder: (ctx, a, b) => AnimatedBuilder(
                          animation: a,
                          builder: (ctx, _) => Opacity(
                              opacity: opacity.transform(a.value),
                              child: ManageCategoriesPage()))));
                },
                child: const Text('Administrar categorías'),
              ),
              const SizedBox(
                height: 20,
              ),
              if (show) Text('¿Que puede mejorarse?'),
              if (show)
                TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  decoration: basisFormDecoration().copyWith(
                      hintText:
                          'Indica alguna mejora que pueda realizarse. ¡Nos harías un gran favor!'),
                  maxLines: 15,
                ),
              const SizedBox(
                height: 10,
              ),
              if (show)
                ElevatedButton.icon(
                    style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.resolveWith((states) => Size(size.width, 50))),
                    onPressed: () {
                      if(controller.text.isEmpty) return;
                      FirebaseFirestore.instance.collection('mejoras').add({
                        'user': context.read<UserProvider>().loggedUser!.firebaseUID,
                        'improvement': controller.text
                      }).then((value) {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return SimpleDialog(
                                title: Text('Recomendación enviada correctamente'),
                                children: [
                                  ElevatedButton(
                                      style: ButtonStyle(
                                          fixedSize: MaterialStateProperty.resolveWith(
                                              (states) => Size(150, 50))),
                                      onPressed: Navigator.of(context).pop,
                                      child: Text('Continuar'))
                                ],
                              );
                            }).then((value) {
                          changeShowStatus();
                        });
                      });
                    },
                    icon: Icon(Icons.send),
                    label: Text('Enviar'))
            ],
          ),
        ),
      ),
    );
  }
}
