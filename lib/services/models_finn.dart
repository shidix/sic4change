import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:sic4change/services/models.dart';
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

  Future<Map<String, double>> getTotalContrib() async {
    final List<SFinn> childrens = await getChildrens();
    if (childrens.isEmpty) {
      final Map<String, double> items = {};
      items["total"] = 0;
      final database = db.collection("s4c_finncontrib");
      await database.where("finn", isEqualTo: uuid).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final Map<String, dynamic> data = doc.data();
          final item = FinnContribution.fromJson(data);
          if (items.containsKey(item.financier)) {
            items[item.financier] = items[item.financier]! + item.amount;
          } else {
            items[item.financier] = item.amount;
          }
          items["total"] = items["total"]! + item.amount;
        }
      });
      return items;
    } else {
      final database = db.collection("s4c_finncontrib");
      database.where("finn", isEqualTo: uuid).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          database.doc(doc.id).delete();
        }
      });
      final Map<String, double> items = {};
      items["total"] = 0;
      for (var child in childrens) {
        final Map<String, double> childItems = await child.getTotalContrib();
        for (var key in childItems.keys) {
          if (items.containsKey(key)) {
            items[key] = items[key]! + childItems[key]!;
          } else {
            items[key] = childItems[key]!;
          }
        }
      }
      return items;
    }
  }

  String parentCode() {
    RegExp punto = RegExp("\\.");
    List<Match> separators = punto.allMatches(name).toList();
    if (separators.isEmpty) {
      return "";
    } else {
      return name.substring(0, name.lastIndexOf("."));
    }
  }

  static Future<List> byProject(String uuidProject) async {
    final List<SFinn> items = [];
    final database = db.collection("s4c_finns");
    await database
        .where("project", isEqualTo: uuidProject)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        try {
          final Map<String, dynamic> data = doc.data();
          final item = SFinn.fromJson(data);
          item.id = doc.id;

          items.add(item);
        } catch (e) {
          print(e);
        }
      }
    });
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  static Future<List> byProjectAndMain(String uuidProject) async {
    final List<SFinn> items = [];
    final database = db.collection("s4c_finns");
    await database
        .where("project", isEqualTo: uuidProject)
        .where("parent", isEqualTo: "")
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        try {
          final Map<String, dynamic> data = doc.data();
          final item = SFinn.fromJson(data);
          item.id = doc.id;

          items.add(item);
        } catch (e) {
          print(e);
        }
      }
    });
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  int getLevel() {
    RegExp punto = RegExp("\\.");

    // Obtener una lista de todos los resultados de la coincidencia
    List<Match> separators = punto.allMatches(name).toList();

    // Contar el número de coincidencias
    return separators.length;
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

  Future<List<SFinn>> getChildrens() async {
    final List<SFinn> items = [];
    final database = db.collection("s4c_finns");
    await database.where("parent", isEqualTo: uuid).get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final Map<String, dynamic> data = doc.data();
        final item = SFinn.fromJson(data);
        item.id = doc.id;
        items.add(item);
      }
    });
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  void recalculate() async {
    getChildrens().then((childrens) {
      if (childrens.isEmpty) {
        FinnContribution.totalsByFinancier(project: project).then((value) {
          print("DBG value: $value");
        });
      }
      ;
      List<String> childrensUuid = childrens.map((e) => e.uuid).toList();
      print("DBG childres.length: ${childrensUuid.length}");

      // FinnContribution.getSummaryByProject project)
    });
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

  void recalculate() async {
    final collection = db.collection("s4c_finncontrib");
    SFinn finn = SFinn.byUuid(this.finn);
    List<SFinn> childrens = await finn.getChildrens();
    if (childrens.isEmpty) {
      return;
    }
    List<String> childrensUuid = childrens.map((e) => e.uuid).toList();
    final query = await collection
        .where("finn", whereIn: childrensUuid)
        .where("financier", isEqualTo: financier)
        .get();
    double total = 0;
    for (var element in query.docs) {
      FinnContribution item = FinnContribution.fromJson(element.data());
      print("item.amount: ${item.amount}");
      total += item.amount;
    }
    amount = total;
    save();
  }

  static Future<Map<String, double>> getSummaryByFinancier(financier) async {
    final collection = db.collection("s4c_finncontrib");
    final query =
        await collection.where("financier", isEqualTo: financier).get();
    double total = 0;
    for (var element in query.docs) {
      FinnContribution item = FinnContribution.fromJson(element.data());
      total += item.amount;
    }
    return {
      "total": total,
    };
  }

  static Future<Map<String, double>> getSummaryByFinancierAndProject(
      finnancier, project) async {
    List? finnList;
    await SFinn.byProjectAndMain(project).then((value) {
      finnList = value.map((e) => e.uuid).toList();
    });

    final collection = db.collection("s4c_finncontrib");
    final query = await collection
        .where("financier", isEqualTo: finnancier)
        .where("finn", whereIn: finnList)
        .get();
    double total = 0;
    for (var element in query.docs) {
      FinnContribution item = FinnContribution.fromJson(element.data());
      total += item.amount;
    }
    return {
      "total": total,
    };
  }

  static Future<Map<String, double>> totalsByFinancier({project}) async {
    List? finnList;
    if (project != null) {
      await SFinn.byProjectAndMain(project).then((value) {
        finnList = value.map((e) => e.uuid).toList();
      });
    }

    Map<String, double> items = {};

    final collection = db.collection("s4c_finncontrib");
    final query = await collection.where("finn", whereIn: finnList).get();
    for (var element in query.docs) {
      FinnContribution item = FinnContribution.fromJson(element.data());
      if (items.containsKey(item.financier)) {
        items[item.financier] = items[item.financier]! + item.amount;
      } else {
        items[item.financier] = item.amount;
      }
    }
    return items;
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

  static Future<List> getByFinn(finn) async {
    final collection = db.collection("s4c_finncontrib");
    final query = await collection.where("finn", isEqualTo: finn).get();
    List items = [];
    for (var element in query.docs) {
      items.add(FinnContribution.fromJson(element.data()));
    }
    return items;
  }

  static Future<List<FinnContribution>> getByProject(project) async {
    final collection = db.collection("s4c_finncontrib");
    List finnList = await SFinn.byProject(project);
    List<FinnContribution> items = [];
    final query = await collection
        .where("finn", whereIn: finnList.map((e) => e.uuid))
        .get();
    for (var element in query.docs) {
      items.add(FinnContribution.fromJson(element.data()));
    }

    // for (var finn in finnList) {
    //   final query = await collection.where("finn", isEqualTo: finn.uuid).get();
    //   for (var element in query.docs) {
    //     items.add(FinnContribution.fromJson(element.data()));
    //   }
    // }

    return items;
  }

  @override
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

  static Future<Map<String, double>> getSummaryByPartner(partner,
      {project}) async {
    final collection = db.collection("s4c_finndistrib");
    QuerySnapshot<Map<String, dynamic>>? query;
    if (project != null) {
      List? finnList;
      await SFinn.byProject(project).then((value) {
        finnList = value.map((e) => e.uuid).toList();
      });
      query = await collection
          .where("partner", isEqualTo: partner)
          .where("finn", whereIn: finnList)
          .get();
    } else {
      query = await collection.where("partner", isEqualTo: partner).get();
    }
    double total = 0;
    for (var element in query.docs) {
      FinnDistribution item = FinnDistribution.fromJson(element.data());
      total += item.amount;
    }
    return {
      "total": total,
    };
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

  static Future<List<FinnDistribution>> getByProject(project) async {
    final collection = db.collection("s4c_finndistrib");
    List finnList = await SFinn.byProject(project);

    List<FinnDistribution> items = [];
    final query = await collection
        .where("finn", whereIn: finnList.map((e) => e.uuid))
        .get();
    for (var element in query.docs) {
      items.add(FinnDistribution.fromJson(element.data()));
    }

    return items;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class Invoice {
  String id;
  String uuid;
  String number;
  String code;
  String finn;
  String concept;
  DateTime date;
  DateTime paidDate;
  double base;
  double taxes;
  double total;
  String desglose;
  String provider;
  String document;
  String partner;
  String currency;
  double imputation;

  Invoice(
      this.id,
      this.uuid,
      this.number,
      this.code,
      this.finn,
      this.concept,
      this.date,
      this.paidDate,
      this.base,
      this.taxes,
      this.total,
      this.desglose,
      this.provider,
      this.document,
      this.partner,
      this.currency,
      {this.imputation = 100.0});

  factory Invoice.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("currency")) {
      json["currency"] = "EUR";
    } else {
      if (!CURRENCIES.containsKey(json["currency"])) {
        json["currency"] = "EUR";
      }
    }
    if (!json.containsKey("imputation")) {
      json["imputation"] = 100.0;
    }
    DateTime date = DateTime.now();
    try {
      date = DateTime.parse(json["date"]);
    } catch (e) {
      try {
        date = DateFormat('dd-MM-yyyy').parse(json["date"]);
      } catch (e) {
        date = DateTime.now();
      }
    }

    DateTime paidDate = DateTime.now();
    try {
      paidDate = DateTime.parse(json["paidDate"]);
    } catch (e) {
      try {
        paidDate = DateFormat('dd-MM-yyyy').parse(json["paidDate"]);
      } catch (e) {
        paidDate = DateTime.now();
      }
    }
    return Invoice(
      json["id"],
      json["uuid"],
      json["number"],
      json["code"],
      json["finn"],
      json["concept"],
      date,
      paidDate,
      json["base"],
      json["taxes"],
      json["total"],
      json["desglose"],
      json["provider"],
      json["document"],
      json["partner"],
      json["currency"],
      imputation: json["imputation"],
    );
  }

  factory Invoice.getEmpty() {
    return Invoice(
      "", // id
      const Uuid().v4(), // uuid
      "", // number
      "", // code
      "", // finn
      "", // concept
      DateTime.now(), // date
      DateTime.now(), // date
      0, // base
      0, // taxes
      0, // total
      "", // desglose
      "", // provider
      "", // document
      "", // partner
      "EUR", // currency
      imputation: 100.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'number': number,
        'code': code,
        'finn': finn,
        'concept': concept,
        'date': DateFormat('yyyy-MM-dd').format(date),
        'paidDate': DateFormat('yyyy-MM-dd').format(paidDate),
        'base': base,
        'taxes': taxes,
        'total': total,
        'desglose': desglose,
        'provider': provider,
        'document': document,
        'partner': partner,
        'currency': currency,
        'imputation': imputation,
      };

  void save() async {
    final collection = db.collection("s4c_invoices");
    if (id == "") {
      id = uuid;
      Map<String, dynamic> data = toJson();
      collection.add(data);
    } else {
      final item = await collection.doc(id).get();
      Map<String, dynamic> data = toJson();
      collection.doc(item.id).set(data);
    }
  }

  void delete() {
    final collection = db.collection("s4c_invoices");
    if (id != "") {
      collection.doc(id).delete();
    }
    id = "";
  }

  static Future<List> getByFinn(finn) async {
    List finnUuids = [];
    if (finn.runtimeType is String) {
      finnUuids = [finn];
    } else {
      finnUuids = finn;
    }
    final collection = db.collection("s4c_invoices");
    final query = await collection.where("finn", whereIn: finnUuids).get();
    List items = [];
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  static Future<Map<String, dynamic>> getSummaryByFinn(finn) async {
    final collection = db.collection("s4c_invoices");
    final query = await collection.where("finn", isEqualTo: finn).get();
    double total = 0;
    double taxes = 0;
    double base = 0;
    int count = 0;
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      total += item.total * item.imputation * 0.01;
      taxes += item.taxes * item.imputation * 0.01;
      base += item.base * item.imputation * 0.01;
      count++;
    }
    return {
      "total": total,
      "taxes": taxes,
      "base": base,
      "count": count,
    };
  }

  static Future<Map<String, dynamic>> getSummaryByPartner(partner,
      {project}) async {
    final collection = db.collection("s4c_invoices");
    QuerySnapshot<Map<String, dynamic>>? query;
    if (project != null) {
      List? finnList;
      await SFinn.byProject(project).then((value) {
        finnList = value.map((e) => e.uuid).toList();
      });
      query = await collection
          .where("partner", isEqualTo: partner)
          .where("finn", whereIn: finnList)
          .get();
    } else {
      query = await collection.where("partner", isEqualTo: partner).get();
    }

    double total = 0;
    double taxes = 0;
    double base = 0;
    int count = 0;
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      total += item.total * item.imputation * 0.01;
      taxes += item.taxes * item.imputation * 0.01;
      base += item.base * item.imputation * 0.01;
      count++;
    }
    return {
      "total": total,
      "taxes": taxes,
      "base": base,
      "count": count,
    };
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
