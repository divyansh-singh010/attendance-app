import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NavigationComponent extends StatefulWidget {
  const NavigationComponent(
      {super.key,
      required this.currentIndex,
      required this.label,
      required this.iconPath,
      required this.setIndex,
      required this.getIndex});

  final int currentIndex;
  final String label;
  final String iconPath;
  final void Function(int) setIndex;
  final int Function() getIndex;

  @override
  State<NavigationComponent> createState() => _NavigationComponent();
}

class _NavigationComponent extends State<NavigationComponent> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.setIndex(widget.currentIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: widget.getIndex() == widget.currentIndex
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 4.0,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/icons/${widget.iconPath}.svg',
              height: 40,
              width: 40,
              colorFilter: widget.getIndex() == widget.currentIndex
                  ? ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcIn)
                  : const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            ),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.getIndex() == widget.currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
            ),
          ],
        ),
      )
    );
  }
}
