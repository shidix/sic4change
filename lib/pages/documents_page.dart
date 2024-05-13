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
Widget? _mainMenu;

enum SampleItem { itemOne, itemTwo, itemThree }

class DocumentsPage extends StatefulWidget {
  final Folder? currentFolder;
  const DocumentsPage({super.key, this.currentFolder});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  Folder? currentFolder;
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
  initState() {
    super.initState();
    currentFolder = widget.currentFolder;
    _mainMenu = mainMenu(context, "/documents");
  }

  @override
  Widget build(BuildContext context) {
    //final Folder? currentFolder;

    /*if (ModalRoute.of(context)!.settings.arguments != null) {
      HashMap args = ModalRoute.of(context)!.settings.arguments as HashMap;
      currentFolder = args["parent"];
    } else {
      currentFolder = null;
    }*/

    if (currentFolder != null) print(currentFolder!.name);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //mainMenu(context, "/documents"),
          _mainMenu!,
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
              Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                  child: fileAddBtn(context, currentFolder)),
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
      style: btnStyle,
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Archivo",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
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
        await uploadTask;

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
  Widget foldersHeader(context, currentFolder) {
    String title = (currentFolder != null) ? currentFolder.name : "/";

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.only(left: 40),
        child: Row(children: [
          customText(title, 20),
          if (currentFolder != null)
            IconButton(
              icon: const Icon(Icons.arrow_upward),
              tooltip: 'Up folder',
              onPressed: () {
                if (currentFolder.parent != "") {
                  getFolderByUuid(currentFolder.parent).then((value) {
                    Navigator.pushReplacementNamed(context, "/documents",
                        arguments: value);
                  });
                } else {
                  Navigator.pushReplacementNamed(
                    context,
                    "/documents",
                  );
                }
              },
            ),
        ]),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                child: folderAddBtn(context, currentFolder)),
          ],
        ),
      ),
    ]);
  }

  Widget folderAddBtn(context, currentFolder) {
    TextEditingController nameController = TextEditingController(text: "");

    return FilledButton(
      onPressed: () {
        _folderEditDialog(
            context, nameController, Folder("", ""), currentFolder);
      },
      style: btnStyle,
      child: const Column(
        children: [
          Icon(Icons.add, color: Colors.black54),
          SizedBox(height: 5),
          Text(
            "Carpeta",
            style: TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget folderList(context, currentFolder) {
    String parentUuid = "";
    if (currentFolder != null) parentUuid = currentFolder.uuid;

    return FutureBuilder(
        future: getFolders(parentUuid!),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            folders = snapshot.data!;

            /*return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 5,
                ),
                itemCount: folders.length,
                itemBuilder: (_, index) {
                  Folder? cFolder = folders[index];
                  return Row(children: [
                    goPage(context, folders[index].name,
                        DocumentsPage(currentFolder: cFolder), Icons.folder,
                        extraction: () {}),
                    /*customRowBtn(context, folders[index].name, Icons.folder,
                        "/documents", {"parent": cFolder}),*/
                    folderPopUpBtn(context, folders[index], currentFolder)
                  ]);
                });*/
            return ListView.builder(
                //padding: const EdgeInsets.all(8),
                itemCount: folders.length,
                scrollDirection: Axis.horizontal,
                //shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  Folder? cFolder = folders[index];
                  return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 60,
                          child: goPage(
                              context,
                              folders[index].name,
                              DocumentsPage(currentFolder: cFolder),
                              Icons.folder,
                              extraction: () {}),
                        ),
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
  void saveFolder(List args) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder!.uuid;
    Folder folder = args[0];
    folder.parent = folderUuid;
    folder.save();
    loadFolders(folderUuid);
    Navigator.pop(context);
  }

  Future<void> _folderEditDialog(
      context, controller, folder, currentFolder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar(
              (currentFolder != null) ? 'Editar carpeta' : 'Nueva carpeta'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 250,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      labelText: "Nombre",
                      initial: folder.name,
                      size: 250,
                      fieldValue: (String val) {
                        setState(() => folder.name = val);
                      },
                    )
                  ]),
            ),
          ),
          actions: <Widget>[
            dialogsBtns(context, saveFolder, folder),
          ],
        );
      },
    );
  }

  void deleteFolder(List args) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder!.uuid;
    Folder folder = args[0];
    folder.delete();
    loadFolders(folderUuid);
    Navigator.pop(context);
  }

  Future<void> _confirmRemoveDialog(context, folder, currentFolder) async {
    //String folderUuid = (currentFolder != null) ? currentFolder.uuid : "";

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Borrar carpeta"),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            dialogsBtns(context, deleteFolder, folder),
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
          _linkDialog(context, file);
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
  Future<void> _linkDialog(context, file) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enlace del fichero'),
          content: SingleChildScrollView(
              child: Row(children: [SelectableText(file.link)])),
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

  void saveFile(List args) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder!.uuid;
    SFile file = args[0];
    file.save();
    loadFiles(folderUuid);
    Navigator.pop(context);
  }

  Future<void> _fileEditDialog(context, controller, file, currentFolder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Cambiar nombre del fichero"),
          content: SingleChildScrollView(
              child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: file.name,
                size: 250,
                fieldValue: (String val) {
                  setState(() => file.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveFile, file),
          ],
        );
      },
    );
  }

  void deleteFile(List args) async {
    String folderUuid = "";
    if (currentFolder != null) folderUuid = currentFolder!.uuid;
    SFile file = args[0];
    FirebaseStorage.instance.refFromURL(file.link).delete();
    file.delete();
    loadFiles(folderUuid);
    Navigator.pop(context);
  }

  Future<void> _confirmFileRemoveDialog(context, file, currentFolder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Borrar fichero"),
          content: const SingleChildScrollView(
            child: Text("Esta seguro/a de que desea borrar este elemento?"),
          ),
          actions: <Widget>[
            dialogsBtns(context, deleteFile, file),
          ],
        );
      },
    );
  }
}
