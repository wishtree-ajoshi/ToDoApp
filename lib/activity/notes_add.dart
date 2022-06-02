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

String? title, desc, dateSelected, toDisplay, timeDisplay;

TextEditingController titleController = TextEditingController();
TextEditingController detailsController = TextEditingController();

class _AddNotesState extends State<AddNotes> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              autofocus: true,
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DateTimePicker(
                dateMask: 'dd/MM/yyyy',
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                type: DateTimePickerType.dateTimeSeparate,
                lastDate: DateTime.now().add(const Duration(days: 730)),
                dateLabelText: "Select Date",
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    List arr = value.split('-');
                    List arr2 = arr[2].split(' ');
                    print(">>>>>>>>>>>>$arr");
                    print(">>>>>>>>>>>>$arr2");
                    setState(() {
                      String value1 = "${arr2[0]}/${arr[1]}/${arr[0]}";
                      String time = "${arr2.last}";
                      print("*********${value1}");
                      print("----------$value");
                      toDisplay = value1;
                      dateSelected = value;
                      timeDisplay = time;
                      print("----------$timeDisplay");
                    });
                  }
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    HiveDataModel.addNote(key: HiveDataModel.id, value: {
                      'Title': titleController.text,
                      'Description': detailsController.text,
                      'Id': HiveDataModel.id,
                      'isCompleted': false,
                      'toBeCompleted': dateSelected,
                      'toDisplay': toDisplay,
                      'timeDisplay': timeDisplay,
                    });
                    title = titleController.text;
                    desc = detailsController.text;
                    HiveDataModel.id = HiveDataModel.id + 1;
                    titleController.clear();
                    detailsController.clear();
                    Navigator.of(context).pop('added');
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
