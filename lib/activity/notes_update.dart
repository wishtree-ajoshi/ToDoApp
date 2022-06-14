import 'dart:io';

import 'package:database_demo/activity/notes_add.dart';
import 'package:database_demo/notification_model/local_notification_model.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timezone/timezone.dart' as tz;
import '../database model/hive_data_model.dart';

final formKey = GlobalKey<FormState>();

class NoteUpdate extends StatefulWidget {
  String title,
      description,
      toBeCompleted,
      toDisplay,
      timeDisplay,
      noteDate,
      imageUrl;
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
    this.noteDate = '',
    this.imageUrl = '',
  }) : super(key: key);

  @override
  State<NoteUpdate> createState() => _NoteUpdateState();
}

tz.TZDateTime scheduleTime = tz.TZDateTime.now(tz.local);
List notesList = [];
List? dateFormat;
TextEditingController updateTitleController = TextEditingController();
TextEditingController updateDetailsController = TextEditingController();

class _NoteUpdateState extends State<NoteUpdate> {
  @override
  void initState() {
    super.initState();
  }

  File? image;
  Future pickImageGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
        (image.path != widget.imageUrl) ? widget.imageUrl = image.path : null;
        // print(widget.imageUrl);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) return;

      final imageTemp = File(image.path);

      setState(() {
        this.image = imageTemp;
        (image.path != widget.imageUrl) ? widget.imageUrl = image.path : null;
        //print(widget.imageUrl);
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    updateTitleController.text = widget.title;
    updateDetailsController.text = widget.description;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    initialDate: DateTime.parse(widget.noteDate),
                    firstDate: DateTime.parse(widget.noteDate),
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
                          dateFormat =
                              "${arr[0]}-${arr[1]}-${arr[2]}".split(' ');
                          widget.toDisplay = value1;
                          widget.toBeCompleted = '$value:00';
                          widget.timeDisplay = time;
                        });
                      }
                    },
                  ),
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              pickImageGallery();
                            },
                            child: const Text('Pick Image(Galley)')),
                        ElevatedButton(
                            onPressed: () {
                              pickImageCamera();
                            },
                            child: const Text('Pick Image(Camera)')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 10,
                      ),
                      child: SizedBox(
                        height: 120,
                        width: 120,
                        child: image != null
                            ? Image.file(image!)
                            : const Text("No image selected"),
                      ),
                    ),
                  ],
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
                            'noteDate': dateFormat?[0],
                            'timeDisplay': widget.timeDisplay,
                            'imageUrl': widget.imageUrl,
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
