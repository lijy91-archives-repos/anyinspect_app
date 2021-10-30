import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<Widget> children;

  const Sidebar({
    Key? key,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
