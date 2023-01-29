import 'package:gastos/data/enums/date_type.dart';
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
  final String _lastSyncCategories = "LAST_SYNC_CAT";
  final String _lastSyncUsers  = "LAST_SYNC_USERS";
  final String _dateType = "DATE_TYPE";
  SharedPreferences? _prefs;

  SharedPreferences get preferences => _prefs!;
  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveLastSync(int millis) async {
    preferences.setInt(_lastSync, millis);
  }

  Future<void> saveDateType(DateType type) async {
    preferences.setString(_dateType, type.value);
  }

  int getLastSync() => preferences.getInt(_lastSync) ?? 0;

  //cats
  Future<void> saveLastSyncCat(int millis) async {
    preferences.setInt(_lastSyncCategories, millis);
  }

  int getLastSyncCat() => preferences.getInt(_lastSyncCategories) ?? 0;
  //Users
  Future<void> saveLastSyncUsers(int millis) async {
    preferences.setInt(_lastSyncUsers, millis);
  }

  int getLastSyncUsers() => preferences.getInt(_lastSyncUsers) ?? 0;
  //
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
