import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;


class SFinn {
  String id;
  String uuid;
  String name;
  String description;
  String parent;
  String project;

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
  
  List<FinnContribution> getContribByFinn()  {
    final List<FinnContribution> items = [];
    final database = db.collection("s4c_finncontrib");
    database.where("finn", isEqualTo: uuid).get().then(
      (querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final Map<String, dynamic> data = doc.data();
          final item = FinnContribution.fromJson(data);
          items.add(item);
        }
      }
    );
    return items;
  }

  void save() {
    final database = db.collection("s4c_finns");
    if (id == "") {
      database.add({
        "id": uuid,
        "uuid": uuid,
        "name": name,
        "description": description,
        "parent": parent,
        "project": project,
      });
    }
    else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }
}

class FinnContribution {
  String id;
  String financier;
  double amount;
  String finn;
  String subject;

  FinnContribution(this.id, this.financier, this.amount, this.finn, this.subject);

  FinnContribution.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        financier = json["financier"],
        amount = json["amount"],
        subject = json["subject"],
        finn = json["finn"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'financier': financier,
        'amount': amount,
        'subject': subject,
        'finn': finn,
      };

  void save()  async {
    final collection = db.collection("s4c_finncontrib");

    if (id == "")
    {

      collection.add({
        "id": const Uuid().v4(),
        "financier": financier,
        "amount":amount,
        "finn":finn,
        "subject":subject,
      });
    }
    else {
      final query = await collection.where("id", isEqualTo: id).limit(1).get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);

    }
  }

  static Future<List> getByFinnAndFinancier (finn, financier) async {
    final collection = db.collection("s4c_finncontrib");
    final query = await collection.where("finn", isEqualTo: finn).where('financier', isEqualTo:financier).get();
    List items = [];
    for (var element in query.docs) { items.add(FinnContribution.fromJson(element.data()));}
    return items;
  }

  

}

class FinnDistribution {
  String id;
  String partner;
  double amount;
  String finn;
  String subject;

  FinnDistribution(this.id, this.partner, this.amount, this.finn, this.subject);

  FinnDistribution.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        partner = json["partner"],
        amount = json["amount"],
        subject = json["subject"],
        finn = json["finn"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'partner': partner,
        'amount': amount,
        'subject': subject,
        'finn': finn,
      };

  void save()  async {
    final collection = db.collection("s4c_finndistrib");

    if (id == "")
    {

      collection.add({
        "id": const Uuid().v4(),
        "partner": partner,
        "amount": amount,
        "finn": finn,
        "subject": subject,
      });
    }
    else {
      final query = await collection.where("id", isEqualTo: id).limit(1).get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  static Future<List> getByFinnAndFinancier (finn, partner) async {
    final collection = db.collection("s4c_finndistrib");
    final query = await collection.where("finn", isEqualTo: finn).where('partner', isEqualTo:partner).get();
    List items = [];
    for (var element in query.docs) { items.add(FinnDistribution.fromJson(element.data()));}
    return items;
  }

  static Future<List> getByFinn (finn) async {
    final collection = db.collection("s4c_finndistrib");
    final query = await collection.where("finn", isEqualTo: finn).get();
    List items = [];
    for (var element in query.docs) { items.add(FinnDistribution.fromJson(element.data()));}
    return items;
  }

  

}
