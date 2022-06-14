import 'package:database_demo/activity/notes_add.dart';
import 'package:database_demo/activity/notes_update.dart';
import 'package:database_demo/image_picker_demo.dart';
import 'package:database_demo/notification_model/local_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../database model/hive_data_model.dart';

class NotesDisplay extends StatefulWidget {
  const NotesDisplay({Key? key}) : super(key: key);

  @override
  State<NotesDisplay> createState() => _NotesDisplayState();
}

tz.TZDateTime scheduleTime = tz.TZDateTime.now(tz.local);
List notesList = [];
bool? done;
String? temp;

class _NotesDisplayState extends State<NotesDisplay> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getListOfNotes();
    });
    super.initState();
    tz.initializeTimeZones();
  }

  getListOfNotes() async {
    notesList = await HiveDataModel.getNotes();
    notesList.sort((a, b) => a['toBeCompleted'].compareTo(b['toBeCompleted']));
    setState(() {});
  }

  colourTile(index) {
    return (0 < '${DateTime.now()}'.compareTo(notesList[index]['toBeCompleted'])
        ? Colors.indigo.shade200
        : (notesList[index]['isCompleted'] == true)
            ? Colors.indigo.shade200
            : Colors.yellow.shade200);
  }

  void onTick(index, value) {
    if (value == true) {
      temp = notesList[index]['Title'];
      if (0 >
          '${DateTime.now()}'.compareTo(notesList[index]['toBeCompleted'])) {
        scheduleTime = tz.TZDateTime.from(
            DateTime.parse(notesList[index]['toBeCompleted']), tz.local);
        NotificationService().cancelNotifications(notesList[index]['Id']);
      }
    } else {
      temp = notesList[index]['Title'];
      if (0 >
          '${DateTime.now()}'.compareTo(notesList[index]['toBeCompleted'])) {
        scheduleTime = tz.TZDateTime.from(
            DateTime.parse(notesList[index]['toBeCompleted']), tz.local);
        NotificationService().showNotification(
          notesList[index]['Id'],
          notesList[index]['Title'],
          notesList[index]['Description'],
          scheduleTime,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade100,
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "TODO List",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )),
      body: (ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(5.0),
          child: ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            minLeadingWidth: 10,
            leading: Column(
              children: [
                const Text(
                  "Do by:",
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                ),
                Text(
                  "${notesList[index]['toDisplay']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  "${notesList[index]['timeDisplay']}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            title: Text(
              "${notesList[index]['Title']}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            subtitle: Text("${notesList[index]['Description']}",
                style: const TextStyle(fontSize: 18)),
            trailing: Checkbox(
                activeColor: Colors.black,
                checkColor: Colors.white,
                value: notesList[index]['isCompleted'],
                onChanged: (value) {
                  setState(() {
                    notesList[index]['isCompleted'] = value;
                    onTick(index, value);
                  });
                }),
            onTap: () async {
              String result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NoteUpdate(
                      title: notesList[index]['Title'],
                      description: notesList[index]['Description'],
                      id: notesList[index]['Id'],
                      toBeCompleted: notesList[index]['toBeCompleted'],
                      toDisplay: notesList[index]['toDisplay'],
                      isCompleted: notesList[index]['isCompleted'],
                      timeDisplay: notesList[index]['timeDisplay'],
                      noteDate: notesList[index]['noteDate'],
                      imageUrl: notesList[index]['imageUrl'],
                    ),
                  ));
              if (result == 'updated') {
                getListOfNotes();
              }
            },
            tileColor: colourTile(index),
            onLongPress: () {
              HiveDataModel.deleteNote(key: notesList[index]['Id']);
              NotificationService().cancelNotifications(notesList[index]['Id']);
              getListOfNotes();
            },
          ),
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotes(
                  notesList: [notesList],
                ),
              ));
          if (result == 'added') {
            getListOfNotes();
          }
        },
        elevation: 10,
        isExtended: true,
        child: const Icon(Icons.add),
      ),
    );
  }
}
