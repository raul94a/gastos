import 'package:flutter/material.dart';
import 'package:gastos/providers/jump_buttons_provider.dart';
import 'package:gastos/providers/scroll_provider.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MainScrollNotification extends StatelessWidget {
  const MainScrollNotification(
      {super.key, required this.child, required this.controller});
  final Widget child;
  final AutoScrollController controller;
  @override
  Widget build(BuildContext context) {
    final state = context.read<JumpButtonsProvider>();
    final scrollState = context.read<ScrollProvider>();
    return NotificationListener<ScrollStartNotification>(
        onNotification: (notification) {
          state.showButtons();
          scrollState.startScrolling();
          return true;
        },
        child: NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              scrollState.finishScrolling();
              if (controller.position.pixels <=
                  controller.position.minScrollExtent) {
                state.hideButtons();
              }

              return true;
            },
            child: child));
  }
}
