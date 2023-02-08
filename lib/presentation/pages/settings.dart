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
                const opacity =
                    Interval(0, 0.75, curve: Curves.fastLinearToSlowEaseIn);
                Navigator.of(context).push(PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 600),
                    pageBuilder: (ctx, a, b) => AnimatedBuilder(
                        animation: a,
                        builder: (ctx, _) => Opacity(
                            opacity: opacity.transform(a.value),
                            child: ManageCategoriesPage()))));
              },
              child: const Text('Administrar categorías'),
            )
          ],
        ),
      ),
    );
  }
}
