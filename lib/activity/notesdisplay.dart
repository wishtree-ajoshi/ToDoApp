/*


///ABANDONED


import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import '../database model/hive_data_model.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

bool? check = false;
String? title, desc, dateSelected, toDisplay;

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
          onTap: () {
            updateTitleController.text = notesList[index]['Title'];
            updateDetailsController.text = notesList[index]['Description'];
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
                            decoration: const InputDecoration(
                              label: Text("Title"),
                            ),
                          ),
                          TextFormField(
                            controller: updateDetailsController,
                            decoration: const InputDecoration(
                              label: Text("Description"),
                            ),
                          ),
                          DateTimePicker(
                            dateMask: 'dd/MM/yyyy',
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            type: DateTimePickerType.date,
                            lastDate:
                                DateTime.now().add(const Duration(days: 730)),
                            initialValue: notesList[index]['toBeCompleted'],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                List arr = value.split('-');
                                String value1 = "${arr[2]}/${arr[1]}/${arr[0]}";
                                setState(() {
                                  notesList[index]['toBeCompleted'] = value;
                                  notesList[index]['toDisplay'] = value1;
                                });
                              }
                            },
                          ),
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
                                  'toBeCompleted': notesList[index]
                                      ['toBeCompleted'],
                                  'toDisplay': notesList[index]['toDisplay'],
                                });
                            updateTitleController.clear();
                            updateDetailsController.clear();
                            getListOfNotes();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Update'),
                        ),
                      ],
                    ));
          },
          tileColor: Colors.orange.shade200,
          onLongPress: () {
            HiveDataModel.deleteNote(key: notesList[index]['Id']);
            getListOfNotes();
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
                        DateTimePicker(
                          dateMask: 'dd/MM/yyyy',
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          type: DateTimePickerType.date,
                          lastDate:
                              DateTime.now().add(const Duration(days: 730)),
                          dateLabelText: "Select Date",
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              List arr = value.split('-');
                              String value1 = "${arr[2]}/${arr[1]}/${arr[0]}";
                              setState(() {
                                dateSelected = value;
                                toDisplay = value1;
                              });
                            }
                          },
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
                            'toBeCompleted': dateSelected,
                            'toDisplay': toDisplay,
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
                  )).then((value) => setState(() {}));
        },
        elevation: 10,
        isExtended: true,
        child: const Icon(Icons.add),
      ),
    );
  }
}

*/