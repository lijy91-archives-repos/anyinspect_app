import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuSection extends StatefulWidget {
  final Widget title;
  final Widget? trailing;
  final bool collapsible;
  final List<Widget> children;

  const MenuSection({
    Key? key,
    required this.title,
    this.trailing,
    this.collapsible = true,
    this.children = const [],
  }) : super(key: key);

  @override
  _MenuSectionState createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  bool _isHovered = false;
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (event) {
            _isHovered = true;
            setState(() {});
          },
          onExit: (event) {
            _isHovered = false;
            setState(() {});
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: [
                Container(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                      color: Color(0xff9b9b9b),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    child: widget.title,
                  ),
                  margin: const EdgeInsets.only(left: 16),
                ),
                Expanded(child: Container()),
                if (_isHovered)
                  Row(
                    children: [
                      if (widget.trailing != null)
                        Container(
                          child: widget.trailing,
                        ),
                      Container(
                        width: 14,
                        height: 14,
                        margin: const EdgeInsets.only(left: 8, right: 12),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          pressedOpacity: 1,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.fastOutSlowIn,
                            transformAlignment: Alignment.center,
                            transform: Matrix4.rotationZ(
                              _isCollapsed ? math.pi / 2 : 0,
                            ),
                            child: const Icon(
                              CupertinoIcons.chevron_right,
                              size: 15,
                              color: Colors.grey,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _isCollapsed = !_isCollapsed;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          firstChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.children,
          ),
          secondChild: Container(),
          crossFadeState: _isCollapsed
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
