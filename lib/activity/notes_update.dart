import 'package:database_demo/notification_model/local_notification_model.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import '../database model/hive_data_model.dart';

final formKey = GlobalKey<FormState>();

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

tz.TZDateTime scheduleTime = tz.TZDateTime.now(tz.local);
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
        child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  validator: (value) {
                    return value!.isEmpty ? 'Title cannot be empty' : null;
                  },
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
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Date cannot be empty';
                      } else if (value.length < 15) {
                        return 'Incomplete Date or Time';
                      } else if (value.compareTo('${DateTime.now()}') < 0) {
                        return 'Set Time or Date Properly';
                      } else {
                        return null;
                      }
                    },
                    dateMask: 'dd/MM/yyyy',
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    type: DateTimePickerType.dateTimeSeparate,
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    initialValue: widget.toBeCompleted,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        List arr = value.split('-');
                        List arr2 = arr[2].split(' ');
                        setState(() {
                          String value1 = "${arr2[0]}/${arr[1]}/${arr[0]}";
                          String time = "${arr2.last}";
                          widget.toDisplay = value1;
                          widget.toBeCompleted = '$value:00';
                          widget.timeDisplay = time;
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
                        if (formKey.currentState!.validate()) {
                          scheduleTime = tz.TZDateTime.from(
                              DateTime.parse(widget.toBeCompleted), tz.local);

                          NotificationService().showNotification(
                            widget.id,
                            updateTitleController.text,
                            updateDetailsController.text,
                            scheduleTime,
                          );
                          HiveDataModel.updateNote(key: widget.id, value: {
                            'Title': updateTitleController.text,
                            'Description': updateDetailsController.text,
                            'Id': widget.id,
                            'isCompleted': widget.isCompleted,
                            'toBeCompleted': widget.toBeCompleted,
                            'toDisplay': widget.toDisplay,
                            'timeDisplay': widget.timeDisplay,
                          });
                          updateTitleController.clear();
                          updateDetailsController.clear();
                          Navigator.of(context).pop('updated');
                        }
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
