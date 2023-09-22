import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  /*return Container(
    child: Column(
      children: [
        IconButton(
          icon: Icon(btn_icon),
          tooltip: btn_name,
          onPressed: () {
            Navigator.pushReplacementNamed(context, btn_route);
          },
        ),
        Text(btn_name),
      ],
    ),*/
/*    child: ElevatedButton(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[Icon(my_icon), Text(btn_name)],
      ),
      onPressed: () {},
      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
          foregroundColor: MaterialStateProperty.all(Colors.grey),
          padding: MaterialStateProperty.all(EdgeInsets.all(10)),
          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 15))),
    ),*/

