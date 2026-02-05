import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ARBaseModel {
  ARBaseModel();

  String getId() {
    return "";
  }

  void setId(String id);
  String getTbName() {
    return "";
  }

  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> json);
  Future<void> reload();

  // Implement common methods
  Future<void> save() async {
    if (getTbName() == "") {
      throw Exception("Table name is not set");
    }
    if (getId() == "") {
      Map<String, dynamic> data = toJson();
      var item =
          await FirebaseFirestore.instance.collection(getTbName()).add(data);
      setId(item.id);
      save();
    } else {
      Map<String, dynamic> data = toJson();
      await FirebaseFirestore.instance
          .collection(getTbName())
          .doc(getId())
          .set(data);
    }
  }

  Future<void> delete() async {
    if (getTbName() == "") {
      throw Exception("Table name is not set");
    }
    if (getId() != "") {
      await FirebaseFirestore.instance
          .collection(getTbName())
          .doc(getId())
          .delete();
    }
  }

  Future<void> byId<T extends ARBaseModel>([String? idToSearch]) async {
    if (getTbName() == "") {
      throw Exception("Table name is not set");
    }
    if (getId() == "" && (idToSearch == null || idToSearch.isEmpty)) {
      throw Exception("ID is not set");
    }

    idToSearch ??= getId();
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(getTbName())
        .doc(idToSearch)
        .get();
    if (!doc.exists) {
      throw Exception(
          "Document with id $idToSearch does not exist in ${getTbName()}");
    }
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    fromJson(data);
  }

  Future<T> get<T extends ARBaseModel>() async {
    if (getTbName() == "") {
      throw Exception("Table name is not set");
    }
    if (getId() == "") {
      throw Exception("ID is not set");
    }
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(getTbName())
        .doc(getId())
        .get();
    if (!doc.exists) {
      throw Exception(
          "Document with id ${getId()} does not exist in ${getTbName()}");
    }
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;
    fromJson(data);
    return this as T;
  }
}
