import 'package:googleapis/mybusinessbusinessinformation/v1.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_marco.dart';
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
    statusDelivery,
  ];
  for (String st in statusList) {
    projStatus[st] = 0;
  }
  int total = 0;
  for (SProject p in projects) {
    for (String st in statusList) {
      if (p.status == st) {
        projStatus[st] = (projStatus[st]! + 1);
        total += 1;
      }
    }
  }
  for (String st in statusList) {
    projStatus[st] = ((projStatus[st]! / total) * 100) as int;
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
  int total = 0;
  for (SProject p in projects) {
    await p.getLocation();
    for (Organization org in p.financiersObj) {
      //Nacional
      if (p.locationObj.country == org.country) {
        if (org.public) {
          sources['Nacional/Publico'] = sources['Nacional/Publico']! + 1;
          total += 1;
        } else {
          sources['Nacional/Privado'] = sources['Nacional/Privado']! + 1;
          total += 1;
        }
      }
      //Internacional
      else {
        if (org.public) {
          sources['Internacional/Publico'] =
              sources['Internacional/Publico']! + 1;
          total += 1;
        } else {
          sources['Internacional/Privado'] =
              sources['Internacional/Privado']! + 1;
          total += 1;
        }
      }
    }
  }
  sources['Nacional/Publico'] =
      ((sources['Nacional/Publico']! / total) * 100) as int;
  sources['Nacional/Privado'] =
      ((sources['Nacional/Privado']! / total) * 100) as int;
  sources['Internacional/Publico'] =
      ((sources['Internacional/Publico']! / total) * 100) as int;
  sources['Internacional/Privado'] =
      ((sources['Internacional/Privado']! / total) * 100) as int;
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

Future<double> getTotalExectuteBudget(projects) async {
  double total = 0;
  Map<String, Map> invoicesSummary = {};

  for (SProject proj in projects) {
    List distribItems = await Distribution.byProject(proj.uuid);

    for (Distribution dist in distribItems) {
      if (!invoicesSummary.containsKey(dist.partner.uuid)) {
        invoicesSummary[dist.partner.uuid] = {};
      }

      if (!invoicesSummary[dist.partner.uuid]!.containsKey('total')) {
        invoicesSummary[dist.partner.uuid]!['total'] = 0;
      }

      for (var item in dist.mapinvoices.values) {
        InvoiceDistrib inv = InvoiceDistrib.fromJson(item);
        invoicesSummary[dist.partner.uuid]!['total'] += (inv.amount);
      }
    }

    proj.partnersObj = await proj.getPartners();
    for (Organization partner in proj.partnersObj) {
      double executedByPartnerAmount = 0;
      if (invoicesSummary.containsKey(partner.uuid)) {
        executedByPartnerAmount = invoicesSummary[partner.uuid]!['total'];
      }
      total += executedByPartnerAmount;
    }
  }
  return total;
}

Future<double> getGoalsMedia(projects) async {
  double total = 0;
  int i = 0;
  for (SProject proj in projects) {
    List goals = await getGoalsByProject(proj.uuid);
    for (Goal goal in goals) {
      if (goal.name != "OE0") {
        total += await Goal.getIndicatorsPercent(goal.uuid);
        i += 1;
      }
    }
  }
  return total / i;
}
