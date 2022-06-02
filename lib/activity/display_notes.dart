import 'package:database_demo/activity/notes_add.dart';
import 'package:database_demo/activity/notes_update.dart';
import 'package:flutter/material.dart';

import '../database model/hive_data_model.dart';

class NotesDisplay extends StatefulWidget {
  const NotesDisplay({Key? key}) : super(key: key);

  @override
  State<NotesDisplay> createState() => _NotesDisplayState();
}

List notesList = [];

class _NotesDisplayState extends State<NotesDisplay> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getListOfNotes();
    });
    super.initState();
  }

  getListOfNotes() async {
    notesList = await HiveDataModel.getNotes();
    notesList.sort((a, b) => a['toBeCompleted'].compareTo(b['toBeCompleted']));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "TODO List",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          )),
      body: (ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, index) => ListTile(
          minLeadingWidth: 10,
          leading: Column(
            children: [
              const Text(
                "Do by:",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
              ),
              Text(
                "${notesList[index]['toDisplay']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
              activeColor: Colors.red,
              checkColor: Colors.black,
              value: notesList[index]['isCompleted'],
              onChanged: (value) {
                setState(() {
                  notesList[index]['isCompleted'] = value;
                });
              }),
          onTap: () async {
            print(">>>>>>>>${notesList}");
            notesList = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteUpdate(
                      title: notesList[index]['Title'],
                      description: notesList[index]['Description'],
                      id: notesList[index]['Id'],
                      toBeCompleted: notesList[index]['toBeCompleted'],
                      toDisplay: notesList[index]['toDisplay']),
                ));
            getListOfNotes();
          },
          tileColor: Colors.orange.shade200,
          onLongPress: () {
            HiveDataModel.deleteNote(key: notesList[index]['Id']);
            getListOfNotes();
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          notesList = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotes(
                  notesList: [notesList],
                ),
              ));
          getListOfNotes();
        },
        elevation: 10,
        isExtended: true,
        child: const Icon(Icons.add),
      ),
    );
  }
}
