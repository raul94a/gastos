import 'package:flutter/cupertino.dart';

class ShowExpensesProvider with ChangeNotifier {
  final Map<int, bool> _showStates = {};
  bool initialized = false;
//getters
  Map<int, bool> get showStates => _showStates;

//methods
  bool _containsIndex(int index) {
    return _showStates.containsKey(index);
  }

  void initStates(int index) {
    if (initialized || _containsIndex(index)) return;
    const enabled = true;
    _showStates.addAll({index: enabled});
    if (_showStates.keys.length >= 5) {
      initialized = true;
    }
   
  }

  void updateState(int index, bool enabled) {
    
    if (_containsIndex(index)) {
      _showStates[index] = enabled;
      notifyListeners();
    }
  }

  bool getState(int index) {
    if (_containsIndex(index)) {
      return _showStates[index]!;
    }
    return false;
  }
}
