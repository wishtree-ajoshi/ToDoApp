import 'package:hive/hive.dart';

import '../activity/notesdisplay.dart';

class HiveDataModel {
  static Box? todoList;
  static int id = (notesList.isEmpty) ? 0 : notesList.length;

  createBox() async {
    todoList = await Hive.openBox('todoList');
  }

  static Future addNote({key, value}) async {
    todoList?.put(key, value).then((value) {
      getNotes();
    });
  }

  static Future<dynamic> getNotes() async {
    return todoList?.values.cast().toList();
  }

  static updateNote({key, value}) async {
    todoList?.putAt(key, value).then((value) {
      getNotes();
    });
  }

  static deleteNote({key}) async {
    if (id > 0) {
      id = id - 1;
    }
    todoList?.delete(key);
    return getNotes();
  }
}
