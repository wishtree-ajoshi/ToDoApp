import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:database_demo/activity/display_notes.dart';

import 'database model/hive_data_model.dart';
import 'notification_model/local_notification_model.dart';

late Box box;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await NotificationService().initNotification();
  await HiveDataModel().createBox();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const NotesDisplay(),
    );
  }
}
