import 'package:flutter/cupertino.dart';

class JumpButtonsProvider with ChangeNotifier {
  bool show = false;

  void showButtons() {
    show = true;
    notifyListeners();
  }

  void hideButtons() {
    show = false;
    notifyListeners();
  }
}
