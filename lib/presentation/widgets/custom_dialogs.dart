import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/data/services/expenses_service.dart';
import 'package:gastos/presentation/style/form_style.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

class ExpenseDialog extends StatelessWidget with MaterialStatePropertyMixin {
  const ExpenseDialog({Key? key, this.expense}) : super(key: key);
  final Expense? expense;
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

    if (expense != null) {
      nameController.text = expense!.person;
      descriptionController.text = expense!.description;
      priceController.text = expense!.price.toString();
    }

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
                Consumer<ExpenseProvider>(
                  builder: (ctx, state, _) => ElevatedButton(
                      style:
                          ButtonStyle(fixedSize: getProperty(Size(width, 50))),
                      focusNode: buttonNode,
                      onPressed: state.loading
                          ? null
                          : () async {
                              //TODO: create the model

                              String name = nameController.text;
                              String description = descriptionController.text;
                              String priceString =
                                  priceController.text.replaceFirst(',', '.');
                              num? price = num.tryParse(priceString);
                              if (price == null) {
                                print('Price is null');
                                return;
                              }
                              if (expense == null) {
                                await createExpense(
                                    context: context,
                                    state: state,
                                    name: name,
                                    description: description,
                                    price: price);
                              } else {
                                await updateExpense(
                                    context: context,
                                    state: state,
                                    name: name,
                                    description: description,
                                    price: price);
                              }
                            },
                      child: state.loading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text('Añadir gasto')),
                ),
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

  Future<void> createExpense(
      {required BuildContext context,
      required ExpenseProvider state,
      required String name,
      required String description,
      required num price}) async {
    final createdDate = DateTime.now();
    final updatedDate = createdDate;
    final expense = Expense(
        person: name,
        description: description,
        price: price,
        createdDate: createdDate,
        updatedDate: updatedDate);
    print(expense);

    try {
      await state.add(expense);
      Navigator.of(context).pop();
    } catch (err) {
      print(err);
    } finally {}
  }

  Future<void> updateExpense(
      {required BuildContext context,
      required ExpenseProvider state,
      required String name,
      required String description,
      required num price}) async {
    final newExpense = expense!.copyWith(
        person: name,
        description: description,
        price: price,
        updatedDate: DateTime.now());
    try {
      await state.update(newExpense);
      Navigator.of(context).pop();
    } catch (err) {
      print(err);
    }
  }
}
