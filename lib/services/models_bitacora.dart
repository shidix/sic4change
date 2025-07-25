import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sic4change/services/logs_lib.dart';
import 'package:sic4change/services/models.dart';
import 'package:uuid/uuid.dart';

class Bitacora extends Object {
  String id = "";
  String uuid = "";
  String projectUuid = "";
  List<dynamic> summary = [];
  List<dynamic> delays = [];
  List<dynamic> financial = [];
  List<dynamic> technicals = [];
  List<dynamic> fromPartners = [];
  List<dynamic> others = [];

  Bitacora(this.projectUuid);

  static Bitacora fromJson(Map<String, dynamic> json) {
    Bitacora item = Bitacora(json['projectUuid']);
    item.id = json["id"];
    item.uuid = json["uuid"];
    item.summary = json['summary'];
    item.delays = json['delays'];
    item.financial = json['financial'];
    item.technicals = json['technicals'];
    item.fromPartners = json['fromPartners'];
    item.others = json['others'];
    return item;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'projectUuid': projectUuid,
      'summary': summary,
      'delays': delays,
      'financial': financial,
      'technicals': technicals,
      'fromPartners': fromPartners,
      'others': others,
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }

  Future<void> save() async {
    final dbBitacora = FirebaseFirestore.instance.collection("s4c_bitacora");
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbBitacora.add(data);
      createLog(
          "Creada bitácora en la iniciativa '${SProject.getProjectName(projectUuid)}'");
    } else {
      Map<String, dynamic> data = toJson();
      dbBitacora.doc(id).set(data);
      createLog(
          "Modificada bitácora en la iniciativa '${SProject.getProjectName(projectUuid)}'");
    }
  }

  Future<void> delete() async {
    final dbBitacora = FirebaseFirestore.instance.collection("s4c_bitacora");
    await dbBitacora.doc(id).delete();
    createLog(
        "Borrada bitácora en la iniciativa '${SProject.getProjectName(projectUuid)}'");
  }

  static Future<Bitacora?> byProjectUuid(String uuid) async {
    final dbBitacora = FirebaseFirestore.instance.collection("s4c_bitacora");
    QuerySnapshot query =
        await dbBitacora.where("projectUuid", isEqualTo: uuid).get();
    if (query.docs.isNotEmpty) {
      var first = query.docs.first;
      Bitacora item = Bitacora.fromJson(first.data() as Map<String, dynamic>);
      item.id = first.id;
      return item;
    }
    return null;
  }
}
