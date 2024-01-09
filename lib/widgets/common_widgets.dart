// ignore_for_file: unused_import

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
    [Color color = Colors.black38]) {
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
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
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
    height: 1,
    color: Colors.grey,
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
    {Color textColor = Colors.black54, Color iconColor = Colors.black54}) {
  icon ??= Icons.settings;
  Widget? row;
  if (text != null) {
    List<Widget> children = [];
    children.add(Icon(
      icon,
      color: iconColor,
      size: 30,
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
      size: 30,
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: row,
  );
}

Widget actionButtonVertical(
    context, String? text, Function action, IconData? icon, dynamic args,
    {Color textColor = Colors.black54, Color iconColor = Colors.black54}) {
  icon ??= Icons.settings;
  return ElevatedButton(
    onPressed: () {
      if (args == null) {
        action();
      } else {
        action(args);
      }
    },
    style: btnStyle,
    // ElevatedButton.styleFrom(
    //   padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    //   backgroundColor: Colors.white,
    // ),
    child: Column(
      children: [
        space(height: 5),
        Icon(icon, color: subTitleColor),
        space(height: 5),
        text != null
            ? customText(text, 12, textColor: subTitleColor)
            : const SizedBox(width: 0),
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

// const Color mainColor = Color(0xFF00809A);
const Color mainColor = Color(0xffabf100);
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

TextStyle headerListText = headerTitleText.copyWith(fontSize: 14);

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
  backgroundColor: const MaterialStatePropertyAll<Color>(Colors.white),
  shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
  elevation: const MaterialStatePropertyAll<double>(5),
);

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
    {textColor = Colors.black, bold = FontWeight.normal}) {
  return Text(
    _text,
    style: TextStyle(fontSize: _size, color: textColor, fontWeight: bold),
  );
}

SizedBox s4cTitleBar(String title, [context, icon]) {
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
                Expanded(
                    flex: 9,
                    child: Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white))),
                Expanded(flex: 1, child: closeButton)
              ]))));
}

//--------------------------------------------------------------------------
//                           BUTTONS
//--------------------------------------------------------------------------

Widget goPage(context, btnName, newContext, icon,
    {style = "", extraction = null}) {
  Widget child = Column(
    children: [
      //space(height: 5),
      Icon(icon, color: subTitleColor),
      space(height: 5),
      customText(btnName, 12, textColor: subTitleColor),
      //space(height: 5),
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
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => newContext)));
        extraction?.call();
      },
      style: (style == "") ? btnStyle : style,
      child: child);
}

Widget goPageIcon(context, btnText, icon, newContext) {
  return IconButton(
      icon: Icon(icon),
      tooltip: btnText,
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => newContext)));
      });
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
          Icon(icon, color: subTitleColor),
          space(height: 5),
          customText(text, 12, textColor: subTitleColor),
        ],
      ));
}

Widget editBtn(context, action, args, {text = editText, icon = Icons.edit}) {
  return IconButton(
    icon: Icon(icon),
    tooltip: text,
    onPressed: () {
      action(context, args);
    },
  );
}

Widget removeBtn(context, action, args,
    {text = removeText, icon = Icons.remove_circle}) {
  return IconButton(
    icon: Icon(icon),
    tooltip: text,
    onPressed: () {
      action(context, args);
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
        const Icon(Icons.arrow_circle_left_outlined, color: subTitleColor),
        space(height: 5),
        customText(returnText, 12, textColor: subTitleColor)
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
        const Icon(Icons.save_outlined, color: subTitleColor),
        space(height: 5),
        customText(saveText, 12, textColor: subTitleColor)
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
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(5), topRight: Radius.circular(5)),
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
          child: customText(btnName, 16, textColor: cardHeaderColor),
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

Widget contentTab(context, action, obj) {
  return Expanded(
      child: Container(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xffdfdfdf),
                width: 2,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Colors.white,
            ),
            child: action(context, obj),
          )));
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
                    obj.delete();
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

class DateTimeRangePicker extends StatelessWidget {
  const DateTimeRangePicker({
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
          end: DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 13),
          start: DateTime.now(),
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
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      onSelectedDate(picked);
    }
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
              DateFormat("dd-MM-yyyy")
                  .format(selectedDate.toLocal())
                  .split(' ')[0],
            ),
            //customText(DateFormat("dd-MM-yyyy").format(selectedDate), 14),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
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
    return SizedBox(
        width: size,
        child: DropdownSearch<KeyValue>(
          popupProps: const PopupProps.menu(
            showSearchBox: true,
            showSelectedItems: true,
          ),
          items: options,
          itemAsString: (KeyValue p) => p.value,
          compareFn: (i1, i2) => i1.key == i2.key,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
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
  }) : super(key: key);

  final String labelText;
  final String initial;
  final double size;
  final ValueChanged<String> fieldValue;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: TextFormField(
        initialValue: (initial != "") ? initial : "",
        decoration: InputDecoration(labelText: labelText),
        onChanged: (val) {
          fieldValue(val);
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
  }) : super(key: key);

  final String labelText;
  final String initial;
  final List<KeyValue> options;
  final ValueChanged<String> onSelectedOpt;
  final bool required;

  @override
  Widget build(BuildContext context) {
    if (initial == "") {
      options.insert(0, KeyValue("", "Seleccione una opción"));
    }
    List<DropdownMenuItem<String>> optionsDrop = options.map((e) {
      return DropdownMenuItem<String>(
        value: e.key,
        child: Text(e.value),
      );
    }).toList();

    return DropdownButtonFormField(
      value: initial,
      decoration: InputDecoration(
          labelText: labelText, contentPadding: const EdgeInsets.only(left: 5)),
      items: optionsDrop,
      onChanged: (value) {
        onSelectedOpt(value.toString());
      },
      validator: (value) {
        if (value == null || value.isEmpty || (required && value == "")) {
          return 'Por favor seleccione una opción';
        }
        return null;
      },
    );
  }
}
