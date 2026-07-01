class User {
  const User({
    required this.id,
    required this.email,
    required this.password,
  });

  final String id;
  final String email;
  final String password;

  User copyWith({
    String? id,
    String? email,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
