import 'package:flutter/material.dart';


class TapOnlyTextField extends StatelessWidget {
  final VoidCallback onTap;
  final String hintText;
  final BorderRadius borderRadius;

  const TapOnlyTextField({
    Key key,
    this.onTap,
    this.hintText,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: borderRadius,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: Colors.transparent,
            child: IgnorePointer(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                ),
              ),
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
