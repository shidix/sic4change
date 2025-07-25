import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

class SFinnInfo extends Object {
  static const String tbName = "s4c_finninfo";
  String id;
  String uuid;
  String project;

  List partidas = [];
  List distributions = [];
  List partners = [];

  SFinnInfo(this.id, this.uuid, this.project);

  factory SFinnInfo.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("project")) {
      json["project"] = "";
    }
    if (!json.containsKey("partidas")) {
      json["partidas"] = [];
    }
    if (!json.containsKey("distributions")) {
      json["distributions"] = [];
    }
    SFinnInfo item = SFinnInfo(json["id"], json["uuid"], json["project"]);
    item.partidas = json["partidas"]
        .map((e) => SFinn.fromJson(e as Map<String, dynamic>))
        .toList();
    item.distributions = json["distributions"]
        .map((e) => Distribution.fromJson(e as Map<String, dynamic>))
        .toList();
    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'project': project,
        'partidas': partidas.map((e) => e.toJson()).toList(),
        'distributions': distributions.map((e) => e.toJson()).toList(),
      };

  void save() async {
    final database = FirebaseFirestore.instance.collection(tbName);
    if (id == "") {
      Map<String, dynamic> data = toJson();
      database.add(data).then((value) => id = value.id);
      createLog(
          "Creada información de financiación de la iniciativa ${SProject.getProjectName(project)}");
//      database.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      database.doc(id).set(data);
      createLog(
          "Modificada información de financiación de la iniciativa ${SProject.getProjectName(project)}");
    }
  }

  void delete() {
    final database = FirebaseFirestore.instance.collection(tbName);
    if (id != "") {
      database.doc(id).delete();
      createLog(
          "Borrada información de financiación de la iniciativa ${SProject.getProjectName(project)}");
    }
  }

  static Future<SFinnInfo?> byProject(String uuidProject) async {
    try {
      final database = FirebaseFirestore.instance.collection(tbName);
      QuerySnapshot query =
          await database.where('project', isEqualTo: uuidProject).get();
      if (query.docs.isNotEmpty) {
        final item =
            SFinnInfo.fromJson(query.docs.first.data() as Map<String, dynamic>);
        item.id = query.docs.first.id;
        return item;
      }
    } catch (e) {
      log('ERROR in SFinnInfo.byProject');
      print(e);
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
        try {
          total += partida.getAmountContrib();
        } catch (e) {
          total += 0;
        }
      }
    }
    return total;
  }

  double getDistribByFinn(SFinn finn) {
    List<String> childrendsUuid = [];
    if (partners.isEmpty) {
      return 0;
    }
    for (SFinn child in finn.getChildren()) {
      childrendsUuid.add(child.uuid);
    }
    childrendsUuid.add(finn.uuid);
    double total = 0;

    for (Distribution distrib in distributions) {
      if (childrendsUuid.contains(distrib.finn.uuid)) {
        if (partners.contains(distrib.partner.uuid)) {
          total += distrib.amount;
        } else {
          distributions.remove(distrib);
          distrib.delete();
          save();
        }
      }
    }
    return total;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  void updateDistribution(Distribution distribution) {
    int index = distributions
        .indexWhere((element) => element.uuid == distribution.uuid);
    if (index != -1) {
      distributions[index] = distribution;
    } else {
      distributions.add(distribution);
    }
    save();
  }

  void deleteDistribution(Distribution distribution) {
    distributions.removeWhere((element) => element.uuid == distribution.uuid);
    save();
  }
}

class SFinn extends Object {
  static const String tbName = "s4c_finns";
  String id;
  String uuid;
  String name;
  String description;
  String parent;
  String project;
  String orgUuid;
  DateTime start;
  DateTime end;
  double contribution;
  Organization? organization;
  int level = -1;

  List<dynamic> partidas = [];
  // List<dynamic> contributions = [];
  List<dynamic> distributions = [];

  SFinn(
    this.id,
    this.uuid,
    this.name,
    this.description,
    this.parent,
    this.project,
    this.start,
    this.end, {
    this.orgUuid = "",
    this.contribution = 0.0,
  });

  int compareTo(SFinn b) {
    SFinn a = this;
    List<String> aSlices = a.name.split(".");
    List<String> bSlices = b.name.split(".");
    //Remove empty elements from aSlices and bSlices
    aSlices.removeWhere((element) => element == "");
    bSlices.removeWhere((element) => element == "");

    int index = 0;
    while (index < aSlices.length) {
      try {
        int aInt = int.parse(aSlices[index]);
        int bInt = 0;
        try {
          bInt = int.parse(bSlices[index]);
        } catch (e) {
          return 1;
        }
        if (aInt.compareTo(bInt) != 0) return aInt.compareTo(bInt);
      } catch (e) {
        if (aSlices[index].compareTo(bSlices[index]) != 0) {
          return aSlices[index].compareTo(bSlices[index]);
        }
      }
      index += 1;
    }
    return 0;
  }

  factory SFinn.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("contribution")) {
      json["contribution"] = 0.0;
    }
    if (!json.containsKey("id")) {
      json["id"] = "";
    }
    if (!json.containsKey("start")) {
      json["start"] = DateTime.now();
    }
    if (!json.containsKey("end")) {
      json["end"] = getDate(json["start"]).add(const Duration(days: 365));
    }
    SFinn partida = SFinn(
      json["id"],
      json["uuid"],
      json['name'],
      json['description'],
      json['parent'],
      json['project'],
      getDate(json["start"]),
      getDate(json["end"]),
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
    return SFinn("", "", "", "", "", "", DateTime.now(),
        DateTime.now().add(const Duration(days: 365)));
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
        'start': start,
        'end': end,
        'contribution': contribution,
        'partidas': partidas.map((e) => e.toJson()).toList(),
      };

  double getAmountContrib() {
    double total = 0;
    for (SFinn partida in partidas) {
      try {
        total += partida.getAmountContrib();
      } catch (e) {
        total += 0;
      }
    }
    if (total == 0) {
      total = contribution;
    }
    return total;
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
    await FirebaseFirestore.instance
        .collection(tbName)
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
          log(e.toString());
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
    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data["id"] = doc.id;
      SFinn item = SFinn.fromJson(data);
      item.save();
    }
  }

  static Future<List> byProjectAndMain(String uuidProject) async {
    final List<SFinn> items = [];
    final database = FirebaseFirestore.instance.collection(tbName);
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
          log(e.toString());
        }
      }
    });
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  List<SFinn> getChildren() {
    List<SFinn> items = [];
    for (SFinn item in partidas) {
      items.add(item);
      items.addAll(item.getChildren());
    }
    return items;
  }

  // int getLevel() {
  //   int deep = 0;
  //   SFinn finn = this;
  //   if (finn.name == "1.1.1") {
  //     while (finn.parent != "") {
  //       deep++;
  //       finn = SFinn.byUuid(finn.parent);
  //     }
  //   }
  //   return (deep);

  // else {
  //   if (level == -1) {
  //     level = SFinn.byUuid(parent).getLevel(deep + 1);
  //   }
  //   return level;
  // }
  // }

  static SFinn byUuid(String uuid) {
    SFinn item = SFinn('', uuid, '', '', '', '', DateTime.now(),
        DateTime.now().add(const Duration(days: 365)));
    FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((querySnapshot) {
      var first = querySnapshot.docs.first;
      item = SFinn.fromJson(first.data());
      item.id = first.id;
      Organization.byUuid(item.orgUuid).then((value) {
        item.organization = value;
      });
    });
    return item;
  }

  static String getFinnName(String uuid) {
    SFinn item = SFinn('', uuid, '', '', '', '', DateTime.now(),
        DateTime.now().add(const Duration(days: 365)));
    FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((querySnapshot) {
      var first = querySnapshot.docs.first;
      item = SFinn.fromJson(first.data());
      item.id = first.id;
      Organization.byUuid(item.orgUuid).then((value) {
        item.organization = value;
      });
    });
    return item.name;
  }

  Future<List<SFinn>> getChildrens() async {
    final List<SFinn> items = [];
    await FirebaseFirestore.instance
        .collection(tbName)
        .where("parent", isEqualTo: uuid)
        .get()
        .then((querySnapshot) {
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
    if (uuid == "") {
      uuid = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance
          .collection(tbName)
          .add(data)
          .then((value) {
        id = value.id;
      });
      createLog(
          "Creada financiación $name de la iniciativa ${SProject.getProjectName(project)}");
    } else {
      if (id == "") {
        final query = await FirebaseFirestore.instance
            .collection(tbName)
            .where("uuid", isEqualTo: uuid)
            .get();
        if (query.docs.isNotEmpty) {
          id = query.docs.first.id;
        }
      }
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
      createLog(
          "Modificada financiación $name de la iniciativa ${SProject.getProjectName(project)}");
    }
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    } else {
      FirebaseFirestore.instance
          .collection(tbName)
          .where("uuid", isEqualTo: uuid)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
    createLog(
        "Borrada financiación $name de la iniciativa ${SProject.getProjectName(project)}");
  }

  @override
  String toString() {
    Map<String, dynamic> data;
    data = {
      'id': id,
      'uuid': uuid,
      'name': name,
      'description': description,
      'parent': parent,
      'project': project,
      'orgUuid': orgUuid,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'contribution': contribution,
      'partidas': partidas.map((e) => e.toJson()).toList(),
    };
    return jsonEncode(data);
  }
}

class FinnDistribution {
  String id;
  String partner;
  double amount;
  String finn;
  String subject;

  static const String tbName = "s4c_finndistrib";

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
    if (id == "") {
      id = const Uuid().v4();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).add(data);
      createLog(
          "Creada distribución de la financiación ${SFinn.getFinnName(finn)}");
    } else {
      final query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("id", isEqualTo: id)
          .limit(1)
          .get();
      final item = query.docs.first;
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(item.id).set(data);
      createLog(
          "Modificada distribución de la financiación ${SFinn.getFinnName(finn)}");
    }
  }

  static Future<Map<String, double>> getSummaryByPartner(partner,
      {project}) async {
    QuerySnapshot<Map<String, dynamic>>? query;
    if (project != null) {
      List? finnList;
      await SFinn.byProject(project).then((value) {
        finnList = value.map((e) => e.uuid).toList();
      });
      query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("partner", isEqualTo: partner)
          .where("finn", whereIn: finnList)
          .get();
    } else {
      query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("partner", isEqualTo: partner)
          .get();
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
    final query = await FirebaseFirestore.instance
        .collection(tbName)
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
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("finn", isEqualTo: finn)
        .get();
    List items = [];
    for (var element in query.docs) {
      items.add(FinnDistribution.fromJson(element.data()));
    }
    return items;
  }

  static Future<List<FinnDistribution>> getByProject(project) async {
    List<FinnDistribution> items = [];

    // final collection = db.collection("s4c_finndistrib");
    // List finnList = await SFinn.byProject(project);
    // if (finnList.isEmpty) {
    //   return items;
    // }
    // final query = await collection
    //     .where("finn", whereIn: finnList.map((e) => e.uuid))
    //     .get();
    // for (var element in query.docs) {
    //   items.add(FinnDistribution.fromJson(element.data()));
    // }

    return items;
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
    createLog(
        "Borrada distribución de la financiación ${SFinn.getFinnName(finn)}");
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class TaxKind extends Object {
  static const String tbName = "s4c_taxkind";

  String id = "";
  String uuid;
  String code;
  String name;
  double percentaje;
  DateTime from;
  DateTime to;
  String country;

  TaxKind(this.uuid, this.code, this.name, this.percentaje, this.from, this.to,
      this.country);

  factory TaxKind.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("country")) {
      json["country"] = "";
    }

    TaxKind item = TaxKind(
      json['uuid'],
      json['code'],
      json['name'],
      json['percentaje'],
      getDate(json['from']),
      getDate(json['to']),
      "España",
    );

    // Country.byUuid(json["country"]).then((value) {
    //   item.country = value;
    // });

    return item;
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'code': code,
        'name': name,
        'percentaje': percentaje,
        'from': from,
        'to': to,
        'country': country,
      };

  Future<TaxKind> save() async {
    (uuid == "") ? uuid = const Uuid().v4() : uuid = uuid;

    if (id == "") {
      FirebaseFirestore.instance
          .collection(tbName)
          .add(toJson())
          .then((value) => id = value.id);
    } else {
      final item =
          await FirebaseFirestore.instance.collection(tbName).doc(id).get();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(item.id).set(data);
    }
    return this;
  }

  Future<bool> delete() async {
    try {
      if (id != "") {
        await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<TaxKind?> byUuid(String uuid) {
    return FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final item = TaxKind.fromJson(querySnapshot.docs.first.data());
        item.id = querySnapshot.docs.first.id;
        return item;
      }
      return null;
    });
  }

  static Future<List<TaxKind>> getAll() async {
    List<TaxKind> items = [];

    QuerySnapshot query =
        await FirebaseFirestore.instance.collection(tbName).get();
    for (var doc in query.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      TaxKind item = TaxKind.fromJson(data);
      item.id = doc.id;
      items.add(item);
    }
    return items;
  }

  static TaxKind getEmpty() {
    return TaxKind("", "", "", 0.0, DateTime.now(),
        DateTime.now().add(Duration(days: 3650)), "España");
  }
}

class Invoice extends Object {
  static const String tbName = "s4c_invoices";

  String id;
  String uuid;
  String number;
  String code;
  String concept;
  DateTime date;
  DateTime paidDate;
  double base;
  double taxes;
  double total;
  double exchangeRate = 1.0;
  String desglose;
  String provider;
  String document;
  String currency;
  String tracker;
  String account = "";
  String? taxKind;

  SFinn finnObj = SFinn.getEmpty();
  SProject projectObj = SProject("");
  List<InvoiceDistrib> invoiceDistrib = [];

  Invoice(
    this.id,
    this.uuid,
    this.number,
    this.code,
    this.concept,
    this.date,
    this.paidDate,
    this.base,
    this.taxes,
    this.total,
    this.desglose,
    this.provider,
    this.document,
    this.currency,
    this.tracker,
  );
  factory Invoice.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("taxKind")) {
      json["taxKind"] = "I.V.A.";
    }
    if (!json.containsKey("currency")) {
      json["currency"] = "EUR";
    } else {
      if (!CURRENCIES.containsKey(json["currency"])) {
        json["currency"] = "EUR";
      }
    }
    if (!json.containsKey("imputation")) {
      json["imputation"] = 0.0;
    }
    DateTime date = DateTime.now();
    try {
      date = getDate(json["date"]);
    } catch (e) {
      try {
        date = DateFormat('dd-MM-yyyy').parse(json["date"]);
      } catch (e) {
        date = DateTime.now();
      }
    }
    DateTime paidDate = DateTime.now();
    try {
      paidDate = getDate(json["paidDate"]);
    } catch (e) {
      try {
        paidDate = DateFormat('dd-MM-yyyy').parse(json["paidDate"]);
      } catch (e) {
        paidDate = DateTime.now();
      }
    }
    Invoice item = Invoice(
      json["id"],
      json["uuid"],
      json["number"],
      json["code"],
      json["concept"],
      date,
      paidDate,
      json["base"],
      json["taxes"],
      json["total"],
      json["desglose"],
      json["provider"],
      json["document"],
      json["currency"],
      json["tracker"],
    );
    if (json.containsKey("taxKind")) {
      try {
        item.taxKind = json["taxKind"];
      } catch (e) {
        item.taxKind = "IVA";
      }
    }

    if (json.containsKey("account")) {
      item.account = json["account"];
    } else {
      item.account = "";
    }

    item.exchangeRate = ((json.containsKey("exchangeRate"))
        ? json["exchangeRate"]
        : 1.0) as double;

    return item;
  }

  factory Invoice.getEmpty() {
    return Invoice(
      "", // id
      const Uuid().v4(), // uuid
      "", // number
      "", // code
      "", // concept
      DateTime.now(), // date
      DateTime.now(), // date
      0, // base
      0, // taxes
      0, // total
      "", // desglose
      "", // provider
      "", // document
      "EUR", // currency
      "",
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'number': number,
        'code': code,
        'concept': concept,
        'date': date,
        'paidDate': paidDate,
        'base': base,
        'taxes': taxes,
        'total': total,
        'desglose': desglose,
        'provider': provider,
        'document': document,
        'currency': currency,
        'account': account,
        'tracker': tracker,
        'exchangeRate': exchangeRate,
        'taxKind': taxKind
      };

  static Future<String> newTracker() async {
    String tracker = getTracker();
    bool exists = true;
    while (exists) {
      final query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("tracker", isEqualTo: tracker)
          .get();
      if (query.docs.isEmpty) {
        exists = false;
      } else {
        tracker = getTracker();
      }
    }
    return tracker.toUpperCase();
  }

  Future<Invoice> save() async {
    if (id == "") {
      tracker = tracker.toUpperCase();
      Invoice? item = await Invoice.byTracker(tracker);
      if (item != null) {
        id = item.id;
        FirebaseFirestore.instance
            .collection(tbName)
            .doc(item.id)
            .set(toJson());
      } else {
        FirebaseFirestore.instance
            .collection(tbName)
            .add(toJson())
            .then((value) => id = value.id);
      }
      createLog("Creada la factura '$number'");
    } else {
      final item =
          await FirebaseFirestore.instance.collection(tbName).doc(id).get();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(item.id).set(data);
      createLog("Modificada la factura '$number'");
    }
    return this;
  }

  Future<bool> delete() async {
    try {
      if (id != "") {
        await FirebaseFirestore.instance.collection(tbName).doc(id).delete();
      }
      createLog("Borrada la factura '$number'");
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Invoice?> byTracker(String tracker) {
    return FirebaseFirestore.instance
        .collection(tbName)
        .where("tracker", isEqualTo: tracker.toUpperCase())
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final item = Invoice.fromJson(querySnapshot.docs.first.data());
        item.id = querySnapshot.docs.first.id;
        return item;
      }
      return null;
    });
  }

  static Future<List> getByFinn(finn) async {
    List finnUuids = [];
    finnUuids = [finn];

    List items = [];
    if (finnUuids.isEmpty) {
      return items;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("finn", whereIn: finnUuids)
          .get();
      for (var element in query.docs) {
        Invoice item = Invoice.fromJson(element.data());
        item.id = element.id;
        items.add(item);
      }
    } catch (e) {
      log("DBG ERROR: $e");
    }
    items.sort((a, b) => a.date.compareTo(b.date));

    return items;
  }

  static Future<List<Invoice>> afterDate(DateTime date) async {
    List<Invoice> items = [];
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("date", isGreaterThanOrEqualTo: date)
        .get();
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<List<Invoice>> all() async {
    List<Invoice> items = [];
    final query = await FirebaseFirestore.instance.collection(tbName).get();
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<List<Invoice>> beforeDate(DateTime date) async {
    List<Invoice> items = [];
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("date", isLessThanOrEqualTo: date)
        .get();

    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<Invoice> getByUuid(uuid) async {
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    if (query.docs.isEmpty) {
      return Invoice.getEmpty();
    }
    Invoice item = Invoice.fromJson(query.docs.first.data());
    item.id = query.docs.first.id;
    item.invoiceDistrib = await InvoiceDistrib.getByInvoice(item);
    return item;
  }

  Future<double> getImputation(String? excludeId) async {
    if (invoiceDistrib.isEmpty) {
      invoiceDistrib = await InvoiceDistrib.getByInvoice(this);
    }
    double total = 0;
    for (InvoiceDistrib distrib in invoiceDistrib) {
      if (distrib.id != excludeId) {
        total += distrib.amount;
      }
    }
    return total;
  }

  static Future<List<Invoice>> getListUuids(listUuids) async {
    List<Invoice> items = [];
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", whereIn: listUuids)
        .get();
    for (var element in query.docs) {
      Invoice item = Invoice.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  @override
  String toString() {
    try {
      return toJson().toString();
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      return "ERROR IN INVOICE id: $id, uuid: $uuid, tracker: $tracker";
    }
  }
}

class InvoiceDistrib extends Object {
  static const String tbName = "s4c_invoicedistrib";
  String id;
  String uuid;
  String invoice;
  String distribution;
  bool taxes = true;
  double percentaje;
  double exchangeRate = 1.0;
  double amount;

  InvoiceDistrib(
      this.id, this.uuid, this.invoice, this.distribution, this.percentaje,
      [this.amount = 0, this.taxes = true]);

  factory InvoiceDistrib.fromJson(Map<String, dynamic> json) {
    InvoiceDistrib item = InvoiceDistrib(
      json["id"],
      json["uuid"],
      json["invoice"],
      json["distribution"],
      json["percentaje"],
      json["amount"],
      json["taxes"],
    );

    item.exchangeRate =
        json.containsKey("exchangeRate") ? json["exchangeRate"] : 1.0;

    return item;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'invoice': invoice,
        'distribution': distribution,
        'percentaje': percentaje,
        'amount': amount,
        'exchangeRate': exchangeRate,
        'taxes': taxes,
      };

  void save() async {
    if (uuid == "") {
      uuid = const Uuid().v4();
    }

    if (id == "") {
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance
          .collection(tbName)
          .add(data)
          .then((value) => id = value.id);
    } else {
      FirebaseFirestore.instance.collection(tbName).doc(id).set(toJson());
    }
  }

  void remove() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    } else {
      FirebaseFirestore.instance
          .collection(tbName)
          .where("uuid", isEqualTo: uuid)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }

  static Future<InvoiceDistrib> getByDistributionAndInvoice(
      String distribution, String invoice) async {
    final query = await FirebaseFirestore.instance
        .collection(InvoiceDistrib.tbName)
        .where("distribution", isEqualTo: distribution)
        .where("invoice", isEqualTo: invoice)
        .get();
    if (query.docs.isNotEmpty) {
      Map<String, dynamic> data = query.docs.first.data();
      data["id"] = query.docs.first.id;
      return InvoiceDistrib.fromJson(data);
    } else {
      return InvoiceDistrib("", "", invoice, distribution, 100.0);
    }
  }

  static Future<List<InvoiceDistrib>> getByInvoice(invoice) async {
    if (invoice == null) {
      return [];
    }

    QuerySnapshot<Map<String, dynamic>> query;
    if (invoice is List) {
      if (invoice.isEmpty) {
        return [];
      }
      query = await FirebaseFirestore.instance
          .collection(InvoiceDistrib.tbName)
          .where("invoice", whereIn: invoice.map((e) => e.uuid).toList())
          .get();
    } else {
      query = await FirebaseFirestore.instance
          .collection(InvoiceDistrib.tbName)
          .where("invoice", isEqualTo: invoice.uuid)
          .get();
    }
    List<InvoiceDistrib> items = [];
    for (var element in query.docs) {
      items.add(InvoiceDistrib.fromJson(element.data()));
    }
    return items;
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance
          .collection(InvoiceDistrib.tbName)
          .doc(id)
          .delete();
    }
  }
}

class BankTransfer {
  static const String tbName = "s4c_banktransfers";

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

  Organization? emissorOrg;
  Organization? receiverOrg;

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
      FirebaseFirestore.instance.collection(tbName).add(data);
    } else {
      final item =
          await FirebaseFirestore.instance.collection(tbName).doc(id).get();
      Map<String, dynamic> data = toJson();
      FirebaseFirestore.instance.collection(tbName).doc(item.id).set(data);
    }
  }

  static Future<List<BankTransfer>> getByProject(project) async {
    final query = await FirebaseFirestore.instance
        .collection(tbName)
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
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    BankTransfer item = BankTransfer.fromJson(query.docs.first.data());
    item.id = query.docs.first.id;
    return item;
  }

  @override
  String toString() {
    Map<String, dynamic> data;
    data = {
      'id': id,
      'uuid': uuid,
      'number': number,
      'code': code,
      'project': project,
      'concept': concept,
      'date': date.toIso8601String(),
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

    return jsonEncode(data);
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }

  Widget getWorkFlow() {
    try {
      return Column(
        children: [
          Row(children: [
            Expanded(child: Text('${emissorOrg?.name}')),
            Expanded(
                child:
                    Text(toCurrency(amountSource), textAlign: TextAlign.right)),
            Expanded(
                child: Text(toCurrency(commissionSource),
                    textAlign: TextAlign.right)),
            Expanded(
                child: Text(toCurrency(exchangeSource, currencySource),
                    textAlign: TextAlign.right)),
          ]),
          (amountIntermediary != 0)
              ? Row(children: [
                  const Expanded(child: Text('Intermediario')),
                  Expanded(
                      child: Text(
                    toCurrency(amountIntermediary, currencyIntermediary),
                    textAlign: TextAlign.right,
                  )),
                  Expanded(
                      child: Text(
                          toCurrency(
                              commissionIntermediary, currencyIntermediary),
                          textAlign: TextAlign.right)),
                  Expanded(
                      child: Text(
                          toCurrency(
                              exchangeIntermediary, currencyIntermediary),
                          textAlign: TextAlign.right)),
                ])
              : Container(),
          Row(children: [
            Expanded(child: Text(receiverOrg!.name)),
            Expanded(
                child: Text(toCurrency(amountDestination, currencyDestination),
                    textAlign: TextAlign.right)),
            Expanded(
                child: Text(
                    toCurrency(commissionDestination, currencyDestination),
                    textAlign: TextAlign.right)),
            const Expanded(child: Text('')),
          ]),
        ],
      );
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      return const Text("Error en el flujo de trabajo");
    }
  }
}

class Distribution extends Object {
  static const String tbName = "s4c_distributions";
  String id = "";
  String uuid;
  String project;
  DateTime date = DateTime.now();
  String? description;
  SFinn finn;
  Organization partner;
  double amount;
  List<Invoice> invoices = [];

  Map<String, dynamic> mapinvoices = {};

  Distribution(this.uuid, this.project, this.description, this.finn,
      this.partner, this.amount);

  factory Distribution.fromJson(Map<String, dynamic> json) {
    try {
      Distribution item = Distribution(
          json["uuid"],
          json["project"],
          json["description"],
          SFinn.fromJson(json["finn"]),
          Organization.fromJson(json["partner"]),
          json["amount"]);
      if (json.containsKey("date")) {
        item.date = getDate(json["date"]);
      }

      if (json.containsKey("mapinvoices")) {
        if (json["mapinvoices"] is List) {
          item.mapinvoices = {};
        } else {
          item.mapinvoices = json["mapinvoices"];
          for (var element in item.mapinvoices.keys) {
            Invoice.getByUuid(element).then((value) {
              if (value.id != "") {
                item.invoices.add(value);
                item.mapinvoices[element]["exchangeRate"] = value.exchangeRate;
              } else {
                item.mapinvoices.remove(element);
                item.save();
              }
            });
          }
        }
      }

      return item;
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
    }

    return getEmpty();
  }

  static Distribution getEmpty() {
    return Distribution(
      const Uuid().v4(),
      "",
      "",
      SFinn.getEmpty(),
      Organization.getEmpty(),
      0,
    );
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'project': project,
        'description': description,
        'finn': finn.toJson(),
        'partner': partner.toJson(),
        'date': date,
        'amount': amount,
        'mapinvoices': mapinvoices,
      };

  static Future<List<Distribution>> all() async {
    try {
      List<Distribution> items = [];
      final query = await FirebaseFirestore.instance.collection(tbName).get();
      if (query.docs.isEmpty) {
        return items;
      }
      for (var element in query.docs) {
        Distribution item = Distribution.fromJson(element.data());
        item.id = element.id;
        items.add(item);
      }
      return items;
    } catch (e, stacktrace) {
      log(e.toString());
      log(stacktrace.toString());
      return [];
    }
  }

  static Future<Distribution> getByUuid(String uuid) async {
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", isEqualTo: uuid)
        .get();
    Distribution item = Distribution.fromJson(query.docs.first.data());
    item.id = query.docs.first.id;
    return item;
  }

  static Future<List<Distribution>> listByUuid(List<String> uuid) async {
    List<Distribution> items = [];
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("uuid", whereIn: uuid)
        .get();
    for (var element in query.docs) {
      Distribution item = Distribution.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  static Future<List<Distribution>> byProject(String uuid) async {
    final query = await FirebaseFirestore.instance
        .collection(tbName)
        .where("project", isEqualTo: uuid)
        .get();
    List<Distribution> items = [];
    for (var element in query.docs) {
      Distribution item = Distribution.fromJson(element.data());
      item.id = element.id;
      items.add(item);
    }
    return items;
  }

  void save() async {
    project = finn.project;
    if (uuid == "") {
      uuid = const Uuid().v4();
    } else {
      final query = await FirebaseFirestore.instance
          .collection(tbName)
          .where("uuid", isEqualTo: uuid)
          .get();
      if (query.docs.isNotEmpty) {
        id = query.docs.first.id;
      }

      if (id == "") {
        Map<String, dynamic> data = toJson();
        FirebaseFirestore.instance
            .collection(tbName)
            .add(data)
            .then((value) => id = value.id);
      } else {
        Map<String, dynamic> data = toJson();
        FirebaseFirestore.instance.collection(tbName).doc(id).set(data);
      }
    }
  }

  void delete() {
    if (id != "") {
      FirebaseFirestore.instance.collection(tbName).doc(id).delete();
    }
  }

  void updateMapinvoices() async {
    for (var invoice in mapinvoices.keys) {
      Invoice.getByUuid(invoice).then((value) {
        if (value.id == "") {
          mapinvoices.remove(invoice);
          save();
        } else {
          InvoiceDistrib.getByDistributionAndInvoice(uuid, invoice)
              .then((value) => mapinvoices[invoice] = value.toJson());
        }
      });
    }
    save();
  }

  double getExecuted() {
    double total = 0;
    if (mapinvoices.isEmpty) {
      return total;
    }
    for (var invoice in mapinvoices.values) {
      try {
        if (invoice.containsKey("exchangeRate")) {
          total += invoice["amount"] * invoice["exchangeRate"];
        } else {
          total += invoice["amount"];
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
      }
    }

    return total;
  }

  @override
  String toString() {
    Map<String, dynamic> data;
    data = {
      'id': id,
      'uuid': uuid,
      'project': project,
      'description': description,
      'finn': finn.toString(),
      'partner': partner.toString(),
      'date': date.toIso8601String(),
      'amount': amount,
      'mapinvoices': mapinvoices,
    };
    return jsonEncode(data);
  }
}
