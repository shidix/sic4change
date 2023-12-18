// import 'dart:ffi';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact.dart';
import 'package:sic4change/services/models_location.dart';
import 'package:uuid/uuid.dart';

FirebaseFirestore db = FirebaseFirestore.instance;
//--------------------------------------------------------------
//                           PROJECTS
//--------------------------------------------------------------
CollectionReference dbProject = db.collection("s4c_projects");

class SProject {
  String id = "";
  String uuid = "";
  String name = "";
  String description = "";
  String type = "";
  String budget = "";
  String manager = "";
  String programme = "";
  String announcement = "";
  String ambit = "";
  bool audit = false;
  bool evaluation = false;
  List financiers = [];
  List partners = [];
  ProjectType typeObj = ProjectType("");
  Contact managerObj = Contact("", "", "", "", "");
  Programme programmeObj = Programme("");
  List<Financier> financiersObj = [];
  List<Contact> partnersObj = [];
  ProjectDates datesObj = ProjectDates("");

  double dblbudget = 0;

  SProject(
    this.name,
  );
  /*SProject(this.uuid, this.name,
      [this.description = "",
      this.type = "",
      this.budget = "",
      this.manager = "",
      this.programme = "",
      this.announcement = "",
      this.ambit = "",
      this.audit = false,
      this.evaluation = false]);*/

  SProject.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        description = json['description'],
        type = json['type'],
        budget = json['budget'],
        manager = json['manager'],
        programme = json['programme'],
        announcement = json['announcement'],
        ambit = json['ambit'],
        audit = json['audit'],
        evaluation = json['evaluation'],
        financiers = json['financiers'],
        partners = json['partners'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'description': description,
        'type': type,
        'budget': budget,
        'manager': manager,
        'programme': programme,
        'announcement': announcement,
        'ambit': ambit,
        'audit': audit,
        'evaluation': evaluation,
        'financiers': financiers,
        'partners': partners,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProject.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProject.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProject.doc(id).delete();
  }

  Future<SProject> reload() async {
    DocumentSnapshot _doc = await dbProject.doc(id).get();
    final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
    data["id"] = _doc.id;
    // SProject _project = SProject.fromJson(data);
    typeObj = await getProjectType();
    managerObj = await getManager();
    programmeObj = await getProgramme();
    financiersObj = await getFinanciers();
    partnersObj = await getPartners();
    datesObj = await getDates();
    return this;
  }

  Future<void> updateProjectFinanciers() async {
    await dbProject.doc(id).update({"financiers": financiers});
  }

  Future<void> updateProjectPartners() async {
    await dbProject.doc(id).update({"partners": partners});
  }

  String getStatus() {
    if (datesObj.approved == "") return "Sin aprobar";
    if (datesObj.start == "") return "Sin iniciar";
    if (datesObj.end == "") return "En proceso";
    try {
      DateTime _start = DateTime.parse(datesObj.start);
      DateTime _end = DateTime.parse(datesObj.end);
      DateTime _approved = DateTime.parse(datesObj.approved);
      DateTime _today = DateTime.now();
      if (_today.isBefore(_start)) return "Sin iniciar";
      if (_today.isBefore(_approved)) return "Sin aprobar";
      if (_today.isAfter(_end)) return "Finalizado";
      return "En proceso";
    } catch (e) {
      return "Finalizado";
    }
  }

  Future<double> totalBudget() async {
    final contribs = db.collection("s4c_finncontrib");
    final finns = db.collection("s4c_finns");
    dblbudget = 0;
    await finns
        .where("project", isEqualTo: uuid)
        .get()
        .then((list_finns) async {
      for (var finn in list_finns.docs) {
        await contribs
            .where("finn", isEqualTo: finn.data()["uuid"])
            .get()
            .then((querySnapshot) {
          for (var doc in querySnapshot.docs) {
            final Map<String, dynamic> data = doc.data();
            dblbudget += data["amount"];
          }
        });
      }
      ;
    });
    return dblbudget;
  }

  Future<ProjectDates> getDates() async {
    if (datesObj.project == "") {
      datesObj = await getProjectDatesByProject(uuid);
    }
    return datesObj;
  }

  Future<ProjectType> getProjectType() async {
    try {
      QuerySnapshot query =
          await dbProjectType.where("uuid", isEqualTo: type).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return ProjectType.fromJson(data);
    } catch (e) {
      return ProjectType("");
    }
  }

  Future<Contact> getManager() async {
    try {
      QuerySnapshot query =
          await dbContacts.where("uuid", isEqualTo: manager).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Contact.fromJson(data);
    } catch (e) {
      return Contact("", "", "", "", "");
    }
  }

  Future<Programme> getProgramme() async {
    try {
      QuerySnapshot query =
          await dbProgramme.where("uuid", isEqualTo: programme).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Programme.fromJson(data);
    } catch (e) {
      return Programme("");
    }
  }

  Future<List<Financier>> getFinanciers() async {
    List<Financier> _fin_list = [];
    for (String fin in financiers) {
      try {
        QuerySnapshot query =
            await dbFinancier.where("uuid", isEqualTo: fin).get();
        final _doc = query.docs.first;
        final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
        data["id"] = _doc.id;
        Financier _financier = Financier.fromJson(data);
        _fin_list.add(_financier);
      } catch (e) {}
    }
    return _fin_list;
  }

  Future<List<Contact>> getPartners() async {
    List<Contact> _par_list = [];
    for (String par in partners) {
      try {
        QuerySnapshot query =
            await dbContacts.where("uuid", isEqualTo: par).get();
        final _doc = query.docs.first;
        final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
        data["id"] = _doc.id;
        Contact _contact = Contact.fromJson(data);
        _par_list.add(_contact);
      } catch (e) {}
    }
    return _par_list;
  }

  static Future<SProject> getByUuid(String uuid) async {
    //SProject item = SProject("", "", "", "", "", "", "", "", "", false, false);
    SProject item = SProject("");
    await dbProject.where("uuid", isEqualTo: uuid).get().then((value) {
      final _doc = value.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      item = SProject.fromJson(data);
    });
    return item;
  }
}

Future<List> getProjects() async {
  List items = [];
  QuerySnapshot queryProject = await dbProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = SProject.fromJson(data);
    try {
      item.typeObj = await item.getProjectType();
      item.managerObj = await item.getManager();
      item.programmeObj = await item.getProgramme();
      item.financiersObj = await item.getFinanciers();
      item.partnersObj = await item.getPartners();
      item.datesObj = await item.getDates();
    } catch (e) {}
    items.add(item);
  }
  return items;
}

Future<List<KeyValue>> getProjectsHash() async {
  List<KeyValue> items = [];
  QuerySnapshot queryProject = await dbProject.get();
  for (var doc in queryProject.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final item = SProject.fromJson(data);
    items.add(item.toKeyValue());
  }
  return items;
}

Future<SProject> getProjectById(String id) async {
  DocumentSnapshot _doc = await dbProject.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return SProject.fromJson(data);
}

Future<SProject?> getProjectByUuid(String _uuid) async {
  QuerySnapshot query = await dbProject.where("uuid", isEqualTo: _uuid).get();
  final _doc = query.docs.first;
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return SProject.fromJson(data);
}

//--------------------------------------------------------------
//                       PROJECT TYPE
//--------------------------------------------------------------
CollectionReference dbProjectType = db.collection("s4c_project_type");

class ProjectType {
  String id = "";
  String uuid = "";
  String name = "";

  ProjectType(this.name);

  ProjectType.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  /*Map<String, String> toKeyValue() => {
        'key': uuid,
        'value': name,
      };*/
  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbProjectType.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProjectType.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProjectType.doc(id).delete();
  }
}

Future<List> getProjectTypes() async {
  List items = [];
  QuerySnapshot queryProjectType = await dbProjectType.get();

  for (var doc in queryProjectType.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ProjectType.fromJson(data);
    items.add(_item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT DATES
//--------------------------------------------------------------
CollectionReference dbDates = db.collection("s4c_project_dates");

class ProjectDates {
  String id = "";
  String uuid = "";
  String approved = "";
  String start = "";
  String end = "";
  String justification = "";
  String delivery = "";
  String project = "";

  ProjectDates(this.project);

  ProjectDates.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        approved = json["approved"],
        start = json["start"],
        end = json["end"],
        justification = json["justification"],
        delivery = json["delivery"],
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'approved': approved,
        'start': start,
        'end': end,
        'justification': justification,
        'delivery': delivery,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbDates.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbDates.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbDates.doc(id).delete();
  }
}

Future<List> getProjectDates() async {
  List items = [];
  QuerySnapshot query = await dbDates.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ProjectDates.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<ProjectDates> getProjectDatesById(String id) async {
  DocumentSnapshot _doc = await dbDates.doc(id).get();
  final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
  data["id"] = _doc.id;
  return ProjectDates.fromJson(data);
}

Future<ProjectDates> getProjectDatesByProject(String _project) async {
  QuerySnapshot query =
      await dbDates.where("project", isEqualTo: _project).get();
  if (query.docs.length == 0) {
    ProjectDates _dates = ProjectDates(_project);
    _dates.save();
    return _dates;
  }
  final _dbResult = query.docs.first;
  final Map<String, dynamic> data = _dbResult.data() as Map<String, dynamic>;
  data["id"] = _dbResult.id;
  return ProjectDates.fromJson(data);
}

//--------------------------------------------------------------
//                       PROJECT LOCATION
//--------------------------------------------------------------
CollectionReference dbLocation = db.collection("s4c_project_location");

class ProjectLocation {
  String id = "";
  String uuid = "";

  String country = "";
  String province = "";
  String region = "";
  String town = "";
  String project = "";
  Country countryObj = Country("");
  Province provinceObj = Province("");
  Region regionObj = Region("");
  Town townObj = Town("");

  ProjectLocation(this.project);

  ProjectLocation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        country = json["country"],
        province = json["province"],
        region = json["region"],
        town = json["town"],
        project = json["project"];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'country': country,
        'province': province,
        'region': region,
        'town': town,
        'project': project,
      };

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbLocation.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbLocation.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbLocation.doc(id).delete();
  }

  Future<Country> getCountry() async {
    try {
      QuerySnapshot query =
          await dbCountry.where("uuid", isEqualTo: country).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Country.fromJson(data);
    } catch (e) {
      return Country("");
    }
  }

  Future<Province> getProvince() async {
    try {
      QuerySnapshot query =
          await dbProvince.where("uuid", isEqualTo: province).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Province.fromJson(data);
    } catch (e) {
      return Province("");
    }
  }

  Future<Region> getRegion() async {
    try {
      QuerySnapshot query =
          await dbRegion.where("uuid", isEqualTo: region).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Region.fromJson(data);
    } catch (e) {
      return Region("");
    }
  }

  Future<Town> getTown() async {
    try {
      QuerySnapshot query = await dbTown.where("uuid", isEqualTo: town).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Town.fromJson(data);
    } catch (e) {
      return Town("");
    }
  }
}

Future<List> getProjectLocation() async {
  List items = [];
  QuerySnapshot query = await dbLocation.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = ProjectLocation.fromJson(data);
    items.add(_item);
  }

  return items;
}

Future<ProjectLocation> getProjectLocationByProject(String _project) async {
  QuerySnapshot query =
      await dbLocation.where("project", isEqualTo: _project).get();

  if (query.docs.length == 0) {
    ProjectLocation _loc = ProjectLocation(_project);
    _loc.save();
    return _loc;
  }

  final _dbResult = query.docs.first;
  final Map<String, dynamic> data = _dbResult.data() as Map<String, dynamic>;
  data["id"] = _dbResult.id;
  ProjectLocation _pl = ProjectLocation.fromJson(data);
  _pl.countryObj = await _pl.getCountry();
  _pl.provinceObj = await _pl.getProvince();
  _pl.regionObj = await _pl.getRegion();
  _pl.townObj = await _pl.getTown();
  return _pl;
}

//--------------------------------------------------------------
//                       PROJECT FINANCIER
//--------------------------------------------------------------
CollectionReference dbFinancier = db.collection("s4c_financier");

class Financier {
  String id = "";
  String uuid = "";
  String name = "";

  Financier(this.name);

  Financier.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var _uuid = Uuid();
      uuid = _uuid.v4();
      Map<String, dynamic> data = toJson();
      dbFinancier.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbFinancier.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbFinancier.doc(id).delete();
  }
}

Future<List> getFinanciers() async {
  List items = [];
  QuerySnapshot queryFinancier = await dbFinancier.get();

  for (var doc in queryFinancier.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Financier.fromJson(data);
    items.add(_item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROJECT REFORMULATION
//--------------------------------------------------------------
CollectionReference dbReformulation =
    db.collection("s4c_project_reformulation");

class Reformulation {
  String id = "";
  String uuid = "";
  String reformulation = "";
  String correction = "";
  String request = "";
  String project = "";
  String financier = "";
  //SProject projectObj = SProject("", "");
  SProject projectObj = SProject("");
  Financier financierObj = Financier("");

  Reformulation(this.project);

  Reformulation.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        reformulation = json['reformulation'],
        correction = json['correction'],
        request = json['request'],
        project = json['project'],
        financier = json['financier'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'reformulation': reformulation,
        'correction': correction,
        'request': request,
        'project': project,
        'financier': financier,
      };

  /*KeyValue toKeyValue() {
    return KeyValue(uuid, reformulation);
  }*/

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbReformulation.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbReformulation.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbReformulation.doc(id).delete();
  }

  Future<SProject> getProject() async {
    try {
      QuerySnapshot query =
          await dbProject.where("uuid", isEqualTo: project).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return SProject.fromJson(data);
    } catch (e) {
      return SProject("");
    }
  }

  Future<Financier> getFinancier() async {
    try {
      QuerySnapshot query =
          await dbFinancier.where("uuid", isEqualTo: financier).get();
      final _doc = query.docs.first;
      final Map<String, dynamic> data = _doc.data() as Map<String, dynamic>;
      data["id"] = _doc.id;
      return Financier.fromJson(data);
    } catch (e) {
      return Financier("");
    }
  }
}

Future<List> getReformulations() async {
  List items = [];
  QuerySnapshot query = await dbReformulation.get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Reformulation.fromJson(data);
    _item.projectObj = await _item.getProject();
    _item.financierObj = await _item.getFinancier();
    items.add(_item);
  }

  return items;
}

Future<List> getReformulationsByProject(uuid) async {
  List items = [];
  QuerySnapshot query =
      await dbReformulation.where("project", isEqualTo: uuid).get();

  for (var doc in query.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Reformulation.fromJson(data);
    _item.projectObj = await _item.getProject();
    _item.financierObj = await _item.getFinancier();
    items.add(_item);
  }

  return items;
}

//--------------------------------------------------------------
//                       PROGRAMME
//--------------------------------------------------------------
CollectionReference dbProgramme = db.collection("s4c_programmes");

class Programme {
  String id = "";
  String uuid = "";
  String name = "";
  String logo = "";
  int projects = 0;

  Programme(this.name);

  Programme.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        uuid = json["uuid"],
        name = json['name'],
        logo = json['logo'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'uuid': uuid,
        'name': name,
        'logo': logo,
      };

  KeyValue toKeyValue() {
    return KeyValue(uuid, name);
  }

  Future<void> save() async {
    if (id == "") {
      var newUuid = Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbProgramme.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbProgramme.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbProgramme.doc(id).delete();
  }

  Future<void> getProjects() async {
    QuerySnapshot query =
        await dbProject.where("programe", isEqualTo: uuid).get();
    projects = query.docs.length;
  }
}

Future<List> getProgrammes() async {
  List items = [];
  QuerySnapshot queryProgramme = await dbProgramme.get();

  for (var doc in queryProgramme.docs) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    final _item = Programme.fromJson(data);
    _item.getProjects();
    items.add(_item);
  }
  return items;
}
