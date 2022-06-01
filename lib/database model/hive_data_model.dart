import 'package:database_demo/activity/notesdisplay.dart';
import 'package:hive/hive.dart';

class HiveDataModel {
  static Box? todoList;
  static int id = (notesList.isEmpty) ? 0 : notesList.length + 1;

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
    todoList?.put(key, value).then((value) {
      getNotes();
    });
  }

  static deleteNote({key}) async {
    todoList?.delete(key);
    return getNotes();
  }
}
