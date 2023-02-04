// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastos/data/models/user.dart';
import 'package:gastos/data/repository/users_repository.dart';
import 'package:gastos/data/shared_preferences_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProvider with ChangeNotifier {
  UserProvider();

  final List<AppUser> _users = [];
  final repository = UserRepository();
  final preferences = SharedPreferencesHelper.instance;

  AppUser? _loggedUser;

  AppUser? get loggedUser => _loggedUser;

  //control vars

  bool error = false;
  bool loading = false;

  //getter
  List<AppUser> get users => _users;

  //methods

  Future<void> initialLoad() async {
    fetchUsers().then((_) async {
      await read();
    });
  }

  Future<void> fetchUsers() async {
    

    try {
      await repository.fetchLastSync(preferences.getLastSyncUsers());
    } catch (err) {
   
      rethrow;
    } finally {
     
     // notifyListeners();
      //Not really needed to notify loading false because it is gonna be called in get method
    }
  }

  Future<void> add(AppUser user) async {
    loading = true;
    notifyListeners();
    try {
      await repository.save(user);
    } catch (err) {
      print(err);
      rethrow;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> read() async {
    final res = await repository.readAll();
    print('USERS FROM DB: $res');
    _users.addAll(res);
    notifyListeners();
  }

  void clear() {
    _users.clear();
  }

  Future<void> refreshData() async {
    print('Refreshing users');
    final lastSync = preferences.getLastSyncUsers();
    final newEntries = await repository.fetchLastSyncUsers(lastSync);
    if (newEntries.isNotEmpty) {
      for (final entry in newEntries) {
        if (!await repository.existsId(entry.firebaseUID)) {
          _users.add(entry);
          notifyListeners();
        }
      }
    }
  }

  Future<void> signUP(AppUser user) async {
    repository.save(user);
    _loggedUser = user;
  }

  Future<void> signIn(AppUser user) async {
    _loggedUser = user;
  }

  Future<void> setLoggedUser(String id) async {
    final user = await repository.readOne(id);
    _loggedUser = user;
  }

  Future<void> createUser(
      BuildContext context, String email, String password, String name) async {
    try {
      print(await repository.service.readAll());
      loading = true;
      notifyListeners();
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(credential);
      //create user on firestore
      final user = credential.user;

      await signUP(AppUser(
          firebaseUID: user!.uid,
          email: user.email!,
          name: name,
          createdDate: DateTime.now(),
          updatedDate: DateTime.now()));

      //create user on local db
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        showErrorDialog(context, 'Error', 'El email ya está en uso');
      }
    } catch (e) {
      print(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      loading = true;
      notifyListeners();
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = await repository.readOne(credential.user!.uid);
      print('USER FROM DB: $user');
      await signIn(user);
    } on FirebaseAuthException catch (e) {
      print(e);
      showErrorDialog(
          context, 'Error', 'Alguna de las credenciales no es correcta');
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future showErrorDialog(BuildContext context, String title, String content) {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title:
                  Text(title, style: GoogleFonts.robotoSerif(fontSize: 24.2)),
              content:
                  Text(content, style: GoogleFonts.raleway(fontSize: 14.2)),
            ));
  }
}
