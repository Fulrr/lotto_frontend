import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final int? cid;
  HomePage({super.key, required this.cid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text('This is a blank page.'),
      ),
    );
  }
}
