import 'package:hive/hive.dart';

import '../core/errors/app_exception.dart';
import '../models/user.dart';
import 'hive_service.dart';

class AuthLocalService {
  AuthLocalService._({required Box<User> usersBox, required Box<dynamic> authBox})
      : _usersBox = usersBox,
        _authBox = authBox;

  final Box<User> _usersBox;
  final Box<dynamic> _authBox;

  static Future<AuthLocalService> create() async {
    final usersBox = await HiveService.openUsersBox();
    final authBox = await HiveService.openAuthBox();
    return AuthLocalService._(usersBox: usersBox, authBox: authBox);
  }

  Future<User?> getCurrentUser() async {
    final currentUserId = _authBox.get('currentUserId') as String?;
    if (currentUserId != null) {
      return _usersBox.get(currentUserId);
    }
    return null;
  }

  Future<User> login(String email, String password) async {
    final users = _usersBox.values;
    try {
      final user = users.firstWhere(
        (u) => u.email == email && u.password == password,
      );
      await _authBox.put('currentUserId', user.id);
      return user;
    } catch (e) {
      throw StorageException('Invalid email or password.');
    }
  }

  Future<User> register(String email, String password) async {
    final users = _usersBox.values;
    final exists = users.any((u) => u.email == email);
    if (exists) {
      throw StorageException('Email already in use.');
    }
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = User(id: id, email: email, password: password);
    
    await _usersBox.put(id, user);
    await _authBox.put('currentUserId', id);
    return user;
  }

  Future<void> logout() async {
    await _authBox.delete('currentUserId');
  }
}
