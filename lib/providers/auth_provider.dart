import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import 'favorites_provider.dart';
import 'cart_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  AuthProvider() {
    // Escucha los cambios de estado de autenticación de Firebase
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _fetchUserDetails(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  // --- INICIAR SESIÓN ---
  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print("Error signing in: $e");
      return false;
    }
  }

  // --- REGISTRO ---
  // --- REGISTRO DE USUARIO MODIFICADO ---
  Future<bool> signUp(String email, String password, String name, String phone, String address) async {
    try {
      // 1. Crear el usuario en Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      User? firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        // 2. Guardar inmediatamente los datos extendidos en la colección 'users' de Firestore
        await _firestore.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
          'isAdmin': false, // Por defecto es cliente normal
        });
        
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      print("Error de Auth al registrar: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      print("Error general o de Firestore al registrar: $e");
      return false;
    }
  }

  // --- EDITAR PERFIL ---
  Future<bool> updateUserData(String name, String phone, String address) async {
    if (_firebaseUser == null) return false;
    try {
      await _firestore.collection('users').doc(_firebaseUser!.uid).update({
        'name': name,
        'phone': phone,
        'address': address,
      });
      
      // Actualizamos el modelo local
      _userModel = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        isAdmin: _userModel!.isAdmin,
        name: name,
        phone: phone,
        address: address,
      );
      notifyListeners();
      return true;
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

  // --- CERRAR SESIÓN ---
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    _userModel = null;
    
    // Limpiamos los datos locales de los otros Providers
    Provider.of<FavoritesProvider>(context, listen: false).clearFavorites();
    Provider.of<CartProvider>(context, listen: false).clearCart();
    
    notifyListeners();
  }
}