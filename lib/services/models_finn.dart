import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SFinn {
  final String id;
  final String uuid;
  final String name;
  final String description;
  final String parent;
  final String project;

  SFinn(this.id, this.uuid, this.name, this.description, this.parent,
      this.project);

  SFinn.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        parent = json['parent'],
        project = json['project'];

  Map<String, String> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'parent': parent,
        'project': project,
      };
}

class FinnContribution {
  final String id;
  final String financier;
  final double amount;
  final String finn;
  final String subject;

  FinnContribution(this.id, this.financier, this.amount, this.finn, this.subject);

  FinnContribution.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        financier = json["financier"],
        amount = json["amout"],
        subject = json["subject"],
        finn = json["finn"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'financer': financier,
        'amount': amount,
        'subject': subject,
        'finn': finn,
      };

  void save()  async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection("s4c_finncontrib");

    if ((this.id == null) || (this.id == ""))
    {

      collection.add({
        "id": Uuid().v4(),
        "financier": this.financier,
        "amount":this.amount,
        "finn":this.finn,
        "subject":this.subject,
      });
    }
    else {
      final query = await collection.where("id", isEqualTo: id).limit(1).get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
      // collection.doc(this.id).set({
      //   "financier": this.financier,
      //   "amount":this.amount,
      //   "finn":this.finn,
      //   "subject":this.subject,
      // });
    }
  }

  static Future<List> getByFinnAndFinancier (finn, financier) async {
    final db = FirebaseFirestore.instance;
    final collection = db.collection("s4c_finncontrib");
    final query = await collection.where("finn", isEqualTo: finn).where('financier', isEqualTo:financier).get();
    List items = [];
    query.docs.forEach((element) { items.add(FinnContribution.fromJson(element.data()));});
    print(items);
    return items;
  }

  

}
