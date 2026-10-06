import 'package:flutter/material.dart';

/// Constrains content to an iPhone portrait width, centred on wider screens.
class PhoneFrame extends StatelessWidget {
  static const double width = 390;
  static const double height = 844;

  final Widget child;
  const PhoneFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.grey.shade300,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: width, maxHeight: height),
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}
