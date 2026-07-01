import 'package:hive/hive.dart';

import 'user.dart';

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    return User(
      id: reader.readString(),
      email: reader.readString(),
      password: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.email)
      ..writeString(obj.password);
  }
}
