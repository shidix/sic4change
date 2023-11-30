import 'dart:collection';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/models_drive.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:file_picker/file_picker.dart';

const pageTitle = "Documentos";
List files = [];
List folders = [];

enum SampleItem { itemOne, itemTwo, itemThree }

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  PlatformFile? pickedFile;
  Uint8List? pickedFileBytes;
  UploadTask? uploadTask;

  void loadFolders(value) async {
    await getFolders(value).then((val) {
      folders = val;
    });
    setState(() {});
  }

  void loadFiles(value) async {
    await getFiles(value).then((val) {
      files = val;
    });
    setState(() {});
  }

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
          foldersHeader(context, currentFolder),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: folderList(context, currentFolder),
          )),
          const Divider(
            color: Colors.grey,
            indent: 30,
            endIndent: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              fileAddBtn(context, currentFolder),
            ],
          ),
          buildProgress(),
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: fileList(context, currentFolder),
          )),
        ],
      ),
    );
  }

/*-------------------------------------------------------------
                     UPLOAD FILES
-------------------------------------------------------------*/
  Widget fileAddBtn(context, currentFolder) {
    return FilledButton(
      onPressed: () {
        selectFile(currentFolder);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: const Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
    /*return ElevatedButton(
      onPressed: () {
        selectFile(currentFolder);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          customText(
            "Add File",
            14,
            textColor: Colors.black,
          ),
        ],
      ),
    );*/
  }

  Future selectFile(currentFolder) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder.uuid;

    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);

    if (result == null) {
      return null;
    } else {
      pickedFile = result.files.first;
      pickedFileBytes = result.files.first.bytes;

      String uniqueFileName =
          "${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}";
      final path = 'files/$uniqueFileName';
      final ref = FirebaseStorage.instance.ref().child(path);

      try {
        setState(() {
          uploadTask = ref.putData(pickedFileBytes!);
        });

        String fileUrl = await ref.getDownloadURL();

        SFile file = SFile(pickedFile!.name, folderUuid, fileUrl);
        file.save();
        loadFiles(folderUuid);

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
        if ((snapshot.hasData) && (uploadTask != null)) {
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

/*-------------------------------------------------------------
                            FOLDERS
-------------------------------------------------------------*/
  Widget foldersHeader(context, _currentFolder) {
    String title;
    if (_currentFolder != null) {
      title = _currentFolder.name;
    } else {
      title = "/";
    }
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Row(children: [
          customText(title, 20),
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
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            folderAddBtn(context, _currentFolder),
          ],
        ),
      ),
    ]);
  }

  Widget folderAddBtn(context, currentFolder) {
    TextEditingController nameController = TextEditingController(text: "");

    return FilledButton(
      onPressed: () {
        _folderEditDialog(context, nameController, null, currentFolder);
      },
      style: FilledButton.styleFrom(
        side: const BorderSide(width: 0, color: Color(0xffffffff)),
        backgroundColor: const Color(0xffffffff),
      ),
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Añadir",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
    /*return ElevatedButton(
      onPressed: () {
        _folderEditDialog(context, nameController, null, currentFolder);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.black54,
            size: 30,
          ),
          space(height: 10),
          customText(
            "Add Folder",
            14,
            textColor: Colors.black,
          ),
        ],
      ),
    );*/
  }

  Widget folderList(context, currentFolder) {
    String? parentUuid;
    if (currentFolder == null) {
      parentUuid = "";
    } else {
      parentUuid = currentFolder.uuid;
    }
    return FutureBuilder(
        future: getFolders(parentUuid!),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            folders = snapshot.data!;

            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 3,
                ),
                itemCount: folders.length,
                itemBuilder: (_, index) {
                  Folder? cFolder = folders[index];
                  return Row(children: [
                    customRowBtn(context, folders[index].name, Icons.folder,
                        "/documents", {"parent": cFolder}),
                    folderPopUpBtn(context, folders[index], currentFolder)
                  ]);
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

//enum SampleItem { itemOne, itemTwo }

  Future<bool> folderHaveChildren(folder) async {
    folders = await getFolders(folder);
    files = await getFiles(folder);
    if ((folders.isNotEmpty) || (files.isNotEmpty)) {
      return true;
    } else {
      return false;
    }
  }

  Widget folderPopUpBtn(context, folder, currentFolder) {
    SampleItem? selectedMenu;
    TextEditingController nameController =
        TextEditingController(text: folder.name);

    return PopupMenuButton<SampleItem>(
      initialValue: selectedMenu,
      // Callback that sets the selected popup menu item.
      onSelected: (SampleItem item) async {
        selectedMenu = item;
        if (selectedMenu == SampleItem.itemOne) {
          _folderEditDialog(context, nameController, folder, currentFolder);
        }
        if (selectedMenu == SampleItem.itemTwo) {
          bool haveChildren = await folderHaveChildren(folder.uuid);
          if (!haveChildren) {
            _confirmRemoveDialog(context, folder, currentFolder);
          } else {
            _errorRemoveDialog(context);
          }
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        const PopupMenuItem<SampleItem>(
            value: SampleItem.itemOne,
            child: Row(children: [
              Icon(Icons.edit),
              Text('Editar'),
            ])),
        const PopupMenuItem<SampleItem>(
          value: SampleItem.itemTwo,
          child: Row(
            children: [
              Icon(Icons.remove_circle),
              Text('Borrar'),
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
      context, controller, folder, currentFolder) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder.uuid;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar carpeta'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 250,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Nombre",
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (folder != null) {
                  folder.name = controller.text;
                  folder.save();
                } else {
                  String parent =
                      (currentFolder != null) ? currentFolder.uuid : "";
                  Folder _folder = Folder(controller.text, parent);
                  _folder.save();
                }
                loadFolders(folderUuid);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmRemoveDialog(context, _folder, _currentFolder) async {
    String _folderUuid = (_currentFolder != null) ? _currentFolder.uuid : "";

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Borrar carpeta'),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Borrar'),
              onPressed: () async {
                _folder.delete();
                loadFolders(_folderUuid);
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _errorRemoveDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          // <-- SEE HERE
          title: const Text('Borrar carpeta'),
          content: const SingleChildScrollView(
            child:
                Text("No se puede borrar esta carpeta porque tiene contenido."),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
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
  Widget fileList(context, currentFolder) {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder.uuid;

    return FutureBuilder(
        future: getFiles(folderUuid),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            files = snapshot.data!;
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 3,
                ),
                itemCount: files.length,
                itemBuilder: (_, index) {
                  SFile? file = files[index];
                  String? name = file?.name;
                  String? loc = "(${file?.loc})";

                  print(file?.link);
                  if (name != null && name.length > 6) {
                    name = '${name.substring(0, 6)}...';
                  }
                  return Row(children: [
                    customRowFileBtn(
                        context, name, loc, Icons.picture_as_pdf, file?.link),
                    filePopUpBtn(context, file, currentFolder)
                  ]);
                });
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }));
  }

  Widget filePopUpBtn(context, file, currentFolder) {
    SampleItem? selectedMenu;
    TextEditingController nameController =
        TextEditingController(text: file.name);

    return PopupMenuButton<SampleItem>(
      initialValue: selectedMenu,
      // Callback that sets the selected popup menu item.
      onSelected: (SampleItem item) async {
        selectedMenu = item;
        if (selectedMenu == SampleItem.itemOne) {
          _fileEditDialog(context, nameController, file, currentFolder);
        }
        if (selectedMenu == SampleItem.itemTwo) {
          _fileEditDialog(context, nameController, file, currentFolder);
        }
        if (selectedMenu == SampleItem.itemThree) {
          _confirmFileRemoveDialog(context, file, currentFolder);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<SampleItem>>[
        const PopupMenuItem<SampleItem>(
            value: SampleItem.itemOne,
            child: Row(children: [
              Icon(Icons.link),
              Text('Ver enlace'),
            ])),
        const PopupMenuItem<SampleItem>(
            value: SampleItem.itemTwo,
            child: Row(children: [
              Icon(Icons.edit),
              Text('Cambiar nombre'),
            ])),
        const PopupMenuItem<SampleItem>(
          value: SampleItem.itemThree,
          child: Row(
            children: [
              Icon(Icons.remove_circle),
              Text('Borrar'),
            ],
          ),
        ),
      ],
    );
  }

/*-------------------------------------------------------------
                        FILES Dialogs
---------------------------------------------------------------*/

  Future<void> _fileEditDialog(context, controller, file, currentFolder) async {
    String _folderUuid = "";
    if (currentFolder != null) _folderUuid = currentFolder.uuid;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cambiar nombre del fichero'),
          content: SingleChildScrollView(
              child: Row(children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Nombre",
                ),
              ),
            ),
            //Text(_fileName),
          ])),
          actions: <Widget>[
            TextButton(
              child: const Text('Guardar'),
              onPressed: () async {
                if (file != null) {
                  file.name = controller.text;
                  file.save();
                  loadFiles(_folderUuid);
                  Navigator.pop(context);
                }
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmFileRemoveDialog(context, file, currentFolder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove File'),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Remove'),
              onPressed: () async {
                file.delete();
                String folderUuid =
                    (currentFolder != null) ? currentFolder.uuid : "";
                loadFiles(folderUuid);
                Navigator.of(context).pop();
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
}
