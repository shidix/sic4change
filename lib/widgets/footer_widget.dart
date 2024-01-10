import 'package:flutter/material.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget footer(context) {
  return Container(
      padding: const EdgeInsets.all(3),
      child: Column(children: [
        space(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.center,
                    child: customText('Realizado por:', 15))),
            Expanded(
                flex: 2,
                child: Align(
                    alignment: Alignment.center,
                    child: customText('En colaboración con:', 15)))
          ],
        ),
        space(height: 10),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage('assets/images/logo_s4c.png'),
                    height: 100,
                  ),
                )),
            Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage('assets/images/logo_ministerio.png'),
                    height: 100,
                  ),
                )),
          ],
        ),
        space(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                flex: 1,
                child: Align(
                    alignment: Alignment.center,
                    child: Text(AppLocalizations.of(context)!.sloganFooter,
                        style: sloganText))),
          ],
        ),
      ]));
}
