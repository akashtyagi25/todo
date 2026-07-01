import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/user.dart';
import '../repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _repository.getCurrentUser();
    } catch (e) {
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _repository.login(email, password);
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'An error occurred during login.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _repository.register(email, password);
      notifyListeners();
      return true;
    } on StorageException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'An error occurred during registration.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
