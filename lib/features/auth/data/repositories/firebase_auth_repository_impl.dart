import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'dart:convert';
import 'dart:io';
import 'package:temporal_zodiac/features/auth/domain/entities/user.dart';
import 'package:temporal_zodiac/features/auth/domain/repositories/auth_repository.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final uid = userCredential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        throw Exception('User data not found in Firestore');
      }

      final data = doc.data()!;
      return User(
        id: uid,
        name: data['name'] ?? '',
        email: email,
        phone: data['phone'],
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<User> signUp(String name, String email, String password, String phone) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;
      
      final user = User(
        id: uid,
        name: name,
        email: email,
        phone: phone,
      );

      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'uid': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } catch (e) {
      throw Exception('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Forgot password failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
         final data = doc.data()!;
         return User(
           id: firebaseUser.uid,
           name: data['name'] ?? '',
           email: firebaseUser.email ?? '',
           phone: data['phone'],
           photoUrl: data['photoUrl'],
         );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<User> updateProfile(User user) async {
    try {
      final uid = user.id;
      await _firestore.collection('users').doc(uid).update({
        'name': user.name,
        'phone': user.phone,
        'photoUrl': user.photoUrl,
      });

      // Update Firebase Auth profile
      await _firebaseAuth.currentUser?.updateDisplayName(user.name);
      if (user.photoUrl != null) {
        await _firebaseAuth.currentUser?.updatePhotoURL(user.photoUrl);
      }

      return user;
    } catch (e) {
      throw Exception('Update profile failed: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      return base64Image;
    } catch (e) {
      throw Exception('Image processing failed: ${e.toString()}');
    }
  }
}
