import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite/sqflite.dart';

part 'todo.g.dart'; // toJSON과 fromJSON을 사용하기 위한 더미 파일 생성용
part 'todo.freezed.dart'; // data model의 기본 property와 method를 생성용

const String tableTodo = 'todo';
const String columnId = '_id';
const String columnTitle = '_title';
const String columnDescription = '_description';
const String columnIsCompleted = '_isCompleted';
const String columnCreatedAt = '_createdAt';

@freezed
class Todo with _$Todo {
  factory Todo({
    required String id,
    required String title,
    required String createdAt,
    @Default('') String description,
    @Default(false) bool isCompleted,
  }) = _Todo;

  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
}

extension TodoEntity on Todo {
  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitle: title,
      columnDescription: description,
      columnIsCompleted: isCompleted == true ? 1 : 0,
      columnCreatedAt: createdAt,
    };
    map[columnId] = id;
    return map;
  }
}

class TodoProvider {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnDescription text not null,
  $columnIsCompleted text not null,
  $columnCreatedAt integer not null)
''');
    });
  }

  Future<Todo> insert(Todo todo) async {
    await db.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<List<Todo>> getTodos() async {
    List<Map<String, dynamic>> maps = await db.query(
      tableTodo,
      columns: [
        columnId,
        columnTitle,
        columnDescription,
        columnIsCompleted,
        columnCreatedAt
      ],
      where: '$columnId = ?',
    );
    return maps.map((e) => Todo.fromJson(e)).toList();
  }

  Future<int> delete(int id) async {
    return await db.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Todo todo) async {
    return await db.update(tableTodo, todo.toMap(),
        where: '$columnId = ?', whereArgs: [todo.id]);
  }

  Future close() async => db.close();
}
