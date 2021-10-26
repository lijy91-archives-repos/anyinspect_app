import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatefulWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? summary;
  final Widget? detailText;
  final Widget? accessoryView;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;

  const MenuItem({
    Key? key,
    this.icon,
    this.title,
    this.summary,
    this.detailText,
    this.accessoryView,
    this.selected = false,
    this.disabled = false,
    this.onTap,
  }) : super(key: key);

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  bool _isHovered = false;

  _onTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  Widget buildDetailText(BuildContext context) {
    if (widget.detailText != null) {
      return DefaultTextStyle(
        style: const TextStyle(
          color: Color(0xff999999),
          fontSize: 13,
        ),
        child: widget.detailText!,
      );
    }

    return Container();
  }

  Widget buildAccessoryView(BuildContext context) {
    if (widget.accessoryView != null) {
      return widget.accessoryView!;
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      padding: const EdgeInsets.only(
        left: 6,
        right: 6,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: widget.selected ? Theme.of(context).primaryColor : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Builder(
        builder: (_) {
          return MouseRegion(
            onEnter: (event) {
              _isHovered = true;
              setState(() {});
            },
            onExit: (event) {
              _isHovered = false;
              setState(() {});
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.disabled ? null : _onTap,
              child: Container(
                width: double.infinity,
                child: Row(
                  children: [
                    if (widget.icon != null)
                      Container(
                        child: widget.icon,
                        margin: EdgeInsets.only(right: 8),
                      ),
                    if (widget.title != null || widget.summary != null)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.title != null)
                              DefaultTextStyle(
                                style: TextStyle(
                                  fontSize: 13,
                                  color: widget.selected
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyText2
                                          ?.color,
                                ),
                                child: widget.title!,
                              ),
                            if (widget.summary != null)
                              DefaultTextStyle(
                                style: TextStyle(
                                  color: widget.selected
                                      ? Colors.white.withOpacity(0.8)
                                      : const Color(0xff999999),
                                  fontSize: 11,
                                ),
                                child: widget.summary!,
                              ),
                          ],
                        ),
                      ),
                    buildDetailText(context),
                    if (_isHovered) buildAccessoryView(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
