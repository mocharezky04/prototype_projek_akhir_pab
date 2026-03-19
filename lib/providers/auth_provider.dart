import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/auth_service.dart';
import '../models/profile.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();
  Profile? profile;
  bool isLoading = false;
  String? error;
  List<Profile> users = [];

  bool get isLoggedIn => _service.currentUser != null;
  String? get role => profile?.role;

  Stream<AuthState> get authChanges => _service.onAuthStateChange;

  Future<void> login(String email, String password) async {
    _setLoading(true);
    error = null;
    try {
      await _service.signIn(email: email, password: password);
      await loadProfile();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    error = null;
    try {
      await _service.signUp(email: email, password: password);
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProfile() async {
    final user = _service.currentUser;
    if (user == null) return;
    error = null;
    try {
      profile = await _service.fetchOrCreateProfile(user.id, user.email ?? '');
    } catch (e) {
      error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _setLoading(true);
    error = null;
    try {
      users = await _service.fetchProfiles();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateRole(String userId, String role) async {
    _setLoading(true);
    error = null;
    try {
      await _service.updateRole(userId, role);
      await loadUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _service.signOut();
    profile = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}
