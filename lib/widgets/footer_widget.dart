import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sic4change/build_info.dart';

// generated file

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({Key? key}) : super(key: key);

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  String version = '';
  String buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = info.version; // From pubspec.yaml
      buildNumber = info.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "v$version ($buildNumber) • $gitCommit • $buildDate",
      style: const TextStyle(fontSize: 12, color: Colors.grey),
    );
  }
}

Widget footer(BuildContext context) {
  return Container(
      padding: const EdgeInsets.all(3),
      child: Column(
          // width = 100%
          mainAxisSize: MainAxisSize.max,
          children: [
            space(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                customText('Realizado por:', 15),
                                const Image(
                                  image:
                                      AssetImage('assets/images/logo_s4c.png'),
                                  height: 100,
                                )
                              ]))),
                ),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText('En colaboración con:', 15),
                                  const Image(
                                    image: AssetImage(
                                        'assets/images/logo_ministerio.png'),
                                    height: 100,
                                  )
                                ])))),
                // logo_RTR
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText('Con la colaboración de:', 15),
                                  const Image(
                                    image: AssetImage(
                                        'assets/images/logo_RTR.png'),
                                    height: 100,
                                  )
                                ])))),
                // logo_NGEU
                Expanded(
                    flex: 2,
                    child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Align(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  customText('Con la colaboración de:', 15),
                                  const Image(
                                    image: AssetImage(
                                        'assets/images/logo_NGEU.png'),
                                    height: 100,
                                  )
                                ])))),
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
            space(height: 10),
            AppVersionWidget()
          ]));
}
