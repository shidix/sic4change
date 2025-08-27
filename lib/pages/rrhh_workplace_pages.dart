import 'package:flutter/material.dart';

class WorkplacePage extends StatefulWidget {
  const WorkplacePage({super.key});

  @override
  State<WorkplacePage> createState() => WorkplacePageState();
}

class WorkplacePageState extends State<WorkplacePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Workplace Page'),
      ),
    );
  }
}
