import 'package:flutter/material.dart';

class BlockBackButton extends StatelessWidget {
  const BlockBackButton({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: child, onWillPop: () async => false);
  }
}
