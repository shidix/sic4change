import 'dart:collection';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service_drive.dart';
import 'package:file_picker/file_picker.dart';

const PAGE_TITLE = "Documentos";

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  //final String? currentFolder;
  //const DocumentsPage({Key? key, this.currentFolder}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  PlatformFile? pickedFile;
  Uint8List? pickedFileBytes;
  UploadTask? uploadTask;
  //String fileUrl = '';

  @override
  Widget build(BuildContext context) {
    final Folder? currentFolder;

    if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      currentFolder = args["parent"];
    } else {
      currentFolder = null;
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          mainMenu(context),
          //Text(widget.currentFolder!),
          foldersHeader(context, currentFolder),
          Expanded(
              child: Container(
            child: folderList(context, currentFolder),
            padding: EdgeInsets.all(10),
          )),
          Divider(
            color: Colors.grey,
            indent: 30,
            endIndent: 30,
          ),
          //filesHeader(context, currentFolder),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              fileAddBtn(context, currentFolder),
            ],
          ),
          buildProgress(),
          Expanded(
              child: Container(
            child: fileList(context, currentFolder),
            padding: EdgeInsets.all(10),
          )),
        ],
      ),
    );
  }

/*-------------------------------------------------------------
                     UPLOAD FILES
-------------------------------------------------------------*/
  Widget fileAddBtn(context, _currentFolder) {
    return ElevatedButton(
      onPressed: () {
        selectFile(_currentFolder);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          Text(
            "Add File",
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future selectFile(_currentFolder) async {
    String _folderUuid = "";
    if (_currentFolder != null) _folderUuid = _currentFolder.uuid;

    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);

    if (result == null)
      return null;
    else {
      pickedFile = result.files.first;
      pickedFileBytes = result.files.first.bytes;

      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString() +
          "_" +
          pickedFile!.name;
      final path = 'files/${uniqueFileName}';
      final ref = FirebaseStorage.instance.ref().child(path);

      try {
        setState(() {
          uploadTask = ref.putData(pickedFileBytes!);
        });

        final snapshot = await uploadTask!.whenComplete(() => {});

        String fileUrl = await ref.getDownloadURL();

        await addFile(pickedFile!.name, _folderUuid, fileUrl).then((value) {
          Navigator.popAndPushNamed(context, "/documents",
              arguments: {"parent": _currentFolder});
        });

        setState(() {
          uploadTask = null;
        });
      } catch (err) {
        print(err);
      }
    }
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(100 * progress).roundToDouble()}%',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox(
            height: 50,
          );
        }
      });
}

/*-------------------------------------------------------------
                            FOLDERS
-------------------------------------------------------------*/
Widget foldersHeader(context, _currentFolder) {
  String _title;
  if (_currentFolder != null)
    _title = _currentFolder.name;
  else
    _title = "/";
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: EdgeInsets.only(left: 40),
      child: Row(children: [
        Text(_title, style: TextStyle(fontSize: 20)),
        if (_currentFolder != null)
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            tooltip: 'Up folder',
            onPressed: () {
              getFolderByUuid(_currentFolder.parent).then((value) {
                Navigator.pushReplacementNamed(context, "/documents",
                    arguments: value);
              });
            },
          ),
      ]),
      /*customRowBtn(context, "", Icons.arrow_upward, "/documents",
          {"parent": currentFolder}),*/
    ),
    Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          folderAddBtn(context, _currentFolder),
        ],
      ),
    ),
  ]);
}

Widget folderAddBtn(context, _currentFolder) {
  TextEditingController nameController = TextEditingController(text: "");

  return ElevatedButton(
    onPressed: () {
      _folderEditDialog(context, nameController, null, _currentFolder);
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Row(
      children: [
        Icon(
          Icons.add,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          "Add Folder",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget folderList(context, _currentFolder) {
  String? parentUuid;
  if (_currentFolder == null)
    parentUuid = "";
  else
    parentUuid = _currentFolder.uuid;
  return FutureBuilder(
      future: getFolders(parentUuid!),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 3,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (_, index) {
                Folder? cFolder = snapshot.data?[index];
                return Row(children: [
                  customRowBtn(context, snapshot.data?[index].name,
                      Icons.folder, "/documents", {"parent": cFolder}),
                  folderPopUpBtn(context, snapshot.data?[index], _currentFolder)
                ]);
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }));
}

enum SampleItem { itemOne, itemTwo }

Widget folderPopUpBtn(context, _folder, _currentFolder) {
  SampleItem? selectedMenu;
  TextEditingController nameController =
      TextEditingController(text: _folder.name);

  return PopupMenuButton<SampleItem>(
    initialValue: selectedMenu,
    // Callback that sets the selected popup menu item.
    onSelected: (SampleItem item) async {
      selectedMenu = item;
      if (selectedMenu == SampleItem.itemOne) {
        _folderEditDialog(context, nameController, _folder, _currentFolder);
      }
      if (selectedMenu == SampleItem.itemTwo) {
        _confirmRemoveDialog(context, _folder.id, _currentFolder);
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
      const PopupMenuItem<SampleItem>(
          value: SampleItem.itemOne,
          child: Row(children: [
            Icon(Icons.edit),
            Text('Edit'),
          ])),
      const PopupMenuItem<SampleItem>(
        value: SampleItem.itemTwo,
        child: Row(
          children: [
            Icon(Icons.remove_circle),
            Text('Remove'),
          ],
        ),
      ),
    ],
  );
}

/*-------------------------------------------------------------
                        FOLDERS Dialogs
---------------------------------------------------------------*/
Future<void> _folderEditDialog(
    context, _controller, _folder, _currentFolder) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Folder edit'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 250,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Enter name",
              ),
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_folder != null) {
                await updateFolder(_folder.id, _folder.uuid, _controller.text,
                        _folder.parent)
                    .then((value) {
                  Navigator.popAndPushNamed(context, "/documents",
                      arguments: {"parent": _currentFolder});
                });
              } else {
                String parent;
                if (_currentFolder != null)
                  parent = _currentFolder.uuid;
                else
                  parent = "";
                await addFolder(_controller.text, parent).then((value) {
                  Navigator.popAndPushNamed(context, "/documents",
                      arguments: {"parent": _currentFolder});
                });
              }
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _confirmRemoveDialog(context, id, _currentFolder) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Remove Folder'),
        content: SingleChildScrollView(
          child: Text("Are you sure to remove this element?"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Remove'),
            onPressed: () async {
              await deleteFolder(id).then((value) {
                Navigator.popAndPushNamed(context, "/documents",
                    arguments: {"parent": _currentFolder});
              });
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

/*-------------------------------------------------------------
                            FILES
-------------------------------------------------------------*/
Widget fileList(context, _currentFolder) {
  String _folderUuid = "";
  if (_currentFolder != null) _folderUuid = _currentFolder.uuid;

  return FutureBuilder(
      future: getFiles(_folderUuid),
      builder: ((context, snapshot) {
        if (snapshot.hasData) {
          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 3,
              ),
              itemCount: snapshot.data?.length,
              itemBuilder: (_, index) {
                SFile? _file = snapshot.data?[index];
                String? _name = _file?.name;

                print(_file?.link);
                if (_name != null && _name.length > 6)
                  _name = '${_name.substring(0, 6)}...';
                return Row(children: [
                  customRowExternalBtn(
                      context, _name, Icons.picture_as_pdf, _file?.link),
                  filePopUpBtn(context, _file, _currentFolder)
                ]);
              });
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      }));
}

Widget filePopUpBtn(context, _file, _currentFolder) {
  SampleItem? selectedMenu;
  TextEditingController nameController =
      TextEditingController(text: _file.name);

  return PopupMenuButton<SampleItem>(
    initialValue: selectedMenu,
    // Callback that sets the selected popup menu item.
    onSelected: (SampleItem item) async {
      selectedMenu = item;
      if (selectedMenu == SampleItem.itemOne) {
        _fileEditDialog(context, nameController, _file, _currentFolder);
      }
      if (selectedMenu == SampleItem.itemTwo) {
        _confirmFileRemoveDialog(context, _file, _currentFolder);
      }
    },
    itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
      const PopupMenuItem<SampleItem>(
          value: SampleItem.itemOne,
          child: Row(children: [
            Icon(Icons.edit),
            Text('Change name'),
          ])),
      const PopupMenuItem<SampleItem>(
        value: SampleItem.itemTwo,
        child: Row(
          children: [
            Icon(Icons.remove_circle),
            Text('Remove'),
          ],
        ),
      ),
    ],
  );
}

/*-------------------------------------------------------------
                        FILES Dialogs
---------------------------------------------------------------*/

Future<void> _fileEditDialog(
    context, _controller, _file, _currentFolder) async {
  String _folderUuid = "";
  if (_currentFolder != null) _folderUuid = _currentFolder.uuid;

  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Change name file'),
        content: SingleChildScrollView(
            child: Row(children: [
          SizedBox(
            width: 250,
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: "Enter name",
              ),
            ),
          ),
          //Text(_fileName),
        ])),
        actions: <Widget>[
          TextButton(
            child: const Text('Save'),
            onPressed: () async {
              if (_file != null) {
                await updateFile(_file.id, _file.uuid, _controller.text,
                        _file.folder, _file.link)
                    .then((value) {
                  Navigator.popAndPushNamed(context, "/documents",
                      arguments: {"parent": _currentFolder});
                });
              } /*else {
                await addFile(_controller.text, _folderUuid, "").then((value) {
                  Navigator.popAndPushNamed(context, "/documents",
                      arguments: {"parent": _currentFolder});
                });
              }*/
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

Future<void> _confirmFileRemoveDialog(context, _file, _currentFolder) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Remove File'),
        content: SingleChildScrollView(
          child: Text("Are you sure to remove this element?"),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Remove'),
            onPressed: () async {
              final ref =
                  FirebaseStorage.instance.ref().child(_file.link).delete();
              await deleteFile(_file.id).then((value) {
                Navigator.popAndPushNamed(context, "/documents",
                    arguments: {"parent": _currentFolder});
              });
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
