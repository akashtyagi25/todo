import 'package:hive/hive.dart';

import 'todo.dart';

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;

  @override
  Todo read(BinaryReader reader) {
    return Todo(
      id: reader.readString(),
      title: reader.readString(),
      description: reader.readString(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      priority: TodoPriority.values[reader.readByte()],
      status: TodoStatus.values[reader.readByte()],
      createdDate: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeString(obj.description)
      ..writeInt(obj.dueDate.millisecondsSinceEpoch)
      ..writeByte(obj.priority.index)
      ..writeByte(obj.status.index)
      ..writeInt(obj.createdDate.millisecondsSinceEpoch);
  }
}
