import 'package:database_demo/activity/display_notes.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../database model/hive_data_model.dart';

class NoteUpdate extends StatefulWidget {
  String title, description, toBeCompleted, toDisplay;
  int id;
  bool isCompleted;
  NoteUpdate(
      {Key? key,
      this.title = '',
      this.description = '',
      this.id = 0,
      this.toBeCompleted = '',
      this.toDisplay = '',
      this.isCompleted = false})
      : super(key: key);

  @override
  State<NoteUpdate> createState() => _NoteUpdateState();
}

List notesList = [];
TextEditingController updateTitleController = TextEditingController();
TextEditingController updateDetailsController = TextEditingController();

class _NoteUpdateState extends State<NoteUpdate> {
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
    updateTitleController.text = widget.title;
    updateDetailsController.text = widget.description;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Note'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
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
            lastDate: DateTime.now().add(const Duration(days: 730)),
            initialValue: widget.toBeCompleted,
            onChanged: (value) {
              if (value.isNotEmpty) {
                List arr = value.split('-');
                String value1 = "${arr[2]}/${arr[1]}/${arr[0]}";
                widget.toBeCompleted = value;
                widget.toDisplay = value1;
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              HiveDataModel.updateNote(key: widget.id, value: {
                'Title': updateTitleController.text,
                'Description': updateDetailsController.text,
                'Id': widget.id,
                'isCompleted': widget.isCompleted,
                'toBeCompleted': widget.toBeCompleted,
                'toDisplay': widget.toDisplay,
              });
              getListOfNotes();
              updateTitleController.clear();
              updateDetailsController.clear();
              Navigator.of(context).pop(notesList);
            },
            child: const Text('Update'),
          ),
        ],
      )),
    );
  }
}
