import '../models/user.dart';
import '../services/auth_local_service.dart';

class AuthRepository {
  AuthRepository({required AuthLocalService localService})
      : _localService = localService;

  final AuthLocalService _localService;

  Future<User?> getCurrentUser() => _localService.getCurrentUser();

  Future<User> login(String email, String password) =>
      _localService.login(email, password);

  Future<User> register(String email, String password) =>
      _localService.register(email, password);

  Future<void> logout() => _localService.logout();
}
