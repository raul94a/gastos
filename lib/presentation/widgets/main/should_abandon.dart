import 'package:flutter/material.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';

class ShouldAbandonApp extends StatelessWidget with MaterialStatePropertyMixin {
  const ShouldAbandonApp({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: child,
        onWillPop: () async => (await shouldAbandonApp(context))!);
  }

  Future<bool?> shouldAbandonApp(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return showModalBottomSheet<bool>(
        constraints: BoxConstraints(maxHeight: size.height * 0.25),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            side: BorderSide(color: Colors.transparent, strokeAlign: 0.0)),
        context: context,
        builder: (ctx) {
          return Column(
            children: [
              SizedBox(
                height: size.height * 0.05,
              ),
              Center(
                child: Text('¿Salir de la aplicación?',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
              SizedBox(
                height: size.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: getProperty(Size(size.width * 0.3, 50))),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'No',
                        style: Theme.of(context).textTheme.labelLarge,
                      )),
                  const SizedBox(
                    width: 15,
                  ),
                  ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: getProperty(Size(size.width * 0.3, 50))),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Sí',
                        style: Theme.of(context).textTheme.labelLarge,
                      )),
                ],
              )
            ],
          );
        });
  }
}
