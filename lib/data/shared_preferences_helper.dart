
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  //singleton
  SharedPreferencesHelper._() {
    _init();
  }
  static SharedPreferencesHelper? _sharedPreferencesHelper;
  static SharedPreferencesHelper get instance =>
      _sharedPreferencesHelper ??= SharedPreferencesHelper._();

  final String _lastSync = "LAST_SYNC";
  final String _dateType = "DATE_TYPE";
  SharedPreferences? _prefs;

  SharedPreferences get preferences => _prefs!;
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveLastSync(String date) async {
    preferences.setString(_lastSync, date);
  }

  Future<void> saveDateType(DateType type) async {
    preferences.setString(_dateType, type.value);
  }

  String getLastSync() => preferences.getString(_lastSync) ?? "";
  DateType getDateType() {
    final type = preferences.getString(_dateType);
    if (type == null) {
      return DateType.day;
    }
    return _parseDateType(type);
  }

  DateType _parseDateType(String type) {
    switch (type) {
      case "month":
        return DateType.month;
      case "year":
        return DateType.year;
      case "week":
        return DateType.week;
      default:
        return DateType.day;
    }
  }
}

enum DateType {
  day("day"),
  month("month"),
  year("year"),
  week("week");

  final String value;
  const DateType(this.value);
}
