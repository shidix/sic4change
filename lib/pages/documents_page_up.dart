import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/pages/contacts_page.dart';
import 'dart:io';
//import 'package:sic4change/custom_widgets/custom_appbar.dart';

class DocumentsUpPage extends StatefulWidget {
  const DocumentsUpPage({super.key});

  @override
  State<DocumentsUpPage> createState() => _DocumentsUpPageState();
}

class _DocumentsUpPageState extends State<DocumentsUpPage> {
  PlatformFile? pickedFile;
  Uint8List? pickedFileBytes;
  UploadTask? uploadTask;
  String fileUrl = '';

  Future selectFile() async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result == null) return null;
    /*if (result == null)
      return;
    else
      //pickedFile = File(result.files.single.path);
      pickedFileBytes = result.files.first.bytes;
*/
    //setState(() {});
    setState(() {
      pickedFile = result.files.first;
      pickedFileBytes = result.files.first.bytes;
    });
  }

  Future uploadFile() async {
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

      fileUrl = await ref.getDownloadURL();
      print(fileUrl);

      setState(() {
        uploadTask = null;
      });
    } catch (err) {
      print(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      body: Column(
        children: [
          mainMenu(context),
          if (pickedFile != null)
            Container(
              child: Image.memory(pickedFileBytes!),
            ),
          Text(fileUrl),
          space(height: 30),
          ElevatedButton(
            child: const Text('Select file'),
            onPressed: selectFile,
          ),
          space(height: 30),
          ElevatedButton(
            child: const Text('Upload file'),
            onPressed: uploadFile,
          ),
          buildProgress(),
        ],
      ),
    );
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
