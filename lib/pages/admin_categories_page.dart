import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:sic4change/services/models_contact_info.dart';
import 'package:sic4change/widgets/common_widgets.dart';
import 'package:sic4change/widgets/footer_widget.dart';
import 'package:sic4change/widgets/main_menu_widget.dart';

const categoryTitle = "Categorías";
List categories = [];
bool loadingCategory = false;
Widget? _mainMenu;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage>
    with SingleTickerProviderStateMixin {
  void setLoading() {
    setState(() {
      loadingCategory = true;
    });
  }

  void stopLoading() {
    setState(() {
      loadingCategory = false;
    });
  }

  void loadCategories() async {
    setLoading();
    await getContactCategories().then((val) {
      categories = val;
      stopLoading();
    });
  }

  @override
  initState() {
    super.initState();
    _mainMenu = mainMenu(context);
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(children: [
        _mainMenu!,
        categoryHeader(context),
        loadingCategory
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : categoryList(context),
        footer(context),
      ]),
    ));
  }

/*-------------------------------------------------------------
                            CATEGORIES
-------------------------------------------------------------*/
  Widget categoryHeader(context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        padding: const EdgeInsets.all(20),
        child: customText("CATEGORÍAS", 20,
            textColor: mainColor, bold: FontWeight.bold),
      ),
      Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            addBtn(
                context, editCategoryDialog, {'category': ContactCategory("")}),
            space(width: 10),
            returnBtn(context),
          ],
        ),
      ),
    ]);
  }

  void saveCategory(List args) async {
    ContactCategory category = args[0];
    category.save();
    loadCategories();

    Navigator.pop(context);
  }

  Future<void> editCategoryDialog(context, Map<String, dynamic> args) {
    ContactCategory category = args["category"];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(0),
          title: s4cTitleBar("Categoría"),
          content: SingleChildScrollView(
              child: Column(children: <Widget>[
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomTextField(
                labelText: "Nombre",
                initial: category.name,
                size: 900,
                minLines: 2,
                maxLines: 9999,
                fieldValue: (String val) {
                  setState(() => category.name = val);
                },
              )
            ]),
          ])),
          actions: <Widget>[
            dialogsBtns(context, saveCategory, category),
          ],
        );
      },
    );
  }

  Widget categoryList(context) {
    return Container(
      decoration: tableDecoration,
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          sortColumnIndex: 0,
          showCheckboxColumn: false,
          headingRowColor:
              MaterialStateColor.resolveWith((states) => headerListBgColor),
          headingRowHeight: 40,
          columns: [
            DataColumn(
              label: customText("Nombre", 14,
                  bold: FontWeight.bold, textColor: headerListTitleColor),
            ),
            DataColumn(label: Container()),
          ],
          rows: categories
              .map(
                (category) => DataRow(cells: [
                  DataCell(Text(category.name)),
                  DataCell(
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    editBtn(
                        context, editCategoryDialog, {"category": category}),
                    removeBtn(
                        context, removeCategoryDialog, {"category": category})
                  ]))
                ]),
              )
              .toList(),
        ),
      ),
    );
  }

  void removeCategoryDialog(context, args) {
    customRemoveDialog(context, args["category"], loadCategories, null);
  }
}
