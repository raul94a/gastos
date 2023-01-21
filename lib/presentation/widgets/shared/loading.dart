import 'package:flutter/material.dart';
class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
   return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:  [
            CircularProgressIndicator.adaptive(
              backgroundColor: Colors.blue.shade100,
            ),
            const Text('Cargando...')
          ],
        ),
      );
  }
}