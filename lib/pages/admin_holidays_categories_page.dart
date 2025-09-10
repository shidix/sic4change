import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sic4change/services/form_holiday.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const categoryTitle = "Categorías para vacaciones y permisos";
// List<HolidaysCategory> categories = [];
bool loadingCategory = false;

class AdminHolidaysCategoriesPage extends StatefulWidget {
  AdminHolidaysCategoriesPage({super.key});

  @override
  State<AdminHolidaysCategoriesPage> createState() =>
      _AdminHolidaysCategoriesPageState();
}

class _AdminHolidaysCategoriesPageState
    extends State<AdminHolidaysCategoriesPage> {
  final user = FirebaseAuth.instance.currentUser!;
  List<HolidaysCategory> categories = [];
  Profile? profile;
  Organization? currentOrganization;
  Widget content = const Center(
    child: CircularProgressIndicator(),
  );
  Widget? _mainMenu;
  Widget? _actionsMenu;

  void initializeData() async {
    _mainMenu = mainMenu(context, "/admin/holidays/categories");
    final results = await Future.wait([
      HolidaysCategory.byOrganization(currentOrganization!),
    ]);

    categories = results[0];
    if (mounted) {
      setState(() {
        checkPermissions(
            context, profile!, [Profile.ADMINISTRATIVE, Profile.ADMIN]);
      });
    }
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    _actionsMenu = Container();

    Provider.of<ProfileProvider>(context, listen: false).addListener(() {
      if (!mounted) return;
      currentOrganization =
          Provider.of<ProfileProvider>(context, listen: false).organization;

      profile = Provider.of<ProfileProvider>(context, listen: false).profile;
      if ((profile != null) && (currentOrganization != null)) {
        initializeData();
      }

      if (mounted) setState(() {});
    });

    currentOrganization =
        Provider.of<ProfileProvider>(context, listen: false).organization;
    profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if ((profile == null) || (currentOrganization == null)) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfile();
    } else {
      initializeData();
    }
  }

  Widget editionList(BuildContext context, List<HolidaysCategory> categories) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: categories.length,
      itemBuilder: (context, index) {
        HolidaysCategory category = categories[index];
        return ListTile(
          title: Text("${category.name} [${category.autoCode()}]"),
          subtitle: Text(
              "Días: ${category.days}, Requiere documento: ${(category.docRequired > 0) ? 'Sí' : 'No'} (${category.docRequired}), Retroactivo: ${category.retroactive ? 'Sí' : 'No'}"),
          // trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          //   editBtn(context, editCategory, {'category': category}),
          // ]),
          onTap: () {
            editCategory(context, {'category': category});
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (profile != null && currentOrganization != null) {
      _actionsMenu = Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: customText(categoryTitle, 20,
                  textColor: mainColor, bold: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                addBtn(context, editCategory, {
                  'category': HolidaysCategory.getEmpty(
                      organization: currentOrganization!)
                }),
              ],
            )
          ],
        ),
      );
      categories.isEmpty
          ? content = const Text("No hay categorías disponibles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          : content = Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: editionList(context, categories),
              ),
            );
    }

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        _actionsMenu!,
        content,
        footer(context),
      ]),
    ));
  }

  Widget editionForm(BuildContext context, HolidaysCategory category) {
    return SingleChildScrollView(
        child: SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: HolidaysCategoryForm(
        category: category,
      ),
    ));
  }

  Future<void> editCategory(context, Map<String, dynamic> args) async {
    HolidaysCategory category = args['category'];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: (category.id.isEmpty)
                ? s4cTitleBar(
                    "Nueva categoría", context, Icons.add_circle_outline)
                : s4cTitleBar("Editar categoría", context, Icons.edit),
            content: editionForm(context, category),
          );
        }).then(
      (value) {
        int index = categories.indexWhere((c) => c.id == category.id);
        if (index != -1) {
          categories[index] = category;
        } else {
          categories.add(category);
        }
        setState(() {});
      },
    );
  }
}
