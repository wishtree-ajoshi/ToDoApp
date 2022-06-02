import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../database model/hive_data_model.dart';

class AddNotes extends StatefulWidget {
  List notesList;

  AddNotes({
    Key? key,
    required this.notesList,
  }) : super(key: key);

  @override
  State<AddNotes> createState() => _AddNotesState();
}

String? title, desc, dateSelected, toDisplay;

TextEditingController titleController = TextEditingController();
TextEditingController detailsController = TextEditingController();

class _AddNotesState extends State<AddNotes> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getListOfNotes();
    });
    super.initState();
  }

  getListOfNotes() async {
    widget.notesList = await HiveDataModel.getNotes();
    widget.notesList
        .sort((a, b) => a['toBeCompleted'].compareTo(b['toBeCompleted']));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
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
            lastDate: DateTime.now().add(const Duration(days: 730)),
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
              HiveDataModel.id = HiveDataModel.id + 1;
              getListOfNotes();
              titleController.clear();
              detailsController.clear();
              Navigator.of(context).pop(widget.notesList);
            },
            child: const Text('Submit'),
          ),
        ],
      )),
    );
  }
}
