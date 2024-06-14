// ignore_for_file: file_names

import 'package:flutter/material.dart';

class Page404 extends StatefulWidget {
  const Page404({super.key});

  @override
  State<Page404> createState() => _Page404State();
}

class _Page404State extends State<Page404> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 Page'),
      ),
      body: const Center(child: Text('404 Page')),
    );
  }
}
