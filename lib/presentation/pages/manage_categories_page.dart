import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gastos/data/models/category.dart';
import 'package:gastos/providers/categories_provider.dart';
import 'package:gastos/providers/users_provider.dart';
import 'package:gastos/utils/material_state_property_mixin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ManageCategoriesPage extends StatelessWidget
    with MaterialStatePropertyMixin {
  const ManageCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final a = context.read<UserProvider>();
    print(a.loggedUser);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text('Tus categorías',
              textAlign: TextAlign.center,
              style: GoogleFonts.robotoSerif(fontSize: 28.2)),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Actualiza o Añade una nueva categoría',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(fontSize: 16.2)),
                  //column for the list of categories
                  Consumer<CategoriesProvider>(
                      builder: (ctx, state, _) =>
                          _CategoriesList(categoriesProvider: state)),
                  //button for adding??
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer<CategoriesProvider>(
                    builder: (ctx, state, _) => Visibility(
                      visible: !state.categories
                          .any((element) => element.deleted == 1),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              alignment: Alignment.center,
                              fixedSize: getProperty(Size(width * 0.92, 50))),
                          onPressed: state.addEmpty,
                          child: Text('Añadir nueva categoria',
                              style: GoogleFonts.raleway())),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categoriesProvider});
  final CategoriesProvider categoriesProvider;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final containerWidth = size.width * 0.45;
    const containerHeight = 250.0;
    final List<Widget> widgets2 = categoriesProvider.categories
        .map((category) => CategoryCard(
            containerHeight: containerHeight,
            containerWidth: containerWidth,
            state: categoriesProvider,
            category: category))
        .toList();

    return GridView(
      shrinkWrap: true,
      primary: false,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 3.0,
          mainAxisExtent: containerHeight),
      children: widgets2,
    );
  }

  InputBorder fieldBorderUnderline() {
    return const UnderlineInputBorder();
  }

  InputBorder fieldBorderOutlined(Color color, double width) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width));
  }
}

class PickColorContainer extends StatefulWidget {
  const PickColorContainer(
      {Key? key,
      required this.addMode,
      required this.category,
      required this.width,
      this.colorPicker,
      required this.height})
      : super(key: key);

  final Category category;
  final double width, height;
  final bool addMode;
  final Function(Color)? colorPicker;
  @override
  State<PickColorContainer> createState() => _PickColorContainerState();
}

class _PickColorContainerState extends State<PickColorContainer> {
  late Color selectedColor;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    selectedColor = Color.fromARGB(
        200, widget.category.r, widget.category.g, widget.category.b);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // print('something has hchanged!!');
    return GestureDetector(
        key: UniqueKey(),
        onTap: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return Dialog(
                  child: ColorPicker(
                      labelTypes: const [ColorLabelType.rgb],
                      pickerColor: selectedColor,
                      onColorChanged: (color) {
                        //update color
                        //print('Color');
                        debounceColor(() => pickColorHandler(color));
                      }),
                );
              });
        },
        child: Container(
          key: Key(widget.category.id),
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: null,
            color: Color.fromARGB(200, selectedColor.red, selectedColor.green,
                selectedColor.blue),
          ),
        ));
  }

  void pickColorHandler(Color color) async {
    if (widget.addMode) {
      widget.colorPicker!(color);
      setState(() {
        selectedColor = color;
      });
      return;
    }

    Category newCa =
        widget.category.copyWith(r: color.red, g: color.green, b: color.blue);

    context.read<CategoriesProvider>().updateLocal(newCa);
    setState(() {
      selectedColor = color;
    });
  }

  void debounceColor(Function() callback) {
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer(const Duration(milliseconds: 700), () {
      callback();
      timer?.cancel();
    });
  }
}

// ignore: must_be_immutable
class CategoryCard extends StatelessWidget {
  CategoryCard(
      {super.key,
      required this.containerHeight,
      required this.containerWidth,
      required this.state,
      required this.category});
  final double containerHeight, containerWidth;
  final Category category;
  final CategoriesProvider state;
  Timer? timer;
  @override
  Widget build(BuildContext context) {
    bool addMode = category.deleted == 1;
    return SizedBox(
      height: containerHeight,
      width: containerWidth,
      child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //container for the color
                PickColorContainer(
                    addMode: addMode,
                    colorPicker: !addMode
                        ? null
                        : (color) {
                            final index = state.categories
                                .indexWhere((element) => element.deleted == 1);
                            state.categories[index] = category.copyWith(
                                r: color.red, g: color.green, b: color.blue);
                          },
                    category: category,
                    width: containerWidth,
                    height: containerHeight * 0.35),
                //TextField for the name
                if (addMode)
                  TextButton(
                      style: ButtonStyle(
                          padding: MaterialStateProperty.resolveWith(
                              (states) => EdgeInsets.zero)),
                      onPressed: () {
                        final index = state.categories
                            .indexWhere((element) => element.deleted == 1);
                        state.categories[index] = category.copyWith(
                          deleted: 0,
                          createdDate: DateTime.now(),
                        );

                        state.add(state.categories[index]);
                      },
                      child: Text(
                        'Añadir',
                        style: GoogleFonts.raleway(),
                      )),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nombre',
                      style: GoogleFonts.raleway(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      style: GoogleFonts.raleway(),
                      initialValue: addMode ? '' : category.name,
                      decoration: InputDecoration(
                          hintText: addMode ? category.name : '',
                          border: fieldBorderOutlined(
                              Colors.lightBlueAccent.shade200, 0.75),
                          enabledBorder: fieldBorderOutlined(
                              Colors.lightBlueAccent.shade700, 0.95),
                          focusedBorder: fieldBorderOutlined(
                              Colors.lightBlueAccent.shade700, 0.95)),
                      onChanged: (value) {
                        debounce(() {
                          if (addMode) {
                            final index = state.categories
                                .indexWhere((element) => element.deleted == 1);
                            state.categories[index] =
                                category.copyWith(name: value);
                            return;
                          }
                          //update name
                          Category newCat = category.copyWith(
                              name: value, updatedDate: DateTime.now());
                          state.update(newCat);
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }

  void debounce(Function() callback) {
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer(const Duration(milliseconds: 700), () {
      callback();
    });
  }

  InputBorder fieldBorderUnderline() {
    return const  UnderlineInputBorder();
  }

  InputBorder fieldBorderOutlined(Color color, double width) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: color, width: width));
  }
}
