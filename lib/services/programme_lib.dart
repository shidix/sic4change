import 'package:googleapis/mybusinessbusinessinformation/v1.dart';
import 'package:sic4change/services/models.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_finn.dart';
import 'package:sic4change/services/models_marco.dart';
import 'package:sic4change/services/utils.dart';

Future<Map<String, double>> getProgrammeFinanciers(projects) async {
  Map<String, double> finMap = {};
  Map<String, String> finUUID = {};
  Map<String, dynamic> finnInfo = {};
  finMap["total"] = 0;

  for (SProject project in projects) {
    List<Organization> finList = await project.getFinanciers();
    project.financiersObj = finList;
    for (Organization financier in finList) {
      finMap[financier.name] = 0;
      finUUID[financier.name] = financier.uuid;
    }
  }

  for (SProject project in projects) {
    print("DBG: ${project.uuid}");
    finnInfo[project.uuid] = await SFinnInfo.byProject(project.uuid);
  }

  finMap.forEach((key, value) async {
    double amount = 0;
    for (SProject project in projects) {
      try {
        amount += finnInfo[project.uuid].getContribByFinancier(finUUID[key]!);
      } catch (e) {}
    }
    finMap[key] = amount;
    finMap["total"] = finMap["total"]! + amount;
    //totalFinancing = totalFinancing + amount;
  });
  return finMap;
}

Map<String, double> setProjectByStatus(projects) {
  Map<String, double> projStatus = {};
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
    projStatus[st] = (total > 0) ? ((projStatus[st]! / total) * 100) : 100;
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

Future<Map<String, double>> getTotalExectuteBudget(projects) async {
  double total = 0;
  Map<String, Map> invoicesSummary = {};
  Map<String, double> totalsExecuted = {};

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

    //proj.partnersObj = await proj.getPartners();
    proj.financiersObj = await proj.getFinanciers();
    //for (Organization partner in proj.partnersObj) {
    for (Organization partner in proj.financiersObj) {
      double executedByPartnerAmount = 0;
      if (invoicesSummary.containsKey(partner.uuid)) {
        executedByPartnerAmount = invoicesSummary[partner.uuid]!['total'];
      }
      total += executedByPartnerAmount;
      totalsExecuted[partner.name] = executedByPartnerAmount;
    }
  }
  totalsExecuted["total"] = total;
  return totalsExecuted;
}

/*Future<double> getTotalExectuteBudget(projects) async {
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
}*/

Future<Map<String, double>> getGoalsPercent(projects) async {
  Map<String, double> goalsPercent = {};
  goalsPercent["total"] = 0;
  for (SProject proj in projects) {
    List goals = await getGoalsByProject(proj.uuid);
    double totalProj = 0;
    int j = 0;
    for (Goal goal in goals) {
      if (goal.name != "OE0") {
        totalProj += await Goal.getIndicatorsPercent(goal.uuid);
        j += 1;
      }
    }
    goalsPercent[proj.uuid] = totalProj / j;
  }

  double total = 0;
  int i = 0;
  goalsPercent.forEach((key, value) {
    total += value;
    i += 1;
  });
  goalsPercent["total"] = total / (i - 1);
  return goalsPercent;
}
