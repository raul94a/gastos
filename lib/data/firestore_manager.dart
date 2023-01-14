import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreManager {
  FirestoreManager._() {
    _init();
  }

  static FirestoreManager? firestoreManager;
  static FirestoreManager get instance => firestoreManager ??= FirestoreManager._();

  FirebaseFirestore? _firestore;
  FirebaseFirestore get firestore => _firestore!;

  

  void _init() {
    _firestore = FirebaseFirestore.instance;
  }
}
