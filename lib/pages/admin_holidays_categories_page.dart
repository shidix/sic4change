import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sic4change/services/holiday_form.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_holidays.dart';
import 'package:sic4change/services/models_profile.dart';
import 'package:sic4change/services/utils.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const categoryTitle = "Categorías para vacaciones y permisos";
List categories = [];
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
  Profile? profile;
  Organization? currentOrganization;
  Widget content = const Center(
    child: CircularProgressIndicator(),
  );
  Widget? _mainMenu;
  Widget? _actionsMenu;

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    _actionsMenu = Container();

    if (profile == null) {
      Profile.getProfile(user.email!).then((value) {
        profile = value;

        if (mounted) {
          checkPermissions(
              context, profile!, [Profile.ADMINISTRATIVE, Profile.ADMIN]);
          setState(() {});
        }
      });
    }

    if (currentOrganization == null) {
      Organization.byDomain(user.email!).then((value) {
        currentOrganization = value;
        if (mounted) {
          setState(() {});
        }
      });
    }

    _mainMenu = mainMenu(context);
  }

  void listCategories() {
    if (currentOrganization != null) {
      HolidaysCategory.byOrganization(currentOrganization!).then((value) {
        categories = value;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile != null && currentOrganization != null) {
      HolidaysCategory.byOrganization(currentOrganization!).then((value) {
        categories = value;
        if (mounted) {
          setState(() {});
        }
      });
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
          : content = ListView.builder(
              shrinkWrap: true,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                HolidaysCategory category = categories[index];
                return ListTile(
                  title: Text(category.name),
                  subtitle: Text(
                      "Días: ${category.days}, Requiere documento: ${category.docRequired ? 'Sí' : 'No'}, Retroactivo: ${category.retroactive ? 'Sí' : 'No'}"),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    editBtn(context, editCategory, {'category': category}),
                  ]),
                  onTap: () {
                    editCategory(context, {'category': category});
                  },
                );
              },
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
      child: HolidaysCategoryForm(
        category: category,
      ),
    );
  }

  Future<void> editCategory(context, Map<String, dynamic> args) async {
    HolidaysCategory category = args['category'];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            titlePadding: const EdgeInsets.all(0),
            title: s4cTitleBar(
                category.id.isEmpty ? "Nueva categoría" : "Editar categoría"),
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
