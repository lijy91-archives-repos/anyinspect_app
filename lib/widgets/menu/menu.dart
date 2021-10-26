import 'package:flutter/material.dart';

export './menu_item.dart';
export './menu_section.dart';

class Menu extends StatelessWidget {
  final EdgeInsets padding;
  final List<Widget> children;

  const Menu({
    Key? key,
    this.padding = EdgeInsets.zero,
    this.children = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: children,
    );
  }
}
