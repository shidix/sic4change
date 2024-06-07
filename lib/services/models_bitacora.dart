import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
FirebaseFirestore db = FirebaseFirestore.instance;

CollectionReference dbBitacora = db.collection("s4c_bitacora");

class Bitacora extends Object{ 
  String id = "";
  String uuid = "";
  String projectUuid = "";
  List<dynamic> summary = [];
  List<dynamic> delays = [];
  List<dynamic> financial = [];
  List<dynamic> technicals = [];
  List<dynamic> fromPartners  = [];
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

  Future<void> save() async {
    if (id == "") {
      var newUuid = const Uuid();
      uuid = newUuid.v4();
      Map<String, dynamic> data = toJson();
      dbBitacora.add(data);
    } else {
      Map<String, dynamic> data = toJson();
      dbBitacora.doc(id).set(data);
    }
  }

  Future<void> delete() async {
    await dbBitacora.doc(id).delete();
  }


  static Future<Bitacora?> byProjectUuid(String uuid) async {
    QuerySnapshot query = await dbBitacora.where("projectUuid", isEqualTo: uuid).get();
    if (!query.docs.isEmpty) {
      var first = query.docs.first;
      return Bitacora.fromJson(first.data()  as Map<String, dynamic>);
    }
    return null;

  }


}


