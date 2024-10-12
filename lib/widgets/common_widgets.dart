// ignore_for_file: unused_import, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
//import 'package:pdf/widgets.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:sic4change/services/models_workday.dart';
import 'package:sic4change/services/utils.dart';
// import 'package:sic4change/pages/project_transversal_page.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:sic4change/services/models_commons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget customTitle(context, _text) {
  return Container(
      width: MediaQuery.of(context).size.width,
      color: const Color(0xffe5f2d7),
      padding: const EdgeInsets.all(10),
      child: Text(
        _text,
        style: const TextStyle(fontSize: 16, color: Color(0xff00594f)),
        textAlign: TextAlign.center,
      ));
}

Widget menuBtn(context, btnName, btnIcon, btnRoute,
    {Color color = Colors.black38, String currentUrl = ""}) {
  if ((currentUrl == "") || (currentUrl != btnRoute)) {
    return FilledButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, btnRoute);
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        side: const BorderSide(width: 0, color: Color(0xff00594f)),
        backgroundColor: bgColor,
        //primary: Colors.purple),
      ),
      child: Column(
        children: [
          Icon(btnIcon, color: color),
          Text(
            btnName,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  } else {
    return menuBtnSelected(context, btnName, btnIcon);
  }
}

Widget menuBtnSelected(context, btnName, btnIcon) {
  Widget child = Column(
    children: [
      Icon(btnIcon, color: mainMenuBtnSelectedColor),
      Text(
        btnName,
        style: TextStyle(color: mainMenuBtnSelectedColor, fontSize: 14),
      ),
    ],
  );

  return FilledButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
        side: const BorderSide(width: 0, color: Color(0xff00594f)),
        backgroundColor: bgColor,
        //primary: Colors.purple),
      ),
      child: child);
}

Widget menuBtnGo(context, btnName, newContext, btnIcon, btnRoute,
    {String? currentUrl, Function? extraction}) {
  Color color = mainMenuBtnColor;
  bool isCurrent = ((currentUrl != null) && (currentUrl == btnRoute));
  if (isCurrent) {
    color = mainMenuBtnSelectedColor;
    return menuBtnSelected(context, btnName, btnIcon);
  } else {
    Widget child = Column(
      children: [
        Icon(btnIcon, color: color),
        Text(
          btnName,
          style: TextStyle(color: color, fontSize: 14),
        ),
      ],
    );

    return FilledButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: ((context) => newContext),
                  settings: RouteSettings(name: btnRoute)));
          extraction?.call();
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          side: const BorderSide(width: 0, color: Color(0xff00594f)),
          backgroundColor: bgColor,
          //primary: Colors.purple),
        ),
        child: child);
  }
}

Widget menuTabSelect(context, btnName, btnRoute, args) {
  return Container(
      padding: const EdgeInsets.all(5),
      decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
            left: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
            right: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
            bottom: BorderSide(width: 0, color: Color(0xffdfdfdf)),
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          color: Colors.white),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
        },
        child: Text(
          btnName,
          style: const TextStyle(color: Color(0xff00809a), fontSize: 16),
        ),
      ));
}

Widget logoutBtn(context, btnName, btnIcon) {
  return FilledButton(
    onPressed: () {
      User user = FirebaseAuth.instance.currentUser!;
      Workday.currentByUser(user.email!).then((value) {
        if ((value != null) && (value.open)) {
          value.endDate = DateTime.now();
          value.open = false;
          value.save();
        }
      });
      FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/');
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      side: const BorderSide(width: 0, color: Color(0xff00594f)),
      backgroundColor: bgColor,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(btnIcon, color: Colors.white54),
        Text(
          btnName,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
      ],
    ),
  );
}

/*Widget customBtn(context, btnName, btnIcon, btnRoute) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute);
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}*/

//Widget customBtnArgs(context, btnName, btnIcon, btnRoute, args) {
Widget customBtn(context, btnName, btnIcon, btnRoute, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customPushBtn(context, btnName, btnIcon, btnRoute, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, btnRoute, arguments: args);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customRowBtn(context, btnName, btnIcon, btnRoute, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
      //Navigator.pushNamed(context, btnRoute, arguments: {"currentFolder": "1"});
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Row(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customRowPopBtn(context, btnName, btnIcon) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Row(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customRowExternalBtn(context, btnName, btnIcon, btnRoute) {
  return ElevatedButton(
    onPressed: () {
      js.context.callMethod('open', [btnRoute]);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Row(
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customRowFileBtn(context, btnName, btnLoc, btnIcon, btnRoute) {
  return ElevatedButton(
    onPressed: () {
      js.context.callMethod('open', [btnRoute]);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          btnIcon,
          color: Colors.black54,
          size: 30,
        ),
        space(width: 10),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            btnName,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
          space(height: 5),
          Text(
            btnLoc,
            style: const TextStyle(color: Colors.black, fontSize: 14),
          ),
        ])
      ],
    ),
  );
}

Widget customTextField(_controller, _hint, {size = 220}) {
  return SizedBox(
    width: size,
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: _hint,
      ),
    ),
  );
}

Widget customDoubleField(_controller, _hint) {
  return SizedBox(
    width: 220,
    child: TextField(
        controller: _controller,
        //decoration: new InputDecoration(labelText: _hint),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r"[0-9.]"))
        ]),
  );
}

Widget customAutocompleteField(_controller, _options, _hint, {width = 220}) {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();

  return Column(children: [
    SizedBox(
      width: width,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: _hint,
        ),
        onFieldSubmitted: (String value) {
          RawAutocomplete.onFieldSubmitted<String>(_autocompleteKey);
        },
      ),
    ),
    SizedBox(
      width: 250,
      child: RawAutocomplete<String>(
        key: _autocompleteKey,
        focusNode: _focusNode,
        textEditingController: _controller,
        optionsBuilder: (TextEditingValue textEditingValue) {
          return _options.where((String option) {
            return option.contains(textEditingValue.text.toLowerCase());
          }).toList();
        },
        optionsViewBuilder: (
          BuildContext context,
          AutocompleteOnSelected<String> onSelected,
          Iterable<String> options,
        ) {
          return Material(
            elevation: 4.0,
            child: ListView(
              children: options
                  .map((String option) => GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option),
                        ),
                      ))
                  .toList(),
            ),
          );
        },
      ),
    ),
  ]);
}

Widget customDropdownField(controller, options, current, hint, {width = 220}) {
  return SizedBox(
      width: width,
      child: DropdownSearch<KeyValue>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
          //disabledItemFn: (String s) => s.startsWith('I'),
        ),
        //items: ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
        items: options,
        itemAsString: (KeyValue p) => p.value,
        compareFn: (i1, i2) => i1.key == i2.key,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            //labelText: "Menu mode",
            hintText: hint,
          ),
        ),
        onChanged: (val) {
          controller.text = val?.key;
        },
        selectedItem: current,
      ));
}

Widget customLinearPercent(context, _offset, _percent, _color) {
  var _percentText = _percent * 100;
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    LinearPercentIndicator(
      width: MediaQuery.of(context).size.width / _offset,
      animation: true,
      lineHeight: 10.0,
      animationDuration: 500,
      percent: _percent,
      //center: Text(_percentText.toString()),
      //linearStrokeCap: LinearStrokeCap.roundAll,
      progressColor: _color,
    ),
    space(height: 5),
    Container(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          "$_percentText % Completado",
          style: const TextStyle(fontSize: 12),
        ))
  ]);
}

Widget customList(_list) {
  return ListView.builder(
      //padding: const EdgeInsets.all(8),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.all(5),
          child: Text('Entry ${_list[index]}'),
        );
      });
}

ButtonStyle buttonEditableTextStyle() {
  return ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    backgroundColor: Colors.white,
  );
}

Text buttonEditableText(String textButton) {
  return Text(textButton,
      textAlign: TextAlign.center,
      style:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey));
}

Widget customRowDivider() {
  return const Divider(
    height: 2,
    color: Colors.grey,
  );
}

Widget customColumnDivider() {
  return VerticalDivider(
    width: 10,
    color: greyColor,
  );
}

Widget customRowDividerBlue() {
  return const Divider(
    height: 1,
    color: Color(0xff00809a),
  );
}

Widget backButton(context) {
  return actionButtonVertical(context, "Volver", (context) {
    Navigator.pop(context);
  }, Icons.arrow_circle_left_outlined, context);
}

Widget actionButton(
    context, String? text, Function action, IconData? icon, dynamic args,
    {Color textColor = Colors.black54,
    Color iconColor = Colors.black54,
    double size = 30,
    double hPadding = 20.0,
    double vPadding = 20.0}) {
  icon ??= Icons.settings;
  Widget? row;
  if (text != null) {
    List<Widget> children = [];
    children.add(Icon(
      icon,
      color: iconColor,
      size: size,
    ));

    children.add(space(width: 10));
    children.add(Text(
      text,
      style: TextStyle(color: textColor, fontSize: 14),
    ));
    row = Row(children: children);
  } else {
    row = Icon(
      icon,
      color: iconColor,
      size: size,
    );
  }

  return ElevatedButton(
    onPressed: () {
      if (args == null) {
        action();
      } else {
        action(args);
      }
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(color: Color(0xff8fbc8f))),
      backgroundColor: Colors.white,
    ),
    child: row,
  );
}

Widget actionButtonVertical(
    context, dynamic text, Function action, IconData? icon, dynamic args,
    {Color textColor = Colors.black54, Color iconColor = Colors.black54}) {
  icon ??= Icons.settings;
  Widget textWidget;
  if (text is String) {
    textWidget = customText(text, 12, textColor: subTitleColor);
  } else if (text is Widget) {
    textWidget = text;
  } else {
    textWidget = const SizedBox(width: 0);
  }
  return ElevatedButton(
    onPressed: () {
      if (args == null) {
        action();
      } else {
        action(args);
      }
    },
    style: btnStyle,
    child: Column(
      children: [
        space(height: 5),
        Icon(icon, color: subTitleColor),
        space(height: 5),
        textWidget,
        space(height: 5),
      ],
    ),
  );
}

Widget customCheckBox(label, state, action) {
  return Row(
    children: [
      Checkbox(
        value: state,
        onChanged: (bool? value) {
          action(value);
        },
      ),
      Text(label)
    ],
  );
}

class CardRounded extends Card {
  CardRounded({super.key, Widget? child, Color? color, EdgeInsets? padding})
      : super(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    topRight: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5))),
            color: color ?? Colors.white,
            child: Padding(
                padding: padding ?? const EdgeInsets.all(10), child: child));
}

Map StatusColors = {
  "PENDIENTE": Colors.orange,
  "EN PROCESO": Colors.blue,
  "COMPLETADO": Colors.green,
  "CANCELADO": Colors.red,
  "RECHAZADO": Colors.red,
  "ACEPTADO": Colors.green,
  "ACTIVO": Colors.green,
  "INACTIVO": Colors.red,
  "SIN INICIAR": Colors.orange,
  "SIN APROBAR": Colors.orange,
  "FINALIZADO": Colors.green,
  "": Colors.grey,
};

TextStyle statusText(
    [fontSize = 14, color = Colors.white, fontWeight = FontWeight.normal]) {
  return TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color);
}

TextStyle percentText = const TextStyle(
    fontFamily: 'Readex Pro',
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.bold);

Padding statusCard(String text, [TextStyle? fgstyle, Color? bgcolor]) {
  fgstyle ??= statusText();
  if (bgcolor == null) {
    if (StatusColors.containsKey(text.toUpperCase())) {
      bgcolor = StatusColors[text.toUpperCase()];
    } else {
      bgcolor = Colors.grey;
    }
  }
  return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Card(
          color: bgcolor,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                text,
                style: fgstyle,
                textAlign: TextAlign.center,
              ))));
}

//--------------------------------------------------------------------------
//                              TEXTS
//--------------------------------------------------------------------------
const String addText = "Añadir";
const String cancelText = "Cancelar";
const String editText = "Modificar";
const String removeConfirm =
    "¿Está seguro/a de que desea borrar este elemento?";
const String removeText = "Borrar";
const String returnText = "Volver";
const String saveText = "Guardar";

const String nameText = "Nombre";
const String descText = "Descripción";

//--------------------------------------------------------------------------
//                              STYLES
//--------------------------------------------------------------------------

const Color titleColor = Colors.black;
const TextStyle titleText = TextStyle(
  fontFamily: 'Readex Pro',
  color: titleColor,
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

//Color titleColor = Color(0xff008099);
Color greyColor = const Color(0xffdfdfdf);
//Color bgColor = const Color(0xffe5f2d7);
Color bgColor = const Color(0xff00594f);
Color mainMenuBtnSelectedColor = Colors.white;
Color mainMenuBtnColor = Colors.white54;
Color blueColor = const Color(0Xff00809a);

const Color percentBarPrimary = Color(0xffabf100);

// const Color mainColor = Color(0xFF00809A);
// const Color mainColor = Color(0xffabf100);
const Color mainColor = Color(0xff00594f);
const TextStyle mainText = TextStyle(
  fontFamily: 'Readex Pro',
  color: mainColor,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const Color secondaryColor = successColor;
const TextStyle secondaryText = TextStyle(
  fontFamily: 'Readex Pro',
  color: secondaryColor,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const Color normalColor = Colors.black;
const TextStyle normalText = TextStyle(
  fontFamily: 'Readex Pro',
  color: normalColor,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

const Color fieldColor = Color(0xFF757575);
const TextStyle fieldStyle = TextStyle(
  fontFamily: 'Readex Pro',
  color: fieldColor,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

TextStyle sloganText =
    normalText.copyWith(fontSize: 20, fontWeight: FontWeight.bold);

const TextStyle headerTitleText = TextStyle(
  fontFamily: 'Readex Pro',
  color: normalColor,
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

const Color smallColor = Colors.grey;
const TextStyle smallText = TextStyle(
  fontFamily: 'Readex Pro',
  color: smallColor,
  fontSize: 12,
  fontWeight: FontWeight.normal,
);

const Color cardHeaderColor = Color(0xffabf100);
const TextStyle cardHeaderText = TextStyle(
  fontFamily: 'Readex Pro',
  color: cardHeaderColor,
  fontSize: 16,
  fontWeight: FontWeight.bold,
);

const Color headerListBgColor = Color(0xffe5f2d7);
const Color headerListBgColorResult = Color(0xffb8cda1);
const Color headerListBgColorIndicator = Color(0xff81b8ac);
const Color headerListBgColorActivity = Color(0xffc6e1f6);
const Color headerListColor = Color(0xff0b0b0b);
const Color cellsListColor = Color(0xff0b0b0b);
const Color headerListTitleColor = Color(0xff327971);

const TextStyle headerListStyle = TextStyle(
  fontFamily: 'Readex Pro',
  color: headerListColor,
  fontSize: 15,
  fontWeight: FontWeight.bold,
);

const TextStyle cellsListStyle = TextStyle(
  fontFamily: 'Readex Pro',
  color: cellsListColor,
  fontSize: 14,
  fontWeight: FontWeight.normal,
);

//headerTitleText.copyWith(fontSize: 14);

const Color subTitleColor = Colors.black45;
const TextStyle subTitleText =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: subTitleColor);

const Color dangerColor = Colors.red;
const TextStyle dangerText =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dangerColor);

const Color warningColor = Colors.orange;
const TextStyle warningText =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: warningColor);

const Color successColor = Colors.green;
const TextStyle successText =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: successColor);

ButtonStyle btnStyle = ButtonStyle(
  backgroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
  shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
  elevation: const WidgetStatePropertyAll<double>(5),
);

ButtonStyle btnStylePlane = const ButtonStyle(
  backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
  elevation: WidgetStatePropertyAll<double>(1),
);

BoxDecoration rowDecoration = const BoxDecoration(
  border: Border(bottom: BorderSide(color: Color(0xffdfdfdf), width: 1)),
);

BoxDecoration rowDecorationGreen = const BoxDecoration(
  border: Border(bottom: BorderSide(color: Color(0xff00594f), width: 2)),
);

BoxDecoration tableDecoration = BoxDecoration(
  //border: Border.all(color: Color(0xff999999), width: 1),
  border: Border.all(color: const Color(0xffaaaaaa), width: 1),
  borderRadius: const BorderRadius.all(Radius.circular(5)),
);

BoxDecoration multiSelectDecoration = BoxDecoration(
  color: Colors.blue.withOpacity(0.1),
  borderRadius: const BorderRadius.all(Radius.circular(40)),
  border: Border.all(
    color: mainMenuBtnColor,
    width: 2,
  ),
);

BoxDecoration homePanelDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey[300]!),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.5),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 3), // changes position of shadow
      ),
    ],
    borderRadius: BorderRadius.circular(10));

//--------------------------------------------------------------------------
//                           COMMONS
//--------------------------------------------------------------------------
Widget space({width = 10, height = 10}) {
  return SizedBox(
    width: width,
    height: height,
  );
}

Widget customText(_text, _size,
    {textColor = Colors.black,
    bold = FontWeight.normal,
    align = TextAlign.start}) {
  return Text(
    _text,
    textAlign: align,
    style: TextStyle(fontSize: _size, color: textColor, fontWeight: bold),
  );
}

SizedBox s4cSubTitleBar(dynamic title, [context, icon]) {
  Widget closeButton = const SizedBox(width: 0);
  if (context != null) {
    closeButton = IconButton(
      icon: const Icon(Icons.close),
      color: Colors.white,
      iconSize: 20,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget titleWidget = const SizedBox(width: 0);
  if (title is String) {
    titleWidget = Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
  } else if (title is Widget) {
    titleWidget = title;
  } else {
    titleWidget = const SizedBox(width: 0);
  }

  Widget iconWidget = const SizedBox(width: 0);
  if (icon != null) {
    iconWidget = Icon(icon, color: Colors.white);
  }
  return SizedBox(
      width: double.infinity,
      child: Container(
          // shape: const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //         topLeft: Radius.circular(5),
          //         topRight: Radius.circular(5),
          //         bottomLeft: Radius.circular(5),
          //         bottomRight: Radius.circular(5))),
          color: mainColor,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(flex: (icon == null) ? 0 : 1, child: iconWidget),
                Expanded(flex: 9, child: titleWidget),
                Expanded(flex: 1, child: closeButton)
              ]))));
}

SizedBox s4cTitleBar(dynamic title, [context, icon]) {
  Widget closeButton = const SizedBox(width: 0);
  if (context != null) {
    closeButton = IconButton(
      icon: const Icon(Icons.close),
      color: Colors.white,
      iconSize: 20,
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  Widget titleWidget = const SizedBox(width: 0);
  if (title is String) {
    titleWidget = Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white));
  } else if (title is Widget) {
    titleWidget = title;
  } else {
    titleWidget = const SizedBox(width: 0);
  }

  Widget iconWidget = const SizedBox(width: 0);
  if (icon != null) {
    iconWidget = Icon(icon, color: Colors.white);
  }
  return SizedBox(
      width: double.infinity,
      child: Card(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5))),
          color: mainColor,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(children: [
                Expanded(flex: (icon == null) ? 0 : 1, child: iconWidget),
                Expanded(flex: 9, child: titleWidget),
                Expanded(flex: 1, child: closeButton)
              ]))));
}

Expanded headerCell(
    {int flex = 1, String text = '', TextAlign textAlign = TextAlign.start}) {
  return Expanded(
      flex: flex,
      child: Text(
        text,
        style: headerListStyle,
        textAlign: textAlign,
      ));
}

Expanded listCell(
    {int flex = 1, dynamic text = '', TextAlign textAlign = TextAlign.start}) {
  return Expanded(
      flex: flex,
      child:
          //check type of text
          (text is String)
              ? Text(
                  text,
                  style: cellsListStyle,
                  textAlign: textAlign,
                )
              : text);
}

//--------------------------------------------------------------------------
//                           BUTTONS
//--------------------------------------------------------------------------

Widget goPage(context, btnName, newContext, icon, {style = "", extraction}) {
  Widget child = Column(
    children: [
      space(height: 5),
      Icon(icon, color: newContext == null ? Colors.black : subTitleColor),
      space(height: 5),
      customText(btnName, 12,
          textColor: newContext == null ? Colors.black : subTitleColor),
      space(height: 5),
    ],
  );
  if (style == "bigBtn") {
    style = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
      //primary: Colors.purple),
    );
    child = Column(
      children: [
        Icon(
          icon,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          btnName,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    );
  }
  return ElevatedButton(
      onPressed: () {
        if (newContext != null) {
          // try {
          //   Navigator.of(context).pop();
          // } catch (e) {}
          // ;
          Navigator.push(
              context, MaterialPageRoute(builder: ((context) => newContext)));
        }
        if ((extraction != null) && (extraction is Function)) {
          extraction.call();
        }
      },
      style: (style == "") ? btnStyle : style,
      child: child);
}

Widget goPageDoc(context, btnName, newContext, icon, {style, extraction}) {
  Widget child = Container(
      width: 250,
      height: 50,
      child: Row(
        children: [
          Icon(icon, color: subTitleColor),
          space(width: 5),
          customText(btnName, 12, textColor: subTitleColor),
        ],
      ));
  return ElevatedButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => newContext)));
        extraction?.call();
      },
      style: btnStyle,
      child: child);
}

Widget goPageIcon(context, btnText, icon, newContext,
    {iconSize = 20, Function? callback}) {
  return IconButton(
      icon: Icon(
        icon,
        size: iconSize,
      ),
      tooltip: btnText,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => newContext)));
        callback?.call();
      });
}

Widget gralButton(context, action, args, text, {icon = Icons.settings}) {
  return FilledButton(
      onPressed: () {
        if (args == null) {
          action(context);
        } else {
          action(context, args);
        }
      },
      style: btnStyle,
      child: Column(
        children: [
          space(height: 5),
          Icon(icon, color: subTitleColor),
          space(height: 5),
          customText(text, 12, textColor: subTitleColor),
          space(height: 5),
        ],
      ));
}

Widget addBtn(context, action, args, {text = addText, icon = Icons.add}) {
  return FilledButton(
      onPressed: () {
        if (args == null) {
          action(context);
        } else {
          action(context, args);
        }
      },
      style: btnStyle,
      child: Column(
        children: [
          space(height: 5),
          Icon(icon, color: subTitleColor),
          space(height: 5),
          customText(text, 12, textColor: subTitleColor),
          space(height: 5),
        ],
      ));
}

Widget gralBtnRow(context, action, args,
    {text = 'Tool', icon = Icons.settings, color = subTitleColor}) {
  return FilledButton(
      onPressed: () {
        if (args == null) {
          action(context);
        } else {
          action(context, args);
        }
      },
      style: btnStylePlane,
      child: Row(
        children: [
          Icon(icon, color: color),
          space(width: 5),
          customText(text, 12, textColor: color),
        ],
      ));
}

Widget addBtnRow(context, action, args,
    {text = addText, icon = Icons.add, color = subTitleColor}) {
  return gralBtnRow(context, action, args,
      text: text, icon: icon, color: color);
}

Widget listBtn(context, action, args,
    {text = 'Listado', icon = Icons.list, iconSize = 20}) {
  return IconButton(
    icon: Icon(
      icon,
      size: iconSize,
    ),
    tooltip: text,
    onPressed: () {
      action(context, args);
    },
  );
}

Widget editBtn(context, action, args,
    {text = editText, icon = Icons.edit, iconSize = 20}) {
  return IconButton(
    icon: Icon(
      icon,
      size: iconSize,
    ),
    tooltip: text,
    onPressed: () {
      action(context, args);
    },
  );
}

Widget iconBtn(context, action, args,
    {text = '', icon = Icons.info, iconSize = 20, color = Colors.black}) {
  return IconButton(
    icon: Icon(icon, size: iconSize, color: color),
    tooltip: text,
    onPressed: () {
      if (args != null) {
        action(context, args);
      } else {
        action(context);
      }
    },
  );
}

Widget iconBtnConfirm(context, action, args,
    {text = '', icon = Icons.info, iconSize = 20, color = Colors.black}) {
  return IconButton(
    icon: Icon(icon, size: iconSize, color: color),
    tooltip: text,
    onPressed: () async {
      bool confirmation = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: const Text('Confirmación'),
                content: const Text('¿Está seguro de realizar esta acción?'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text('Cancelar')),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text('Aceptar')),
                ]);
          }) as bool;
      if (confirmation) {
        if (args != null) {
          action(context, args);
        } else {
          action(context);
        }
      }
    },
  );
}

Widget removeBtn(context, action, args,
    {text = removeText, icon = Icons.remove_circle, iconSize = 20}) {
  return IconButton(
    icon: Icon(
      icon,
      size: iconSize,
    ),
    tooltip: text,
    onPressed: () {
      action(context, args);
    },
  );
}

Widget removeConfirmBtn(context, action, args,
    {text = removeText, icon = Icons.remove_circle, iconSize = 20}) {
  return IconButton(
    icon: Icon(icon, size: iconSize),
    tooltip: text,
    onPressed: () async {
      bool confirmation = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                titlePadding: const EdgeInsets.all(0),
                title: s4cTitleBar(removeText),
                content: const SingleChildScrollView(
                  child: Text(removeConfirm),
                ),
                actions: <Widget>[
                  Row(children: [
                    Expanded(
                        flex: 5,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 20.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            backgroundColor: Colors.white,
                          ),
                          child: Row(children: [
                            const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.black54,
                              size: 30,
                            ),
                            space(width: 10),
                            customText(removeText, 14)
                          ]),
                        )),
                    space(width: 10),
                    Expanded(
                        flex: 5,
                        child: actionButton(context, "Cancelar", (context) {
                          Navigator.of(context).pop(false);
                        }, Icons.cancel, context))
                  ])
                ]);
          }) as bool;
      if (confirmation) {
        if (args == null) {
          try {
            action();
          } catch (e) {
            action(context);
          }
        } else {
          try {
            action(args);
          } catch (e) {
            action(context, args);
          }
        }
      }
    },
  );
}

Widget cancelBtn(context) {
  return TextButton(
    child: const Text(cancelText),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
}

Widget returnBtn(context) {
  return FilledButton(
    onPressed: () {
      Navigator.pop(context);
    },
    style: btnStyle,
    child: Column(
      children: [
        space(height: 5),
        const Icon(Icons.arrow_circle_left_outlined, color: subTitleColor),
        space(height: 5),
        customText(returnText, 12, textColor: subTitleColor),
        space(height: 5),
      ],
    ),
  );
}

Widget saveBtn(context, action, [args]) {
  return FilledButton(
    onPressed: () {
      if (args == null) {
        action();
      } else {
        action(args);
      }
    },
    style: btnStyle,
    child: Column(
      children: [
        space(height: 5),
        const Icon(Icons.save_outlined, color: subTitleColor),
        space(height: 5),
        customText(saveText, 12, textColor: subTitleColor),
        space(height: 5),
      ],
    ),
  );
}

Widget saveBtnForm(context, action, [args]) {
  return actionButton(context, saveText, action, Icons.save_outlined, args);
}

Widget removeBtnForm(context, action, [args]) {
  void confirmDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text(AppLocalizations.of(context)!.confirm),
      content: Text(AppLocalizations.of(context)!.confirmDelete),
      actions: [
        TextButton(
          child: Text(AppLocalizations.of(context)!.delete),
          onPressed: () {
            args == null
                ? Navigator.of(context).pop(action())
                : Navigator.of(context).pop(action(args));
          },
        ),
        TextButton(
          child: Text(AppLocalizations.of(context)!.cancel),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  return actionButton(
      context, removeText, confirmDialog, Icons.delete, context);
}

Widget cancelBtnForm(context) {
  return actionButton(context, cancelText, () {
    Navigator.pop(context);
  }, Icons.cancel, null);
}

Widget dialogsBtns(context, action, obj) {
  return Row(children: [
    Expanded(
      flex: 5,
      child:
          actionButton(context, "Enviar", action, Icons.save_outlined, [obj]),
    ),
    space(width: 10),
    Expanded(
        flex: 5,
        child: actionButton(
            context, "Cancelar", cancelItem, Icons.cancel, context))
  ]);
}

Widget dialogsBtns2(context, action, [args]) {
  return Row(children: [
    Expanded(
      flex: 5,
      child: actionButton(context, "Enviar", action, Icons.save_outlined, args),
    ),
    space(width: 10),
    Expanded(
        flex: 5,
        child: actionButton(
            context, "Cancelar", cancelItem, Icons.cancel, context))
  ]);
}

//--------------------------------------------------------------------------
//                           TABS
//--------------------------------------------------------------------------
BoxDecoration tabDecoration = const BoxDecoration(
    border: Border(
      top: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
      left: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
      right: BorderSide(width: 2.0, color: Color(0xffdfdfdf)),
      bottom: BorderSide(width: 0, color: Color(0xffdfdfdf)),
    ),
    // borderRadius: BorderRadius.only(
    //     topLeft: Radius.circular(5), topRight: Radius.circular(5)),
    borderRadius: null,
    color: Colors.white);

Widget menuTab(context, btnName, btnRoute, args, {selected = false}) {
  if (selected) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: tabDecoration,
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
          },
          child: customText(btnName, 16, textColor: cardHeaderColor),
        ));
  } else {
    return Container(
        padding: const EdgeInsets.all(5),
        child: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
          },
          child: customText(btnName, 16, textColor: subTitleColor),
        ));
  }
}

Widget menuTab2(context, btnName, newContext, {selected = false}) {
  if (selected) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: tabDecoration,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: ((context) => newContext)));
          },
          child: customText(btnName, 16, textColor: mainColor),
        ));
  } else {
    return Container(
        padding: const EdgeInsets.all(5),
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: ((context) => newContext)));
          },
          child: customText(btnName, 16, textColor: subTitleColor),
        ));
  }
}

Widget contentTab(context, action, obj, {widthFactor = 1}) {
  return Flexible(
      child: Container(
          width: MediaQuery.of(context).size.width * widthFactor,
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Card(
            elevation: 5,
            /*decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffdfdfdf),
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),*/
            child: action(context, obj),
          )));
}

Widget contentTabSized(context, action, obj, {widthFactor = 1}) {
  return Container(
      padding: const EdgeInsets.only(left: 10, right: 10),
      width: MediaQuery.of(context).size.width * widthFactor,
      child: Card(
        elevation: 5,
        child: (action is Function) ? action(context, obj) : action,
      ));
}

//--------------------------------------------------------------------------
//                           COLLAPSE
//--------------------------------------------------------------------------
Widget customCollapse(context, title, action, obj,
    {expanded = true, subtitle = "", style = "main"}) {
  Map<String, Map<String, dynamic>> styles = {
    "main": {
      "titleColor": headerListTitleColor,
      "bgColor": headerListBgColor,
      "iconColor": headerListTitleColor
    },
    "secondary": {
      "titleColor": Colors.black87,
      "bgColor": Colors.blue[50],
      "iconColor": Colors.black87,
    },
    "danger": {
      "titleColor": Colors.white,
      "bgColor": Colors.red,
      "iconColor": Colors.white
    },
    "warning": {
      "titleColor": Colors.white,
      "bgColor": Colors.orange,
      "iconColor": Colors.white
    },
    "success": {
      "titleColor": Colors.white,
      "bgColor": Colors.green,
      "iconColor": Colors.white
    },
    "level-2": {
      "iconColor": mainMenuBtnSelectedColor,
      "bgColor": headerListBgColorIndicator,
      "titleColor": mainMenuBtnSelectedColor
    },
  };

  Map<String, dynamic> currentStyle;
  if (style is String) {
    style = style.toLowerCase();
    if (!styles.containsKey(style)) {
      style = "main";
    }
    currentStyle = styles[style]!;
  } else {
    currentStyle = style;
  }

  return ExpansionTile(
    title: (title is String)
        ? customText(title, 14, textColor: currentStyle["titleColor"])
        : title,
    subtitle: customText(subtitle, 14, textColor: currentStyle["titleColor"]),
    backgroundColor: currentStyle["bgColor"],
    collapsedBackgroundColor: currentStyle["bgColor"],
    iconColor: currentStyle["iconColor"],
    collapsedIconColor: currentStyle["iconColor"],
    initiallyExpanded: expanded,
    shape: Border.all(color: Colors.transparent),
    children: [
      Container(decoration: tabDecoration, child: action(context, obj))
    ],
  );
}

Widget customCollapse2(context, title, action, obj,
    {expanded = true,
    subtitle = "",
    bgColor = headerListBgColor,
    txtColor = headerListTitleColor}) {
  return ExpansionTile(
    title: (title is String)
        ? customText(title, 14, textColor: txtColor, bold: FontWeight.bold)
        : title,
    //subtitle: customText(subtitle, 14, textColor: headerListTitleColor),
    backgroundColor: bgColor,
    collapsedBackgroundColor: bgColor,
    iconColor: txtColor,
    collapsedIconColor: txtColor,
    initiallyExpanded: expanded,
    shape: Border.all(color: Colors.transparent),
    children: [
      Container(decoration: tabDecoration, child: action(context, obj))
    ],
  );
}

//--------------------------------------------------------------------------
//                           DIALOGS
//--------------------------------------------------------------------------
Future<void> customRemoveDialog(context, obj, action, [args]) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(0),
        title: s4cTitleBar(removeText),
        content: const SingleChildScrollView(
          child: Text(removeConfirm),
        ),
        actions: <Widget>[
          Row(children: [
            Expanded(
                flex: 5,
                child: ElevatedButton(
                  onPressed: () {
                    if (obj != null) obj.delete();
                    if (args == null) {
                      action();
                    } else {
                      action(args);
                    }
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(children: [
                    const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.black54,
                      size: 30,
                    ),
                    space(width: 10),
                    customText(removeText, 14)
                  ]),
                )),
            space(width: 10),
            Expanded(
                flex: 5,
                child: actionButton(
                    context, "Cancelar", cancelItem, Icons.cancel, context))
          ])
          /*Expanded(
              flex: 5,
              child: ElevatedButton(
                onPressed: () {
                  obj.delete();
                  if (args == null) {
                    action();
                  } else {
                    action(args);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 20.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  backgroundColor: Colors.white,
                ),
                child: Row(children: [
                  const Icon(Icons.remove),
                  space(width: 10),
                  customText(removeText, 14)
                ]),
              )),*/
          /*TextButton(
            child: const Text(removeText),
            onPressed: () async {
              obj.delete();
              if (args == null) {
                action();
              } else {
                action(args);
              }
              Navigator.of(context).pop();
            },
          ),*/
          /*space(width: 10),
          Expanded(
              flex: 5,
              child: actionButton(
                  context, "Cancelar", cancelItem, Icons.cancel, context))*/
          /*TextButton(
            child: const Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),*/
        ],
      );
    },
  );
}

//--------------------------------------------------------------------------
//                           ACTIONS
//--------------------------------------------------------------------------
void cancelItem(BuildContext context) {
  Navigator.of(context).pop();
}

//--------------------------------------------------------------------------
//                           FORMS FIELDS
//--------------------------------------------------------------------------
class ReadOnlyTextField extends StatelessWidget {
  final String label;
  final String textToShow;
  final TextAlign textAlign;

  const ReadOnlyTextField(
      {super.key,
      required this.label,
      required this.textToShow,
      this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    Color bgcolor = Colors.grey.shade100;
    TextStyle? fgstyle = Theme.of(context)
        .textTheme
        .titleMedium!
        .copyWith(backgroundColor: bgcolor);
    return Container(
        color: bgcolor,
        child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                    height: 5.0), // Ajusta el espacio según sea necesario
                Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      label,
                      textAlign: textAlign,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall, // Estilo similar al de un TextFormField
                    )),
                const SizedBox(
                    height: 2.0), // Ajusta el espacio según sea necesario
                Row(children: [
                  Expanded(
                      flex: 1,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text(
                            textToShow,
                            textAlign: textAlign,
                            style:
                                fgstyle, // Estilo similar al de un TextFormField
                          )))
                ]),
                const SizedBox(
                    height: 4.0), // Ajusta el espacio según sea necesario

                const Divider(height: 1.0, color: Colors.black54),
                const SizedBox(
                    height: 2.0), // Ajusta el espacio según sea necesario
              ],
            )));
  }
}

// ignore: must_be_immutable
class UploadFileField extends StatelessWidget {
  final Object textToShow;
  final ValueChanged<PlatformFile?> onSelectedFile;
  PlatformFile? pickedFile;
  EdgeInsets padding = const EdgeInsets.only(top: 8);

  UploadFileField({
    super.key,
    required this.textToShow,
    required this.onSelectedFile,
    this.pickedFile,
    this.padding = const EdgeInsets.only(top: 8),
  });

  Future<PlatformFile?> chooseFile(context) async {
    final result =
        await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (result == null) {
      return null;
    } else {
      pickedFile = result.files.first;
      onSelectedFile(pickedFile);
      return pickedFile;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Padding(
          padding: padding,
          child: actionButtonVertical(
              context,
              (pickedFile == null) ? textToShow : pickedFile!.name,
              chooseFile,
              Icons.upload_file,
              context))
    ]);
  }
}

class DateTimeRangePicker extends StatelessWidget {
  DateTimeRangePicker({
    Key? key,
    required DateTimeRange this.calendarRangeDate,
    required this.labelText,
    required this.selectedDate,
    required this.onSelectedDate,
  }) : super(key: key);

  final DateTimeRange calendarRangeDate;
  final String labelText;
  final DateTimeRange selectedDate;
  final ValueChanged<DateTimeRange> onSelectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: calendarRangeDate.start,
        lastDate: calendarRangeDate.end,
        initialDateRange: DateTimeRange(
          end: selectedDate.end,
          start: selectedDate.start,
        ),
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400.0,
                  maxHeight: 500.0,
                ),
                child: child,
              )
            ],
          );
        });

    if (picked != null && picked != selectedDate) onSelectedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "${"${selectedDate.start.toLocal()}".split(' ')[0]} - ${"${selectedDate.end.toLocal()}".split(' ')[0]}",
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker({
    Key? key,
    required this.labelText,
    required this.selectedDate,
    required this.onSelectedDate,
    this.firstDate,
    this.lastDate,
    this.readOnly = false,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime> onSelectedDate;
  final bool readOnly;

  Future<void> _selectDate(BuildContext context) async {
    if (readOnly) {
      return;
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: firstDate != null ? firstDate! : DateTime(1900),
      lastDate: lastDate != null ? lastDate! : DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: readOnly ? Colors.grey.shade100 : null,
        child: InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: labelText,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  DateFormat("dd-MM-yyyy")
                      .format(selectedDate.toLocal())
                      .split(' ')[0],
                ),
                //customText(DateFormat("dd-MM-yyyy").format(selectedDate), 14),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
        ));
  }
}

class CustomPopupDialog extends StatefulWidget {
  final dynamic context;
  final String title;
  final IconData icon;
  final Widget content;
  final List<Widget>? actionBtns;

  const CustomPopupDialog({
    super.key,
    required this.context,
    required this.title,
    required this.icon,
    required this.content,
    required this.actionBtns,
  });

  @override
  _CustomPopupDialogState createState() => _CustomPopupDialogState();
}

class _CustomPopupDialogState extends State<CustomPopupDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: s4cTitleBar(widget.title, widget.context, widget.icon),
      content: Padding(padding: const EdgeInsets.all(0), child: widget.content),
      actions: widget.actionBtns,
    );
  }
}

class CustomDropdown extends StatelessWidget {
  const CustomDropdown({
    Key? key,
    required this.labelText,
    required this.size,
    required this.options,
    required this.selected,
    required this.onSelectedOpt,
  }) : super(key: key);

  final double size;
  final String labelText;
  final KeyValue selected;
  final List<KeyValue> options;
  final ValueChanged<String> onSelectedOpt;

  @override
  Widget build(BuildContext context) {
    // Create a list of DropDownnOnSearchFind options from options_src
    DropdownSearchOnFind<KeyValue> options_new = (filter, loadProps) {
      return Future.value(
          options.where((element) => element.value.contains(filter)).toList());
    };

    return SizedBox(
        width: size,
        child: DropdownSearch<KeyValue>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
          items: options_new,
          itemAsString: (KeyValue p) => p.value,
          compareFn: (i1, i2) => i1.key == i2.key,
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              labelText: labelText,
              hintText: labelText,
            ),
          ),
          onChanged: (val) {
            onSelectedOpt(val!.key);
          },
          selectedItem: selected,
        ));
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.initial,
    required this.size,
    required this.fieldValue,
    this.minLines = 1,
    this.maxLines = 1,
  }) : super(key: key);

  final String labelText;
  final String initial;
  final double size;
  final ValueChanged<String> fieldValue;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    int? mLines = (maxLines < 9999) ? maxLines : null;
    return SizedBox(
      width: size,
      child: TextFormField(
        minLines: minLines,
        maxLines: mLines,
        initialValue: (initial != "") ? initial : "",
        decoration: InputDecoration(
            labelText: labelText,
            contentPadding: const EdgeInsets.only(bottom: 4)),
        onChanged: (val) {
          fieldValue(val);
        },
      ),
    );
  }
}

class CustomIntField extends StatelessWidget {
  const CustomIntField({
    Key? key,
    required this.labelText,
    required this.initial,
    required this.size,
    required this.fieldValue,
  }) : super(key: key);

  final String labelText;
  final int initial;
  final double size;
  final ValueChanged<int> fieldValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: TextFormField(
        initialValue: initial.toString(),
        decoration: InputDecoration(
            labelText: labelText,
            contentPadding: const EdgeInsets.only(bottom: 4)),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ], // O
        onChanged: (val) {
          fieldValue(int.parse(val));
        },
      ),
    );
  }
}

class CustomSelectFormField extends StatelessWidget {
  const CustomSelectFormField({
    Key? key,
    required this.labelText,
    required this.initial,
    required this.options,
    required this.onSelectedOpt,
    this.required = false,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  final String labelText;
  final String initial;
  final List<KeyValue> options;
  final ValueChanged<String> onSelectedOpt;
  final EdgeInsets padding;
  final bool required;

  @override
  Widget build(BuildContext context) {
    String initialKey = "";

    for (var i = 0; i < options.length; i++) {
      if (options[i].key == initial) {
        initialKey = initial;
        break;
      }
    }

    if (initialKey == "") {
      options.insert(0, KeyValue("", "Seleccione una opción"));
    }

    // Check if initial value is in the list of options (if not, add it)
    if (!options.any((element) => element.key == initial)) {
      options.insert(0, KeyValue(initial, initial));
    }

    //Remove duplicates /by key)
    for (var i = 0; i < options.length; i++) {
      for (var j = i + 1; j < options.length; j++) {
        if (options[i].key == options[j].key) {
          options.removeAt(j);
        }
      }
    }

    List<DropdownMenuItem<String>> optionsDrop = options.map((e) {
      return DropdownMenuItem<String>(
        value: e.key,
        child: Text(e.value),
      );
    }).toList();

    return Padding(
        padding: padding,
        child: DropdownButtonFormField(
          value: initialKey,
          decoration: InputDecoration(labelText: labelText),
          items: optionsDrop,
          onChanged: (value) {
            if (value != null) {
              onSelectedOpt(value.toString());
            }
          },
          validator: (value) {
            if (!required) {
              return null;
            }
            if (value == null ||
                value.isEmpty ||
                (required && value == "") ||
                (value == "--")) {
              return 'Por favor seleccione una opción';
            }
            return null;
          },
        ));
  }
}

class CustomDateField extends StatelessWidget {
  const CustomDateField({
    Key? key,
    required this.labelText,
    required this.selectedDate,
    required this.onSelectedDate,
    this.minYear = 2000,
    this.maxYear = 2101,
    this.bottom = 16,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectedDate;
  final int minYear;
  final int maxYear;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: ListTile(
          leading: const Icon(Icons.date_range),
          shape: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          title: Text(labelText),
          subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(minYear),
                lastDate: DateTime(maxYear, 12, 31));
            if (picked != null && picked != selectedDate) {
              onSelectedDate(picked);
            }
          },
        ));
  }
}

class FilterDateField extends StatelessWidget {
  const FilterDateField({
    Key? key,
    required this.labelText,
    required this.selectedDate,
    required this.onSelectedDate,
    this.minYear = 2000,
    this.maxYear = 2101,
    this.bottom = 16,
  }) : super(key: key);

  final dynamic labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectedDate;
  final int minYear;
  final int maxYear;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: ListTile(
          leading: const Icon(Icons.date_range),
          shape: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0)),
          title: (labelText is String)
              ? Text(
                  labelText,
                  style: TextStyle(fontSize: 10),
                  maxLines: 1,
                )
              : labelText,
          subtitle: Text(DateFormat('dd/MM/yyyy').format(selectedDate),
              style: TextStyle(fontSize: 12)),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(minYear),
                lastDate: DateTime(maxYear, 12, 31));
            if (picked != null && picked != selectedDate) {
              onSelectedDate(picked);
            }
          },
        ));
  }
}

Widget customTextLabel(context, String label, dynamic text) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 5.0),
      Text(label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: mainColor, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2.0),
      (text is String)
          ? Text(text, style: Theme.of(context).textTheme.titleMedium)
          : text,
      const SizedBox(height: 4.0),
      const SizedBox(height: 2.0),
    ],
  );
}

Widget mainHeader(title, List<Widget> buttons) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Container(
      padding: (buttons.isNotEmpty)
          ? const EdgeInsets.only(left: 40)
          : EdgeInsets.all(40),
      child: (title is String)
          ? Text(title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left)
          : title,
    ),
    Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: buttons,
      ),
    ),
  ]);
}

class FileNameDialog extends StatefulWidget {
  const FileNameDialog({super.key});

  @override
  _FileNameDialogState createState() => _FileNameDialogState();
}

class _FileNameDialogState extends State<FileNameDialog> {
  TextEditingController _fileNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter file name'),
      content: TextField(
        controller: _fileNameController,
        decoration: InputDecoration(hintText: "Nombre de archivo"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null); // Cancel
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_fileNameController.text); // Confirm
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}
