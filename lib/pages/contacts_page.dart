import 'package:flutter/material.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

final List<Map> contacts =
    List.generate(100, (index) => {"id": index, "name": "Contact $index"});

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Other Page'),
      ),*/
      body: Column(children: [
        mainMenu(context),
        Expanded(
          child: contactList(),
        )
      ]),
    );
  }
}

Widget contactList() {
  return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: contacts.length,
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          color: Colors.teal[100],
          child: Text(contacts[index]["name"]),
        );
      });
}
