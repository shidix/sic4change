import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:js' as js;

import 'package:flutter/services.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
// import 'package:sic4change/pages/project_transversal_page.dart';
import 'package:sic4change/services/models_commons.dart';

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

Widget customDropdownField(_controller, _options, _current, _hint,
    {width = 220}) {
  return SizedBox(
      width: width,
      child: DropdownSearch<KeyValue>(
        popupProps: const PopupProps.menu(
          showSearchBox: true,
          showSelectedItems: true,
          //disabledItemFn: (String s) => s.startsWith('I'),
        ),
        //items: ["Brazil", "Italia (Disabled)", "Tunisia", 'Canada'],
        items: _options,
        itemAsString: (KeyValue p) => p.value,
        compareFn: (i1, i2) => i1.key == i2.key,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            //labelText: "Menu mode",
            hintText: _hint,
          ),
        ),
        onChanged: (val) {
          _controller.text = val?.key;
        },
        selectedItem: _current,
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
              "${selectedDate.toLocal()}".split(' ')[0],
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }
}

Widget addButton(context, String text, String route, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushNamed(context, route, arguments: args);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.add,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget backButton(context) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Row(
      children: [
        const Icon(
          Icons.arrow_back,
          color: Colors.black54,
          size: 30,
        ),
        space(height: 10),
        const Text(
          "Volver",
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget actionButton(
    context, String text, Function action, IconData? icon, dynamic args,
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
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      backgroundColor: Colors.white,
    ),
    child: Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 30,
        ),
        space(height: 10),
        Text(
          text,
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget actionButtonVertical(
    context, String text, Function action, IconData? icon, dynamic args,
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
        customText(text, 12, textColor: subTitleColor),
        space(height: 5),
      ],
    ),
  );
}

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
                height: 4.0), // Ajusta el espacio según sea necesario
            Text(
              label,
              textAlign: textAlign,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall, // Estilo similar al de un TextFormField
            ),
            const SizedBox(
                height: 2.0), // Ajusta el espacio según sea necesario
            Text(
              textToShow,
              textAlign: textAlign,
              style: fgstyle, // Estilo similar al de un TextFormField
            ),
            const SizedBox(
                height: 4.0), // Ajusta el espacio según sea necesario

            const Divider(height: 1.0, color: Colors.black54),
            const SizedBox(
                height: 2.0), // Ajusta el espacio según sea necesario
          ],
        ));
  }
}

SizedBox s4cTitleBar(String title, [context]) {
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

Object getObject(List items, String uuid) {
  return items.firstWhere((item) => item.uuid == uuid);
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

const Color titleColor = Color(0xffabf0ff);
const TextStyle titleText = TextStyle(
  fontFamily: 'Readex Pro',
  color: Color(0xffabf0ff),
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

//Color titleColor = Color(0xff008099);
Color greyColor = const Color(0xffdfdfdf);
//Color bgColor = const Color(0xffe5f2d7);
Color bgColor = const Color(0xff00594f);
Color mainMenuBtnSelectedColor = Colors.white;
Color mainMenuBtnColor = Colors.white54;

// const Color mainColor = Color(0xFF00809A);
const Color mainColor = Color(0xffabf100);

const TextStyle mainText = TextStyle(
  fontFamily: 'Readex Pro',
  color: mainColor,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const Color secondaryColor = Color(0xFF00809A);
const TextStyle secondaryText = TextStyle(
  fontFamily: 'Readex Pro',
  color: Color(0xFF00809A),
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

//--------------------------------------------------------------------------
//                           TEXTS
//--------------------------------------------------------------------------
Widget customText(_text, _size,
    {textColor = Colors.black, bold = FontWeight.normal}) {
  return Text(
    _text,
    style: TextStyle(fontSize: _size, color: textColor, fontWeight: bold),
  );
}

//--------------------------------------------------------------------------
//                           BUTTONS
//--------------------------------------------------------------------------
Widget addBtn(context, action, args, {text = addText, icon = Icons.add}) {
  return FilledButton(
      onPressed: () {
        action(context, args);
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
        title: const Text(removeText),
        content: const SingleChildScrollView(
          child: Text(removeConfirm),
        ),
        actions: <Widget>[
          TextButton(
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
          ),
          TextButton(
            child: const Text(cancelText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
