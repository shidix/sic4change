import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sic4change/pages/models.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/services/firebase_service.dart';

const PAGE_TITLE = "Documentos";

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});
  //final String? currentFolder;
  //const DocumentsPage({Key? key, this.currentFolder}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
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
          ))
        ],
      ),
    );
  }
}

Widget foldersHeader(context, currentFolder) {
  String _title;
  if (currentFolder != null)
    _title = currentFolder.name;
  else
    _title = "/";
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: EdgeInsets.only(left: 40),
      child: Row(children: [
        Text(_title, style: TextStyle(fontSize: 20)),
        if (currentFolder != null)
          IconButton(
            icon: const Icon(Icons.arrow_upward),
            tooltip: 'Up folder',
            onPressed: () {
              getFolderByUuid(currentFolder.parent).then((value) {
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
          folderAddBtn(context),
        ],
      ),
    ),
  ]);
}

Widget folderAddBtn(context) {
  TextEditingController nameController = TextEditingController(text: "");

  return ElevatedButton(
    onPressed: () {
      _folderEditDialog(context, nameController, null);
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
          "Add",
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
                  folderPopUpBtn(context, snapshot.data?[index])
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

Widget folderPopUpBtn(context, _folder) {
  SampleItem? selectedMenu;
  TextEditingController nameController =
      TextEditingController(text: _folder.name);

  return PopupMenuButton<SampleItem>(
    initialValue: selectedMenu,
    // Callback that sets the selected popup menu item.
    onSelected: (SampleItem item) async {
      selectedMenu = item;
      if (selectedMenu == SampleItem.itemOne) {
        _folderEditDialog(context, nameController, _folder);
      }
      if (selectedMenu == SampleItem.itemTwo) {
        _confirmRemoveDialog(context, _folder.id);
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

/*
              Dialogs
*/
Future<void> _folderEditDialog(context, _controller, _folder) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        // <-- SEE HERE
        title: const Text('Cancel booking'),
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
                await updateFolder(
                        _folder.id, _folder.uuid, _controller.text, "")
                    .then((value) {
                  Navigator.popAndPushNamed(context, "/documents");
                });
              } else {
                await addFolder(_controller.text, "").then((value) {
                  Navigator.popAndPushNamed(context, "/documents");
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

Future<void> _confirmRemoveDialog(context, id) async {
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
                Navigator.popAndPushNamed(context, "/documents");
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
