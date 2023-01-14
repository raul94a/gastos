import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/services/expenses_service.dart';
import 'package:gastos/presentation/style/form_style.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';

class ExpenseDialog extends StatelessWidget with MaterialStatePropertyMixin {
  const ExpenseDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nombre'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    
                    keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.none,
                      // focusNode: nameNode,
                      decoration: basisFormDecoration(),
                      controller: nameController,
                     // onFieldSubmitted: (value) => nameNode.nextFocus(),
                     
                )),
                SizedBox(
                  height: 20,
                ),
                Text('Descripción del gasto'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.none,
                      // focusNode: descriptionNode,
                      decoration: basisFormDecoration(),
                      controller: descriptionController,
                   //   onFieldSubmitted: (value) => descriptionNode.nextFocus(),
                    ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text('precio (€)'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      textInputAction: TextInputAction.none,
                      // focusNode: priceNode,
                      decoration: basisFormDecoration(),
                                            controller: priceController,
                  //    onFieldSubmitted: (value) => priceNode.nextFocus(),
                     ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ButtonStyle(fixedSize: getProperty(Size(width, 50))),
                    focusNode: buttonNode,
                    onPressed: () async {
                      //TODO: create the model
          
                      String name = nameController.text;
                      String description = descriptionController.text;
                      String priceString = priceController.text.replaceFirst(',', '.');
                      num? price = num.tryParse(priceString);
                      if (price == null) {
                        print('Price is null');
                        return;
                      }
                      final createdDate = DateTime.now().toIso8601String();
                      final updatedDate = createdDate;
                      final expense = Expense(
                          person: name,
                          description: description,
                          price: price,
                          createdDate: createdDate,
                          updatedDate: updatedDate);
                      print(expense);
                      //TODO: SEND TO THE SERVICE -> FIRESTORE
                      await ExpenseService().save(expense.toMap());
                    },
                    child: Text('Añadir gasto')),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    style: ButtonStyle(fixedSize: getProperty(Size(width, 50))),
                    onPressed: Navigator.of(context).pop,
                    child: Text('Cancelar'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
