import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/generated/l10n.dart';
import 'package:sic4change/pages/admin_ambits_page.dart';
import 'package:sic4change/pages/rrhh_calendars_page.dart';
import 'package:sic4change/pages/admin_categories_page.dart';
import 'package:sic4change/pages/admin_charge_page.dart';
import 'package:sic4change/pages/admin_companies_page.dart';
import 'package:sic4change/pages/admin_country_page.dart';
import 'package:sic4change/pages/admin_decision_page.dart';
import 'package:sic4change/pages/admin_holidays_categories_page.dart';
import 'package:sic4change/pages/admin_position_page.dart';
import 'package:sic4change/pages/admin_profiles_page.dart';
import 'package:sic4change/pages/admin_project_status_page.dart';
import 'package:sic4change/pages/admin_project_type_page.dart';
import 'package:sic4change/pages/admin_province_page.dart';
import 'package:sic4change/pages/admin_reformulation_status_page.dart';
import 'package:sic4change/pages/admin_reformulation_type_page.dart';
import 'package:sic4change/pages/admin_region_page.dart';
import 'package:sic4change/pages/admin_skateholder_page.dart';
import 'package:sic4change/pages/admin_task_status_page.dart';
import 'package:sic4change/pages/admin_town_page.dart';
import 'package:sic4change/pages/admin_zone_page.dart';
import 'package:sic4change/pages/rrhh_holiday_category_page.dart';
import 'package:sic4change/services/cache_profiles.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';
import 'package:sic4change/widgets/common_widgets.dart';

const adminTitle = "Administración";
Widget? _mainMenu;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key, this.prList});

  final List? prList;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Profile? profile;
  Organization? currentOrganization;

  void initializeData() async {
    _mainMenu = mainMenu(context, "/admin");
    profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    currentOrganization =
        Provider.of<ProfileProvider>(context, listen: false).organization;
    if (profile != null && currentOrganization != null) {
      checkPermissions(
          context, profile!, [Profile.ADMINISTRATIVE, Profile.ADMIN]);
    }
    _mainMenu = mainMenu(context, "/admin");
  }

  @override
  void initState() {
    super.initState();

    Provider.of<ProfileProvider>(context, listen: false).addListener(() {
      if (!mounted) return;
      currentOrganization =
          Provider.of<ProfileProvider>(context, listen: false).organization;

      profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      _mainMenu = mainMenu(context, "/home");
      if ((profile != null) && (currentOrganization != null)) {
        initializeData();
      }

      if (mounted) setState(() {});
    });

    _mainMenu = mainMenu(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mainMenu!,
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "LOCALIZACIÓN")),
          locationList(context),
          space(height: 20),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "CONTACTO")),
          contactList(context),
          space(height: 20),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "INICIATIVAS")),
          projectList(context),
          space(height: 20),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "TAREAS")),
          taskList(context),
          space(height: 20),
          Container(
              padding: const EdgeInsets.all(10),
              child: customTitle(context, "CONFIGURACIÓN")),
          configList(context),
          footer(context),
        ],
      ),
    ));
  }

/*-------------------------------------------------------------
                     MODULES LIST
-------------------------------------------------------------*/
  Widget locationList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          goPage(context, "Zonas", const ZonePage(), Icons.location_city,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(
              context, "Municipios", const TownPage(), Icons.location_history,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Provincias", const ProvincePage(),
              Icons.location_city_sharp,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Comunidades", const RegionPage(),
              Icons.location_city_rounded,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Paises", const CountryPage(),
              Icons.location_city_outlined,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
        ]));
  }

  Widget contactList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          goPage(context, "Perfiles", const AdminProfilesPage(), Icons.man,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Categorías", const CategoryPage(), Icons.category,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Cargos", const ChargePage(), Icons.cabin,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Posiciones", const PositionPage(), Icons.cabin,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Empresas", const CompanyPage(),
              Icons.apartment_outlined,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Capacidad de decisión", const DecisionPage(),
              Icons.deblur,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Skateholders", const StakeholderPage(),
              Icons.skateboarding,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
        ]));
  }

  Widget projectList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          goPage(context, "Estados de reformulación",
              const ReformulationStatusPage(), Icons.read_more, style: "bigBtn",
              extraction: () {
            setState(() {});
          }),
          goPage(context, "Tipos de reformulación",
              const ReformulationTypePage(), Icons.real_estate_agent,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Estados", const ProjectStatusPage(),
              Icons.stacked_bar_chart,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, "Tipos", const ProjectTypePage(), Icons.type_specimen,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          goPage(context, 'Ámbitos', const AdminAmbitsPage(), Icons.map,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
        ]));
  }

  Widget taskList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          goPage(context, "Estados de reformulación", const TaskStatusPage(),
              Icons.task,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
        ]));
  }

  Widget configList(context) {
    return Container(
        padding: const EdgeInsets.only(left: 50, right: 50),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          goPage(context, "Calendarios", const CalendarHolidaysPage(),
              Icons.settings,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
          space(width: 20),
          goPage(context, "Categorías de vacaciones y permisos",
              AdminHolidaysCategoriesPage(), Icons.category, style: "bigBtn",
              extraction: () {
            setState(() {});
          }),
          space(width: 20),
          goPage(context, "Utils", const AdminUtilsPage(), Icons.settings,
              style: "bigBtn", extraction: () {
            setState(() {});
          }),
        ]));
  }
}

class AdminUtilsPage extends StatelessWidget {
  const AdminUtilsPage({super.key});

  void checkHolidayRequests(BuildContext context) async {
    // Lógica para comprobar las solicitudes de vacaciones
    List<SNotification> notifications = await SNotification.byObjType(
        'S4C_HOLIDAYS',
        senders: ['cparedes@sic4change.org']);
    List<HolidaysCategory> categories = await HolidaysCategory.getAll();
    List<SNotification> invalidNotifications = [];
    List<String> modifiedRequests = [];
    for (var notification in notifications) {
      if (modifiedRequests.contains(notification.objId)) {
        continue;
      }
      String categoryName = notification.msg
          .split("categoría: ")[1]
          .split(", Estado: ")[0]
          .trim();

      if (categoryName.contains('PR-')) {
        categoryName = categoryName.replaceAll('PR-', 'PR25-');
      }
      HolidaysCategory category = categories.firstWhere(
          (cat) => cat.name == categoryName,
          orElse: () => HolidaysCategory.getEmpty());
      if (category.id.isEmpty) {
        categoryName = "PR25-$categoryName";
        category = categories.firstWhere((cat) => cat.name == categoryName,
            orElse: () => HolidaysCategory.getEmpty());
      }
      if (category.id.isEmpty) {
        invalidNotifications.add(notification);
        print("INVALID: ${notification.msg}");
      } else {
        print("VALID: ${notification.msg}");
        if (notification.objId.isEmpty) {
          continue;
        }
        HolidayRequest? request = await HolidayRequest.byId(notification.objId);
        if (request.id == notification.objId) {
          request.category = category.id;
          print(
              "\tModifying Request ${request.id} - Category: ${category.name}");
          await request.save();
          modifiedRequests.add(request.id);
        }
      }
    }
    print(
        "Total Notifications: ${notifications.length}  Invalid Notifications: ${invalidNotifications.length}");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [
      backButton(context),
      gralBtnRow(context, checkHolidayRequests, null,
          text: "Comprobar solicitudes de vacaciones"),
    ];

    int ButtonsPerRow = 5;
    List<Widget> arrangedButtons = [];
    for (int i = 0; i < buttons.length; i += ButtonsPerRow) {
      arrangedButtons.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: buttons
            .sublist(
                i,
                i + ButtonsPerRow > buttons.length
                    ? buttons.length
                    : i + ButtonsPerRow)
            .map((button) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: button,
                ))
            .toList(),
      ));
    }

    return Column(
      children: arrangedButtons,
    );
  }
}
