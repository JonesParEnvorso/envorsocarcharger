import 'package:flutter/material.dart';

class Help extends StatefulWidget {
  const Help({Key? key}) : super(key: key);

  @override
  State<Help> createState() => _Help();
}

class _Help extends State<Help> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text('About us'),
    );
  }
}
