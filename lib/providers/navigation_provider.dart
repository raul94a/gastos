import 'package:flutter/cupertino.dart';

enum PageName {
  individual, common, info, settings
}

class NavigationProvider with ChangeNotifier {
  int page = 1;
  PageName pageName = PageName.common;


  void goTo(int index) {
    page = index;
    pageName = getPageName(index);
    notifyListeners();
  }

  PageName getPageName(int page){
    switch(page){
      case 0: return PageName.individual;
      case 1: return PageName.common;
      case 2: return PageName.info;
      case 3: return PageName.settings;
      default:
      return PageName.common;
    }
  }
}