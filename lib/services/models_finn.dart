// import 'dart:collection';
import 'dart:convert';

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

  Future<List> getContrib() async {
    final List<FinnContribution> items = [];
    final database = db.collection("s4c_finncontrib");
    await database.where("finn", isEqualTo: uuid).get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final item = FinnContribution.fromJson(data);
        items.add(item);
      }
    });
    return items;
  }

  static Future<List> byProject(String uuidProject) async {
    final List<SFinn> items = [];
    final database = db.collection("s4c_finns");
    await database
        .where("project", isEqualTo: uuidProject)
        .orderBy('name')
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final item = SFinn.fromJson(data);
        item.id = doc.id;

        items.add(item);
      }
    });
    return items;
  }

  static SFinn byUuid(String uuid) {
    final database = db.collection("s4c_finns");
    SFinn item = SFinn('', uuid, '', '', '', '');
    database.where("uuid", isEqualTo: uuid).get().then((querySnapshot) {
      var first = querySnapshot.docs.first;
      item.id = first.id;
      item = SFinn.fromJson(first.data());
    });
    return item;
  }

  void save() {
    final database = db.collection("s4c_finns");
    if (id == "") {
      id = uuid;
      Map<String, dynamic> data = toJson();
      database.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    final database = db.collection("s4c_finns");
    if (id != "") {
      database.doc(id).delete();
    }
  }

  String toString() {
    return jsonEncode(toJson());
  }
}

/////////////////////

class FinnContribution {
  String id;
  String financier;
  double amount;
  String finn;
  String subject;

  FinnContribution(
      this.id, this.financier, this.amount, this.finn, this.subject);

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

  void save() async {
    final collection = db.collection("s4c_finncontrib");

    if (id == "") {
      collection.add({
        "id": const Uuid().v4(),
        "financier": financier,
        "amount": amount,
        "finn": finn,
        "subject": subject,
      });
    } else {
      final query = await collection.where("id", isEqualTo: id).limit(1).get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  static Future<List> getByFinnAndFinancier(finn, financier) async {
    final collection = db.collection("s4c_finncontrib");
    final query = await collection
        .where("finn", isEqualTo: finn)
        .where('financier', isEqualTo: financier)
        .get();
    List items = [];
    for (var element in query.docs) {
      items.add(FinnContribution.fromJson(element.data()));
    }
    return items;
  }

  String toString() {
    return jsonEncode(toJson());
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

  void save() async {
    final collection = db.collection("s4c_finndistrib");

    if (id == "") {
      id = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      collection.add(data);
    } else {
      final query = await collection.where("id", isEqualTo: id).limit(1).get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  static Future<List> getByFinnAndFinancier(finn, partner) async {
    final collection = db.collection("s4c_finndistrib");
    final query = await collection
        .where("finn", isEqualTo: finn)
        .where('partner', isEqualTo: partner)
        .get();
    List items = [];
    for (var element in query.docs) {
      items.add(FinnDistribution.fromJson(element.data()));
    }
    return items;
  }

  static Future<List> getByFinn(finn) async {
    final collection = db.collection("s4c_finndistrib");
    final query = await collection.where("finn", isEqualTo: finn).get();
    List items = [];
    for (var element in query.docs) {
      items.add(FinnDistribution.fromJson(element.data()));
    }
    return items;
  }
}

class Invoice {
  String id;
  String uuid;
  String number;
  String code;
  String finn;
  String concept;
  String date;
  double base;
  double taxes;
  double total;
  String desglose;
  String provider;
  String document;

  Invoice(
      this.id,
      this.uuid,
      this.number,
      this.code,
      this.finn,
      this.concept,
      this.date,
      this.base,
      this.taxes,
      this.total,
      this.desglose,
      this.provider,
      this.document);

  Invoice.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        number = json["number"],
        code = json["code"],
        finn = json["finn"],
        concept = json["concept"],
        date = json["date"],
        base = json["base"],
        taxes = json["taxes"],
        total = json["total"],
        desglose = json["desglose"],
        provider = json["provider"],
        document = json["document"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'number': number,
        'code': code,
        'finn': finn,
        'concept': concept,
        'date': date,
        'base': base,
        'taxes': taxes,
        'total': total,
        'desglose': desglose,
        'provider': provider,
        'document': document,
      };

  void save() async {
    final collection = db.collection("s4c_invoices");
    if (id == "") {
      id = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      collection.add(data);
    } else {
      final item = await collection.doc(id).get();
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  static Future<List> getByFinn(finn) async {
    final collection = db.collection("s4c_invoices");
    final query =
        await collection.where("finn", isEqualTo: finn).orderBy('date').get();
    List items = [];
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<Invoice> getByUuid(uuid) async {
    final collection = db.collection("s4c_invoices");
    final query = await collection.where("uuid", isEqualTo: uuid).get();
    Invoice item = Invoice.fromJson(query.docs.first.data());
    item.id = query.docs.first.id;
    return item;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  void delete() {
    final collection = db.collection("s4c_invoices");
    if (id != "") {
      collection.doc(id).delete();
    }
  }
}

class BankTransfer {
  String id;
  String uuid;
  String number;
  String code;
  String project;
  String concept;
  String date;
  String emissor;
  String receiver;
  double amountSource;
  double exchangeSource;
  double commissionSource;
  double amountIntermediary;
  double exchangeIntermediary;
  double commissionIntermediary;
  double amountDestination;
  double commissionDestination;
  String currencySource;
  String currencyIntermediary;
  String currencyDestination;
  String document;

  BankTransfer(
      this.id,
      this.uuid,
      this.number,
      this.code,
      this.project,
      this.concept,
      this.date,
      this.emissor,
      this.receiver,
      this.amountSource,
      this.exchangeSource,
      this.commissionSource,
      this.amountIntermediary,
      this.exchangeIntermediary,
      this.commissionIntermediary,
      this.amountDestination,
      this.commissionDestination,
      this.currencySource,
      this.currencyIntermediary,
      this.currencyDestination,
      this.document);

  BankTransfer.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        number = json["number"],
        code = json["code"],
        project = json["project"],
        concept = json["concept"],
        date = json["date"],
        emissor = json["emissor"],
        receiver = json["receiver"],
        amountSource = json["amountSource"],
        exchangeSource = json["exchangeSource"],
        commissionSource = json["commissionSource"],
        amountIntermediary = json["amountIntermediary"],
        exchangeIntermediary = json["exchangeIntermediary"],
        commissionIntermediary = json["commissionIntermediary"],
        amountDestination = json["amountDestination"],
        commissionDestination = json["commissionDestination"],
        currencySource = json["currencySource"],
        currencyIntermediary = json["currencyIntermediary"],
        currencyDestination = json["currencyDestination"],
        document = json["document"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'number': number,
        'code': code,
        'project': project,
        'concept': concept,
        'date': date,
        'emissor': emissor,
        'receiver': receiver,
        'amountSource': amountSource,
        'exchangeSource': exchangeSource,
        'commissionSource': commissionSource,
        'amountIntermediary': amountIntermediary,
        'exchangeIntermediary': exchangeIntermediary,
        'commissionIntermediary': commissionIntermediary,
        'amountDestination': amountDestination,
        'commissionDestination': commissionDestination,
        'currencySource': currencySource,
        'currencyIntermediary': currencyIntermediary,
        'currencyDestination': currencyDestination,
        'document': document,
      };

  void save() async {
    final collection = db.collection("s4c_banktransfers");
    if (id == "") {
      id = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      collection.add(data);
    } else {
      final item = await collection.doc(id).get();
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  static Future<List<BankTransfer>> getByProject(project) async {
    final collection = db.collection("s4c_banktransfers");
    final query = await collection
        .where("project", isEqualTo: project)
        .orderBy('date')
        .get();
    List<BankTransfer> items = [];
    for (var element in query.docs) {
      BankTransfer item = BankTransfer.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<BankTransfer> getByUuid(uuid) async {
    final collection = db.collection("s4c_banktransfers");
    final query = await collection.where("uuid", isEqualTo: uuid).get();
    BankTransfer item = BankTransfer.fromJson(query.docs.first.data());
    item.id = query.docs.first.id;
    return item;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  void delete() {
    final collection = db.collection("s4c_banktransfers");
    if (id != "") {
      collection.doc(id).delete();
    }
  }
}
