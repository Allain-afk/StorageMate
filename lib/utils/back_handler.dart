import 'package:flutter/material.dart';

class DoubleBackToExit extends StatefulWidget {
  const DoubleBackToExit({super.key, required this.child});
  final Widget child;
  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastPressed;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Press back again to exit')));
          return;
        }
        Navigator.of(context).maybePop();
      },
      child: widget.child,
    );
  }
}


