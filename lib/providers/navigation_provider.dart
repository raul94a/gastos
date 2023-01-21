import 'package:flutter/cupertino.dart';

class NavigationProvider with ChangeNotifier {
  int page = 0;



  void goTo(int index) {
    page = index;
    notifyListeners();
  }
}