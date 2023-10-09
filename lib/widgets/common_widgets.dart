import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:js' as js;

Widget space({width = 10, height = 10}) {
  return SizedBox(
    width: width,
    height: height,
  );
}

Widget customText(_text, _size, {textColor = Colors.black}) {
  return Text(
    _text,
    style: TextStyle(fontSize: _size, color: textColor),
  );
}

Widget menuBtn(context, btnName, btnIcon, btnRoute) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute);
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      side: const BorderSide(width: 0, color: Colors.blueGrey),
      backgroundColor: Colors.blueGrey,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(btnIcon, color: Colors.black54),
        Text(
          btnName,
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      ],
    ),
  );
}

Widget menuTab(context, btnName, btnRoute, args) {
  return Container(
      padding: EdgeInsets.all(5),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
        },
        child: Text(
          btnName,
          style: TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ));
}

Widget menuTabSelect(context, btnName, btnRoute, args) {
  return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
          border: Border(
            top: BorderSide(width: 1.0, color: Colors.grey),
            left: BorderSide(width: 1.0, color: Colors.grey),
            right: BorderSide(width: 1.0, color: Colors.grey),
            bottom: BorderSide(width: 1.0, color: Colors.grey),
          ),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          color: Colors.grey),
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
        },
        child: Text(
          btnName,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ));
}

Widget logoutBtn(context, btnName, btnIcon) {
  return ElevatedButton(
    onPressed: () {
      FirebaseAuth.instance.signOut();
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      side: const BorderSide(width: 0, color: Colors.blueGrey),
      backgroundColor: Colors.blueGrey,
      //primary: Colors.purple),
    ),
    child: Column(
      children: [
        Icon(btnIcon, color: Colors.black54),
        Text(
          btnName,
          style: TextStyle(color: Colors.black54, fontSize: 18),
        ),
      ],
    ),
  );
}

Widget customBtn(context, btnName, btnIcon, btnRoute) {
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
}

Widget customBtnArgs(context, btnName, btnIcon, btnRoute, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
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
}

Widget customRowBtn(context, btnName, btnIcon, btnRoute, args) {
  return ElevatedButton(
    onPressed: () {
      Navigator.pushReplacementNamed(context, btnRoute, arguments: args);
      //Navigator.pushNamed(context, btnRoute, arguments: {"currentFolder": "1"});
    },
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
          style: TextStyle(color: Colors.black, fontSize: 14),
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
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
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
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
      ],
    ),
  );
}

Widget customTextField(_controller, _hint) {
  return SizedBox(
    width: 220,
    child: TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: _hint,
      ),
    ),
  );
}

Widget customAutocompleteField(_controller, _options, _hint) {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();

  return Column(children: [
    SizedBox(
      width: 220,
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
