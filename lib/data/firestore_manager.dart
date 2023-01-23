import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {
  FirestoreManager._() {
    _init();
  }

  static FirestoreManager? _firestoreManager;
  static FirestoreManager get instance => _firestoreManager ??= FirestoreManager._();

  FirebaseFirestore? _firestore;
  FirebaseFirestore get firestore => _firestore!;

  

  void _init() {
    _firestore = FirebaseFirestore.instance;
  }
}
