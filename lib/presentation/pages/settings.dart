import 'package:flutter/material.dart';
import 'package:gastos/presentation/pages/manage_categories_page.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text('Categorías', style: GoogleFonts.robotoSerif(fontSize: 28.2)),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const ManageCategoriesPage()));
              },
              child: const Text('Administrar categorías'),
            )
          ],
        ),
      ),
    );
  }
}
