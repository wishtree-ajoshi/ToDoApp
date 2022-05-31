import 'package:flutter/material.dart';

import '../database model/hive_data_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

bool? check = false;
String? title;
String? desc;
TextEditingController titleController = TextEditingController();
TextEditingController detailsController = TextEditingController();

TextEditingController updateTitleController = TextEditingController();
TextEditingController updateDetailsController = TextEditingController();

List notesList = [];

class _NotesPageState extends State<NotesPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getListOfNotes();
    });
    super.initState();
  }

  getListOfNotes() async {
    notesList = await HiveDataModel.getNotes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print(".......${HiveDataModel.todoList?.keys}");
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        "TODO List",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      )),
      body: (ListView.builder(
        itemCount: notesList.length,
        itemBuilder: (context, index) => ListTile(
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
          onTap: () {
            print(
                "Before update:  key: ${HiveDataModel.id}....value:${notesList}");
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('Update Note'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            autofocus: true,
                            controller: updateTitleController,
                            maxLength: 20,
                            decoration: InputDecoration(
                                label: const Text("Title"),
                                hintText: notesList[index]['Title']),
                          ),
                          TextFormField(
                            controller: updateDetailsController,
                            decoration: InputDecoration(
                                label: const Text("Description"),
                                hintText: notesList[index]['Description']),
                          ),
                          Row(
                            children: [
                              const Text("Completed"),
                              Checkbox(
                                  value: notesList[index]['isCompleted'],
                                  onChanged: (value) {
                                    setState(() {
                                      notesList[index]['isCompleted'] = value;
                                    });
                                  }),
                            ],
                          )
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            HiveDataModel.updateNote(
                                key: notesList[index]['Id'],
                                value: {
                                  'Title': updateTitleController.text,
                                  'Description': updateDetailsController.text,
                                  'Id': notesList[index]['Id'],
                                  'isCompleted': notesList[index]
                                      ['isCompleted'],
                                });
                            updateTitleController.clear();
                            updateDetailsController.clear();
                            getListOfNotes();
                            print(
                                "After updating: key: ${HiveDataModel.id}....value:${notesList}");
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ));
          },
          tileColor: Colors.orange.shade200,
          onLongPress: () {
            print(
                "before delete:.....key: ${HiveDataModel.id}....value:${notesList}");
            HiveDataModel.deleteNote(key: notesList[index]['Id']);
            getListOfNotes();
            print(
                "After delete.....key: ${HiveDataModel.id}....value:${notesList}");
          },
        ),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: const Text('Add Note'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: titleController,
                          maxLength: 20,
                          decoration: const InputDecoration(
                              label: Text("Title"), hintText: "Enter Title"),
                        ),
                        TextFormField(
                          controller: detailsController,
                          decoration: const InputDecoration(
                            hintText: "Enter Description",
                            label: Text("Description"),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          HiveDataModel.addNote(key: HiveDataModel.id, value: {
                            'Title': titleController.text,
                            'Description': detailsController.text,
                            'Id': HiveDataModel.id,
                            'isCompleted': false,
                          });
                          title = titleController.text;
                          desc = detailsController.text;
                          getListOfNotes();

                          HiveDataModel.id = HiveDataModel.id + 1;
                          titleController.clear();
                          detailsController.clear();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  )).then((value) => setState(() {
                print(
                    "After Adding...key: ${HiveDataModel.id}....value:${notesList}");
              }));
        },
        elevation: 10,
        isExtended: true,
        child: const Icon(Icons.add),
      ),
    );
  }
}
