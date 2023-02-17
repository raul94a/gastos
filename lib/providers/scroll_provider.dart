import 'package:flutter/material.dart';

class ScrollProvider with ChangeNotifier {




  bool isScrolling = false;


  startScrolling(){
    isScrolling = true;
    notifyListeners();
  }

  finishScrolling(){
    isScrolling = false;
    notifyListeners();
  }


}