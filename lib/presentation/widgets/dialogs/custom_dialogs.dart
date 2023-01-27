import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/expense.dart';
import 'package:gastos/presentation/style/form_style.dart';
import 'package:gastos/presentation/widgets/dialogs/expense_dialog_widgets/categories_dropdown.dart';
import 'package:gastos/presentation/widgets/shared/block_back_button.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/expense_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:provider/provider.dart';

class ExpenseDialog extends StatelessWidget with MaterialStatePropertyMixin {
  const ExpenseDialog({Key? key, this.expense, this.updateHandler, this.date})
      : super(key: key);
  final Expense? expense;
  final String? date;
  final Function(Expense)? updateHandler;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlockBackButton(
      child: SingleChildScrollView(
        child: Dialog(
          alignment: Alignment.center,
          insetPadding: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(14.5),
            child: SizedBox(
              height: size.height * 0.8,
              child: Consumer<ExpenseProvider>(
                builder: (ctx, state, _) {
                  if (expense == null && state.loading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (expense == null && state.success) {
                    return const SuccessDialog();
                  }

                  return ExpenseHandlerContent(
                    expense: expense,
                    updateHandler: updateHandler,
                    date: date,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget with MaterialStatePropertyMixin {
  const SuccessDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(
          height: 40,
        ),
        Wrap(
          runAlignment: WrapAlignment.spaceBetween,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          children: [
            Center(
              child: Icon(
                Icons.check_circle_outlined,
                color: Colors.green.shade400,
                size: 70,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('¡El gasto ha sido añadido con éxito!'),
          ],
        ),
        ElevatedButton(
            style: ButtonStyle(fixedSize: getProperty(Size(width * 0.8, 50))),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ExpenseProvider>().clear();
            },
            child: const Text('Continuar'))
      ],
    );
  }
}

class ExpenseHandlerContent extends StatefulWidget
    with MaterialStatePropertyMixin {
  const ExpenseHandlerContent(
      {super.key, this.expense, this.updateHandler, this.date});
  final Expense? expense;
  final Function(Expense)? updateHandler;
  final String? date;
  @override
  State<ExpenseHandlerContent> createState() => _ExpenseHandlerContentState();
}

class _ExpenseHandlerContentState extends State<ExpenseHandlerContent> {
  final TextEditingController nameController = TextEditingController(),
      descriptionController = TextEditingController(),
      priceController = TextEditingController();

  String selectedCategory = '';
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
    if(widget.expense != null){
      selectedCategory = widget.expense!.category;
    }else{
      selectedCategory = context.read<CategoriesProvider>().categories.first.id;

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
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final categoriesState = context.read<CategoriesProvider>();
    return Form(
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
          const SizedBox(height: 20,),
          const Text('Categoría del gasto'),
          CategoriesDropdown(
              categoriesState: categoriesState,
              selectedCategory: selectedCategory,
              categoryHandler: (str) {
                setState(() {
                  selectedCategory = str!;
                });
              }),
         
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
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Consumer<ExpenseProvider>(
            builder: (ctx, state, _) => ElevatedButton(
                style:
                    ButtonStyle(fixedSize: widget.getProperty(Size(width, 50))),
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
                          if (kDebugMode) {
                            print('Price is null');
                          }
                          return;
                        }
                        if (widget.expense == null) {
                          await createExpense(
                              context: context,
                              state: state,
                              name: name,
                              category: selectedCategory,
                              description: description,
                              price: price);
                        } else {
                          await updateExpense(
                              context: context,
                              state: state,
                              name: name,
                              category: selectedCategory,
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
                style:
                    ButtonStyle(fixedSize: widget.getProperty(Size(width, 50))),
                onPressed: state.loading ? null : Navigator.of(context).pop,
                child: const Text('Cancelar')),
          )
        ],
      ),
    );
  }

  Future<void> createExpense(
      {required BuildContext context,
      required ExpenseProvider state,
      required String name,
      required String category,
      required String description,
      required num price}) async {
    //if Date is not null, the creation is being triggered through the add button for past dates.
    //so, the only thing needed to be done is to fetch an expense from that date and borrow its createdDate
    final createdDate = widget.date != null
        ? state.expenses[widget.date!]!.first.createdDate
        : DateTime.now().toLocal();
    final updatedDate = createdDate;
    final expense = Expense(
        person: name,
        description: description,
        price: price,
        category: category,
        createdDate: createdDate,
        updatedDate: updatedDate);

    try {
      await state.add(expense);
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    } finally {}
  }

  Future<void> updateExpense(
      {required BuildContext context,
      required ExpenseProvider state,
      required String name,
      required String category,
      required String description,
      required num price}) async {
    final newExpense = widget.expense!.copyWith(
        person: name,
        description: description,
        price: price,
        category: category,
        updatedDate: DateTime.now().toLocal());
    try {
      //We're not going to update the Expense with the provider.
      widget.updateHandler!(newExpense);
      await state.update(newExpense);
      Navigator.of(context).pop();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }
}
