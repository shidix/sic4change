import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/utils.dart';

Map<String, int> setProjectByStatus(projects) {
  Map<String, int> projStatus = {};
  List statusList = [
    statusFormulation,
    statusSended,
    statusReject,
    statusRefuse,
    statusApproved,
    statusStart,
    statusEnds,
    statusJustification,
    statusClose,
    statusDelivery
  ];
  for (String st in statusList) {
    projStatus[st] = 0;
  }
  for (SProject p in projects) {
    for (String st in statusList) {
      if (p.status == st) {
        projStatus[st] = projStatus[st]! + 1;
      }
    }
  }
  return projStatus;
}

Future<Map<String, int>> setSourceFinancing(projects) async {
  Map<String, int> sources = {
    'Nacional/Publico': 0,
    'Nacional/Privado': 0,
    'Internacional/Publico': 0,
    'Internacional/Privado': 0
  };
  for (SProject p in projects) {
    await p.getLocation();
    for (Organization org in p.financiersObj) {
      //Nacional
      if (p.locationObj.country == org.country) {
        if (org.public) {
          sources['Nacional/Publico'] = sources['Nacional/Publico']! + 1;
        } else {
          sources['Nacional/Privado'] = sources['Nacional/Privado']! + 1;
        }
      }
      //Internacional
      else {
        if (org.public) {
          sources['Internacional/Publico'] =
              sources['Internacional/Publico']! + 1;
        } else {
          sources['Internacional/Privado'] =
              sources['Internacional/Privado']! + 1;
        }
      }
    }
  }
  return sources;
}

class Organizacion {}

Map<String, int> setProjectByCountry(projects) {
  Map<String, int> projCountry = {};
  for (SProject p in projects) {
    String c = p.locationObj.country;
    if (!projCountry.containsKey(c)) {
      projCountry[c] = 0;
    }
    projCountry[c] = projCountry[c]! + 1;
  }
  return projCountry;
}
