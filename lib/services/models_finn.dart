import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class SFinnInfo extends Object {
  String id;
  String uuid;
  String project;

  List partidas = [];

  // List<Map<String, dynamic>> contributions = [];
  // List<Map<String, dynamic>> distributions = [];

  SFinnInfo(this.id, this.uuid, this.project);

  factory SFinnInfo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("project")) {
      json["project"] = "";
    }
    if (!json.containsKey("partidas")) {
      json["partidas"] = [];
    }
    SFinnInfo item = SFinnInfo(json["id"], json["uuid"], json["project"]);
    item.partidas = json["partidas"]
        .map((e) => SFinn.fromJson(e as Map<String, dynamic>))
        .toList();
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'project': project,
        'partidas': partidas.map((e) => e.toJson()).toList(),
      };

  void save() async {
    final database = db.collection("s4c_finninfo");
    if (id == "") {
      id = uuid;
      Map<String, dynamic> data = toJson();
      database.add(data).then((value) => id = value.id);
//      database.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    final database = db.collection("s4c_finninfo");
    if (id != "") {
      database.doc(id).delete();
    }
  }

  static Future<SFinnInfo?> byProject(String uuidProject) async {
    try {
      final database = db.collection("s4c_finninfo");
      QuerySnapshot query =
          await database.where('project', isEqualTo: uuidProject).get();
      if (query.docs.isNotEmpty) {
        SFinnInfo item =
            SFinnInfo.fromJson(query.docs.first.data() as Map<String, dynamic>);
        item.id = query.docs.first.id;
        return item;
      }
    } catch (e) {
      print("DBG ERROR: $e");
    }
    return null;
  }

  double getTotalContrib() {
    double total = 0;
    for (var partida in partidas) {
      total += partida.getAmountContrib();
    }
    return total;
  }

  double getContribByFinancier(String orgUuid) {
    double total = 0;
    for (SFinn partida in partidas) {
      if (partida.orgUuid == orgUuid) {
        total += partida.getAmountContrib();
      }
    }
    return total;
  }

  String toString() {
    return jsonEncode(toJson());
  }
}

class SFinn extends Object {
  String id;
  String uuid;
  String name;
  String description;
  String parent;
  String project;
  String orgUuid;
  double contribution;
  Organization? organization;
  int level = -1;

  List<dynamic> partidas = [];
  // List<dynamic> contributions = [];
  List<dynamic> distributions = [];

  SFinn(this.id, this.uuid, this.name, this.description, this.parent,
      this.project,
      {this.orgUuid = "", this.contribution = 0.0});

  factory SFinn.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("contribution")) {
      json["contribution"] = 0.0;
    }
    if (!json.containsKey("id")) {
      json["id"] = "";
    }
    SFinn partida = SFinn(
      json["id"],
      json["uuid"],
      json['name'],
      json['description'],
      json['parent'],
      json['project'],
      orgUuid: json['orgUuid'],
      contribution: json['contribution'],
    );

    if (json.containsKey("partidas")) {
      partida.partidas = json["partidas"]
          .map((e) => SFinn.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // if (json.containsKey("contributions")) {
    //   partida.contributions = json["contributions"]
    //       .map((e) => FinnContribution.fromJson(e as Map<String, dynamic>))
    //       .toList();
    // }

    if (json.containsKey("distributions")) {
      partida.distributions = json["distributions"]
          .map((e) => FinnDistribution.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return partida;
  }

  static SFinn getEmpty() {
    return SFinn("", "", "", "", "", "");
  }

  Future<Organization> getOrganization() async {
    organization ??= await Organization.byUuid(orgUuid);
    return organization!;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'parent': parent,
        'project': project,
        'orgUuid': orgUuid,
        'contribution': contribution,
        'partidas': partidas.map((e) => e.toJson()).toList(),
      };

/*
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
*/

  double getAmountContrib() {
    double total = 0;
    for (SFinn partida in partidas) {
      total += partida.getAmountContrib();
    }
    if (total == 0) {
      total = contribution;
    }
    return total;
  }

/*
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
*/

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
    items.sort((a, b) {
      if (a.orgUuid == b.orgUuid) {
        return a.name.compareTo(b.name);
      } else {
        return a.orgUuid.compareTo(b.orgUuid);
      }
    });
    return items;
  }

  static Future<void> fixModels() async {
    QuerySnapshot query = await db.collection("s4c_finns").get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      SFinn item = SFinn.fromJson(data);
      item.save();
    }
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
    int deep = 0;
    SFinn finn = this;
    if (finn.name == "1.1.1") {
      while (finn.parent != "") {
        print("DBG 0001 ${finn.name} ${deep}");
        deep++;
        finn = SFinn.byUuid(finn.parent);
      }
    }
    return (deep);

    // else {
    //   if (level == -1) {
    //     level = SFinn.byUuid(parent).getLevel(deep + 1);
    //   }
    //   return level;
    // }
  }

  static SFinn byUuid(String uuid) {
    final database = db.collection("s4c_finns");
    SFinn item = SFinn('', uuid, '', '', '', '');
    database.where("uuid", isEqualTo: uuid).get().then((querySnapshot) {
      var first = querySnapshot.docs.first;
      item = SFinn.fromJson(first.data());
      item.id = first.id;
      Organization.byUuid(item.orgUuid).then((value) {
        item.organization = value;
      });
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

  void save() async {
    final database = db.collection("s4c_finns");
    if (uuid == "") {
      uuid = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      await database.add(data).then((value) {
        id = value.id;
      });
    } else {
      if (id == "") {
        final query = await database.where("uuid", isEqualTo: uuid).get();
        if (query.docs.isNotEmpty) {
          id = query.docs.first.id;
        }
      }
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
    }
  }

  void delete() {
    final database = db.collection("s4c_finns");
    if (id != "") {
      database.doc(id).delete();
    } else {
      database.where("uuid", isEqualTo: uuid).get().then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
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
    if (finnList.isEmpty) {
      return items;
    }
    final query = await collection
        .where("finn", whereIn: finnList.map((e) => e.uuid))
        .get();
    for (var element in query.docs) {
      items.add(FinnDistribution.fromJson(element.data()));
    }

    return items;
  }

  void delete() {
    final database = db.collection("s4c_finndistrib");
    if (id != "") {
      database.doc(id).delete();
    }
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

  SFinn finnObj = SFinn.getEmpty();
  SProject projectObj = SProject("");

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
    finnUuids = [finn];

    final collection = db.collection("s4c_invoices");
    List items = [];
    if (finnUuids.isEmpty) {
      return items;
    }

    try {
      final query = await collection.where("finn", whereIn: finnUuids).get();
      for (var element in query.docs) {
        print("DBG 0001 ${element.data()}");
        Invoice item = Invoice.fromJson(element.data());
        item.id = element.id;
        items.add(item);
      }
    } catch (e) {
      print("DBG ERROR: $e");
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

  static Future<List> getByPartner(partner) async {
    final collection = db.collection("s4c_invoices");
    List items = [];
    QuerySnapshot<Map<String, dynamic>>? query =
        await collection.where("partner", isEqualTo: partner).get();
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      await item.getFinn();
      await item.getProject();
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

  Future<void> getFinn() async {
    final collection = db.collection("s4c_finns");
    final query = await collection.where("uuid", isEqualTo: finn).get();
    SFinn item = SFinn.fromJson(query.docs.first.data());
    finnObj = item;
  }

  Future<void> getProject() async {
    final collection = db.collection("s4c_projects");
    final query =
        await collection.where("uuid", isEqualTo: finnObj.project).get();
    SProject item = SProject.fromJson(query.docs.first.data());
    projectObj = item;
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
  DateTime date;
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

  factory BankTransfer.getEmpty() {
    return BankTransfer(
      "", // id
      const Uuid().v4(), // uuid
      "", // number
      "", // code
      "", // project
      "", // concept
      DateTime.now(), // date
      "", // emissor
      "", // receiver
      0, // amountSource
      0, // exchangeSource
      0, // commissionSource
      0, // amountIntermediary
      0, // exchangeIntermediary
      0, // commissionIntermediary
      0, // amountDestination
      0, // commissionDestination
      "EUR", // currencySource
      "EUR", // currencyIntermediary
      "EUR", // currencyDestination
      "", // document
    );
  }

  factory BankTransfer.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("currencySource")) {
      json["currencySource"] = "EUR";
    } else {
      if (!CURRENCIES.containsKey(json["currencySource"])) {
        json["currencySource"] = "EUR";
      }
    }
    if (!json.containsKey("currencyIntermediary")) {
      json["currencyIntermediary"] = "EUR";
    } else {
      if (!CURRENCIES.containsKey(json["currencyIntermediary"])) {
        json["currencyIntermediary"] = "EUR";
      }
    }
    if (!json.containsKey("currencyDestination")) {
      json["currencyDestination"] = "EUR";
    } else {
      if (!CURRENCIES.containsKey(json["currencyDestination"])) {
        json["currencyDestination"] = "EUR";
      }
    }
    if (!json.containsKey("document")) {
      json["document"] = "";
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

    if (json["amountIntermediary"] != 0) {
      json["exchangeSource"] =
          json["amountIntermediary"] / json["amountSource"];
      json["exchangeIntermediary"] =
          json["amountDestination"] / json["amountIntermediary"];
    } else {
      json["exchangeIntermediary"] = 0;
      json["exchangeSource"] = json["amountDestination"] / json["amountSource"];
    }

    return BankTransfer(
      json["id"],
      json["uuid"],
      json["number"],
      json["code"],
      json["project"],
      json["concept"],
      date,
      json["emissor"],
      json["receiver"],
      json["amountSource"],
      json["exchangeSource"],
      json["commissionSource"],
      json["amountIntermediary"],
      json["exchangeIntermediary"],
      json["commissionIntermediary"],
      json["amountDestination"],
      json["commissionDestination"],
      json["currencySource"],
      json["currencyIntermediary"],
      json["currencyDestination"],
      json["document"],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'number': number,
        'code': code,
        'project': project,
        'concept': concept,
        'date': DateFormat('yyyy-MM-dd').format(date),
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
    if (amountIntermediary != 0) {
      exchangeSource = amountIntermediary / (amountSource - commissionSource);
      exchangeIntermediary =
          amountDestination / (amountIntermediary - commissionIntermediary);
    } else {
      exchangeIntermediary = 0;
      exchangeSource = amountDestination / (amountSource - commissionSource);
    }

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
