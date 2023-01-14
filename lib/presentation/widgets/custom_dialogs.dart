import 'package:flutter/material.dart';
import 'package:gastos/presentation/style/form_style.dart';

Future<void> addExpenseDialog({required BuildContext context}) async {
  showDialog(
      context: context,
      builder: (ctx) {
        final size = MediaQuery.of(context).size;
        final width = size.width;
        final TextEditingController nameController = TextEditingController(),
            descriptionController = TextEditingController(),
            priceController = TextEditingController();
        final FocusNode nameNode = FocusNode(),
            descriptionNode = FocusNode(),
            priceNode = FocusNode(),
            buttonNode = FocusNode();
        return SingleChildScrollView(
          child: Dialog(
            insetPadding: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.all(14.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nombre'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: nameNode,
                      decoration: basisFormDecoration(),
                      controller: nameController,
                      onEditingComplete: nameNode.nextFocus,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Descripción del gasto'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: descriptionNode,
                      decoration: basisFormDecoration(),
                      controller: descriptionController,
                      onEditingComplete: descriptionNode.nextFocus,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('precio (€)'),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      focusNode: priceNode,
                      decoration: basisFormDecoration(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      controller: priceController,
                      onEditingComplete:  priceNode.nextFocus,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      focusNode: buttonNode,
                      onPressed: () {
                        //Todo create the model

                      },
                      child: Text('Añadir gasto')),
                  ElevatedButton(
                      onPressed: Navigator.of(ctx).pop, child: Text('Cancelar'))
                ],
              ),
            ),
          ),
        );
      });
}
