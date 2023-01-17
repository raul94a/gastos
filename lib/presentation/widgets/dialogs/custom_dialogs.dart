import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/style/form_style.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

class ExpenseDialog extends StatefulWidget with MaterialStatePropertyMixin {
  const ExpenseDialog({Key? key, this.expense, this.updateHandler})
      : super(key: key);
  final Expense? expense;
  final Function(Expense)? updateHandler;

  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final TextEditingController nameController = TextEditingController(),
      descriptionController = TextEditingController(),
      priceController = TextEditingController();

  final FocusNode nameNode = FocusNode(),
      descriptionNode = FocusNode(),
      priceNode = FocusNode(),
      buttonNode = FocusNode();
  @override
  void initState() {
    super.initState();

    if (widget.expense != null) {
      nameController.text = widget.expense!.person;
      descriptionController.text = widget.expense!.description;
      priceController.text = widget.expense!.price.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    nameNode.dispose();
    descriptionNode.dispose();
    priceNode.dispose();
    buttonNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('BUILDING EXPENSE DIALOG');
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return SingleChildScrollView(
      child: Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(14.5),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nombre'),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      focusNode: nameNode,
                      decoration: basisFormDecoration(),
                      controller: nameController,
                      // onFieldSubmitted: (value) => nameNode.nextFocus(),
                    )),
                const SizedBox(
                  height: 20,
                ),
                const Text('Descripción del gasto'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    focusNode: descriptionNode,
                    decoration: basisFormDecoration(),
                    controller: descriptionController,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text('precio (€)'),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    textInputAction: TextInputAction.done,
                    focusNode: priceNode,
                    decoration: basisFormDecoration(),
                    controller: priceController,
                    //    onFieldSubmitted: (value) => priceNode.nextFocus(),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Consumer<ExpenseProvider>(
                  builder: (ctx, state, _) => ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: widget.getProperty(Size(width, 50))),
                      focusNode: buttonNode,
                      onPressed: state.loading
                          ? null
                          : () async {
                              String name = nameController.text;
                              String description = descriptionController.text;
                              String priceString =
                                  priceController.text.replaceFirst(',', '.');
                              num? price = num.tryParse(priceString);
                              if (price == null) {
                                print('Price is null');
                                return;
                              }
                              if (widget.expense == null) {
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
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : Text(widget.expense != null
                              ? 'Actualizar gasto'
                              : 'Añadir gasto')),
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<ExpenseProvider>(
                  builder: (ctx, state, _) => ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: widget.getProperty(Size(width, 50))),
                      onPressed:
                          state.loading ? null : Navigator.of(context).pop,
                      child: const Text('Cancelar')),
                )
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
    final newExpense = widget.expense!.copyWith(
        person: name,
        description: description,
        price: price,
        updatedDate: DateTime.now());
    try {
      //We're not going to update the Expense with the provider.
      widget.updateHandler!(newExpense);
      await state.update(newExpense);
      Navigator.of(context).pop();
    } catch (err) {
      print(err);
    }
  }
}
