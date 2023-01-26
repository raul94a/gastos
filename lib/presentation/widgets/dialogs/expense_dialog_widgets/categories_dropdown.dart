import 'package:flutter/material.dart';
import 'package:gastos/providers/categories_provider.dart';

class CategoriesDropdown extends StatelessWidget {
  const CategoriesDropdown(
      {super.key,
      required this.categoriesState,
      required this.selectedCategory,
      required this.categoryHandler});
  final Function(String?) categoryHandler;
  final CategoriesProvider categoriesState;
  final String selectedCategory;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        underline: Container(
          height: 1.5,
          width: 1.5,
          color: Colors.black,
        ),
        menuMaxHeight: size.height * 0.4,
        isExpanded: true,
        value: selectedCategory,
        onChanged: categoryHandler,
        items: categoriesState.categories
            .map((e) => DropdownMenuItem<String>(
                value: e.id,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(e.r, e.g, e.b, 1),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(e.name),
                  ],
                )))
            .toList(),
      ),
    );
  }
}
