import 'package:flutter_bloc_challenge/todo/data/todos_api.dart';
import 'package:flutter_bloc_challenge/todo/domain/todo/todo.dart';

import 'package:sqflite/sqflite.dart';

class LocaleStorageTodosApi extends TodosApi {
  @override
  Future<int> clearCompleted() {
    // TODO: implement clearCompleted
    throw UnimplementedError();
  }

  @override
  Future<int> completeAll({required bool isCompleted}) {
    // TODO: implement completeAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTodo(String id) {
    // TODO: implement deleteTodo
    throw UnimplementedError();
  }

  @override
  Stream<List<Todo>> getTodos() {
    // TODO: implement getTodos
    throw UnimplementedError();
  }

  @override
  Future<void> saveTodo(Todo todo) {
    // TODO: implement saveTodo
    throw UnimplementedError();
  }
}
