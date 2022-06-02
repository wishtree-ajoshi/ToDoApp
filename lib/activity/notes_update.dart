import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';

import '../database model/hive_data_model.dart';

class NoteUpdate extends StatefulWidget {
  String title, description, toBeCompleted, toDisplay, timeDisplay;
  int id;
  bool isCompleted;
  NoteUpdate({
    Key? key,
    this.title = '',
    this.description = '',
    this.id = 0,
    this.toBeCompleted = '',
    this.toDisplay = '',
    this.isCompleted = false,
    this.timeDisplay = '',
  }) : super(key: key);

  @override
  State<NoteUpdate> createState() => _NoteUpdateState();
}

List notesList = [];
TextEditingController updateTitleController = TextEditingController();
TextEditingController updateDetailsController = TextEditingController();

class _NoteUpdateState extends State<NoteUpdate> {
  @override
  void initState() {
    super.initState();
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
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
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
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: DateTimePicker(
                dateMask: 'dd/MM/yyyy',
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                type: DateTimePickerType.dateTimeSeparate,
                lastDate: DateTime.now().add(const Duration(days: 730)),
                initialValue: widget.toBeCompleted,
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
                      widget.toDisplay = value1;
                      widget.toBeCompleted = value;
                      widget.timeDisplay = time;
                      print("----------${widget.timeDisplay}");
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
                    HiveDataModel.updateNote(key: widget.id, value: {
                      'Title': updateTitleController.text,
                      'Description': updateDetailsController.text,
                      'Id': widget.id,
                      'isCompleted': widget.isCompleted,
                      'toBeCompleted': widget.toBeCompleted,
                      'toDisplay': widget.toDisplay,
                    });
                    updateTitleController.clear();
                    updateDetailsController.clear();
                    Navigator.of(context).pop('updated');
                  },
                  child: const Text('Update'),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
