import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget contactMenu(context, contact, tabSelected) {
  bool info = (tabSelected == "info") ? true : false;
  bool tracking = (tabSelected == "tracking") ? true : false;
  bool claim = (tabSelected == "claim") ? true : false;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        menuTab(context, "Info", "/contact_info", {'contact': contact},
            selected: info),
        menuTab(
            context, "Seguimiento", "/contact_trackings", {'contact': contact},
            selected: tracking),
        menuTab(
            context, "Reclamaciones", "/contact_claims", {'contact': contact},
            selected: claim),
      ],
    ),
  );
}
