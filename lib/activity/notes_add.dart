import 'dart:io';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:database_demo/notification_model/local_notification_model.dart';
import '../database model/hive_data_model.dart';
import '../image_selection/image_picker.dart';

class AddNotes extends StatefulWidget {
  List notesList;

  AddNotes({
    Key? key,
    required this.notesList,
  }) : super(key: key);

  @override
  State<AddNotes> createState() => _AddNotesState();
}

final formKey = GlobalKey<FormState>();
String? title, desc;
List? dateFormat;
String dateSelected = '', toDisplay = '', timeDisplay = '', imageUrl = '';
tz.TZDateTime scheduleTime = tz.TZDateTime.now(tz.local);
TextEditingController titleController = TextEditingController();
TextEditingController detailsController = TextEditingController();
File? _image;

class _AddNotesState extends State<AddNotes> {
  @override
  void initState() {
    super.initState();
  }

  ///Show notifications of different types....
  void showNotifications() {
    if (imageUrl == '') {
      NotificationService().showNotification(
        HiveDataModel.id,
        titleController.text,
        detailsController.text,
        scheduleTime,
      );
    } else {
      NotificationService().showImageNotification(
        HiveDataModel.id,
        titleController.text,
        detailsController.text,
        scheduleTime,
        imageUrl,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() {
        titleController.clear();
        detailsController.clear();
        imageUrl = '';
        _image = null;
        Navigator.pop(context);
        return Future.value(false);
      }),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Add Note'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
          child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    validator: (value) {
                      return value!.isEmpty ? 'Title cannot be empty' : null;
                    },
                    autofocus: true,
                    controller: titleController,
                    maxLength: 20,
                    decoration: const InputDecoration(label: Text("Title*")),
                  ),
                  TextFormField(
                    controller: detailsController,
                    decoration:
                        const InputDecoration(label: Text("Description")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DateTimePicker(
                      ///Validator for submit....
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
                      timeLabelText: "Select Time*",
                      dateLabelText: "Select Date*",
                      errorFormatText: "Select valid time",
                      onChanged: (value) {
                        if (value.isNotEmpty && value.split(' ').length > 1) {
                          List arr = value.split('-');
                          List arr2 = arr[2].split(' ');
                          setState(() {
                            String value1 = "${arr2[0]}/${arr[1]}/${arr[0]}";
                            String time = "${arr2.last}";
                            dateFormat =
                                "${arr[0]}-${arr[1]}-${arr[2]}".split(' ');
                            toDisplay = value1;
                            dateSelected = "$value:00";
                            timeDisplay = time;
                          });
                        }
                      },
                    ),
                  ),

                  ///Pick Image from Gallery....
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          imageUrl = await ImageSelector()
                              .pickImageGallery(imageUrl, _image);
                          if (imageUrl == null) {
                            if (_image == null) {
                              imageUrl = '';
                            } else {
                              imageUrl = _image!.path;
                            }
                          }
                          final File newImage = File(imageUrl);
                          setState(() {
                            _image = newImage;
                          });
                        },
                        child: const Text('Pick Image(Galley)')),
                  ),

                  ///Pick Image from Camera....
                  ElevatedButton(
                      onPressed: () async {
                        imageUrl = await ImageSelector()
                            .pickImageCamera(imageUrl, _image);
                        if (imageUrl == null) {
                          if (_image == null) {
                            imageUrl = '';
                          } else {
                            imageUrl = _image!.path;
                          }
                        }
                        final File newImage = File(imageUrl);
                        setState(() {
                          _image = newImage;
                        });
                      },
                      child: const Text('Pick Image(Camera)')),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 10,
                    ),

                    ///Display image as Preview...
                    child: SizedBox(
                      height: 150,
                      width: 150,
                      child: imageUrl != ''
                          ? Image.file(_image!)
                          : const Text("No image selected"),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            scheduleTime = tz.TZDateTime.from(
                                DateTime.parse(dateSelected), tz.local);

                            showNotifications();

                            HiveDataModel.addNote(
                                key: HiveDataModel.id,
                                value: {
                                  'Title': titleController.text,
                                  'Description': detailsController.text,
                                  'Id': HiveDataModel.id,
                                  'isCompleted': false,
                                  'toBeCompleted': dateSelected,
                                  'toDisplay': toDisplay,
                                  'noteDate': dateFormat?[0],
                                  'timeDisplay': timeDisplay,
                                  'imageUrl': imageUrl,
                                  'dateAdded': DateTime.now().toString(),
                                });
                            title = titleController.text;
                            desc = detailsController.text;
                            HiveDataModel.id = HiveDataModel.id + 1;
                            titleController.clear();
                            detailsController.clear();
                            imageUrl = '';
                            Navigator.of(context).pop('added');
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
