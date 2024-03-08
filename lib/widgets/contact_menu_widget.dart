import 'package:flutter/material.dart';
import 'package:sic4change/pages/contact_calendar_page.dart';
import 'package:sic4change/pages/contact_claim_page.dart';
import 'package:sic4change/pages/contact_info_page.dart';
import 'package:sic4change/pages/contact_tracking_page.dart';
import 'package:sic4change/widgets/common_widgets.dart';

Widget contactMenu(context, contact, contactInfo, tabSelected) {
  // bool info = (tabSelected == "info") ? true : false;
  // bool tracking = (tabSelected == "tracking") ? true : false;
  // bool claim = (tabSelected == "claim") ? true : false;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Row(
      children: [
        // menuTab(context, "Info", "/contact_info", {'contact': contact},
        //     selected: info),
        // menuTab(
        //     context, "Seguimiento", "/contact_trackings", {'contact': contact},
        //     selected: tracking),
        //     menuTab(
        // context, "Reclamaciones", "/contact_claims", {'contact': contact},
        // selected: claim),
        menuTab2(context, "Información",
            ContactInfoPage(contact: contact, contactInfo: contactInfo),
            selected: (tabSelected == "info")),
        menuTab2(context, "Seguimiento",
            ContactTrackingPage(contact: contact, contactInfo: contactInfo),
            selected: (tabSelected == "tracking")),
        menuTab2(context, "Reclamaciones",
            ContactClaimPage(contact: contact, contactInfo: contactInfo),
            selected: (tabSelected == "claim")),
        menuTab2(context, "Calendario",
            ContactCalendarPage(contact: contact, contactInfo: contactInfo),
            selected: (tabSelected == "calendar")),
      ],
    ),
  );
}
