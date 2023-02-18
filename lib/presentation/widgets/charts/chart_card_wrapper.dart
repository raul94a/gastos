import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';

class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return child;
  }
}


///former code
// Card(
//         elevation: 10,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(10),
//             side: true ? BorderSide.none : const BorderSide(
//               strokeAlign: 0.0,
//               width: 2,
//               color: Color.fromARGB(235, 1, 1, 2),
//             )),
//         color: const Color.fromARGB(235, 17, 22, 48),