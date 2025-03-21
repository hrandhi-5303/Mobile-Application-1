import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lesson3/controller/cloudstorage_controller.dart';
import 'package:lesson3/controller/firestore_controller.dart';
import 'package:lesson3/controller/ml_controller.dart';
import 'package:lesson3/model/constant.dart';
import 'package:lesson3/model/photo_memo.dart';
import 'package:lesson3/viewscreen/view/view_util.dart';

class AddPhotoMemoScreen extends StatefulWidget {
  static const routeName = '/addPhotoMemoScreen';

  final User user;
  List<PhotoMemo> photoMemoList;

  AddPhotoMemoScreen({
    required this.user,
    required this.photoMemoList,
    Key? key
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddPhotoMemoState();
  }
}

class _AddPhotoMemoState extends State<AddPhotoMemoScreen> {
  late _Controller con;
  var formKey = GlobalKey<FormState>();
  File? photo;

  // int radioGroupValue=0;

  // Initial Selected Value
  String dropdownvalue = 'label';

  // List of items in our dropdown menu
  var items = [
    'label',
    'text',
  ];

  @override
  void initState() {
    super.initState();
    con = _Controller(this);
    con.currentMLValue="label";
  }

  void render(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add A New Memo'),
        actions: [
          IconButton(
            onPressed: con.uploadMemo,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                    child: photo == null
                        ? const FittedBox(
                      child: Icon(Icons.photo_library),
                    )
                        : Image.file(photo!),
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Container(
                      color: Colors.blue[200],
                      child: PopupMenuButton(
                        onSelected: con.getPhoto,
                        itemBuilder: (context) => [
                          for (var source in PhotoSource.values)
                            PopupMenuItem(
                              value: source,
                              child: Text(source.name.toUpperCase()),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0.0,
                    bottom: 0.0,
                    child: con.progressMessage == null
                        ? const SizedBox(
                      height: 1.0,
                    )
                        : Container(
                      color: Colors.blue[200],
                      child: Text(
                        con.progressMessage!,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Title'),
                autocorrect: true,
                validator: PhotoMemo.validateTitle,
                onSaved: con.saveTitle,
              ),
              TextFormField(
                decoration: const InputDecoration(hintText: 'Memo'),
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                validator: PhotoMemo.validateMemo,
                onSaved: con.saveMemo,
              ),
              TextFormField(
                decoration: const InputDecoration(
                    hintText:
                    'Shared with (email list separated by space , ; )'),
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                maxLines: 2,
                validator: PhotoMemo.validateSharedWith,
                onSaved: con.saveSharedWith,
              ),

              SizedBox(height: 10,),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Apply Machine learning by : ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton(
                    // Initial Value
                    value: dropdownvalue,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(items),
                      );
                    }).toList(),
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                             con.currentMLValue=dropdownvalue;
                      });
                    },
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class _Controller {
  _AddPhotoMemoState state;
  PhotoMemo tempMemo = PhotoMemo();
  String? progressMessage;
  String? currentMLValue;
  _Controller(this.state);

  void getPhoto(PhotoSource source) async {
    try {
      var imageSource = source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery;
      XFile? image = await ImagePicker().pickImage(source: imageSource);
      if (image == null) return; //
      // canceled

      state.render(() => state.photo = File(image.path));
    } catch (e) {
      if (Constant.devMode) print('======== failed to get pic: $e');
      showSnackBar(context: state.context, message: 'Failed to get pic: $e');
    }
  }

  void uploadMemo() async {
    FormState? currentState = state.formKey.currentState;
    if (currentState == null || !currentState.validate()) {
      return;
    }
    if (state.photo == null) {
      showSnackBar(context: state.context, message: 'Photo not selected');
      return;
    }

    currentState.save();

    startCircularProgress(state.context);

    try {
      Map result = await CloudStorageController.uploadPhotoFile(
        photo: state.photo!,
        uid: state.widget.user.uid,
        listener: (int progress) {
          state.render(() {
            if (progress == 100) {
              progressMessage = null;
            } else {
              progressMessage = 'Uploading: $progress %';
            }
          });
        },
      );
      tempMemo.photoFilename = result[ArgKey.filename];
      tempMemo.photoURL = result[ArgKey.downloadURL];
      tempMemo.imageLabels = currentMLValue=="label"?await GoogleMLController.getImageLabels(photo: state.photo!):await GoogleMLController.fetchTextFromImage(photo: state.photo!);
      tempMemo.createdBy = state.widget.user.email!;
      tempMemo.machineLearningBy = currentMLValue=="label"?"label":"text";

      tempMemo.timestamp = DateTime.now(); // millisec from 1970/1/1

      String docId =
      await FirestoreController.addPhotoMemo(photoMemo: tempMemo);
      tempMemo.docId = docId;

      state.widget.photoMemoList.insert(0, tempMemo);

      state.widget.photoMemoList=await FirestoreController.getPhotoMemoList(email: FirebaseAuth.instance.currentUser!.email!);

      stopCircularProgress(state.context);
      // return to Home
      Navigator.of(state.context).pop();

      print('========= docId: $docId');
    } catch (e) {
      stopCircularProgress(state.context);
      if (Constant.devMode) print('******** uploadFile/Doc error: $e');
      showSnackBar(
          context: state.context,
          seconds: 20,
          message: 'UploadFile/Doc Error: $e');
    }
  }

  void saveTitle(String? value) {
    if (value != null) {
      tempMemo.title = value;
    }
  }
  void saveMemo(String? value) {
    if (value != null) {
      tempMemo.memo = value;
    }
  }
  void saveSharedWith(String? value) {
    if (value != null && value.trim().isNotEmpty) {
      var emailList = value.trim().split(RegExp('(,|;| )+')).map((e) => e.trim()).toList();
      tempMemo.sharedWith = emailList;
    }
  }
}
