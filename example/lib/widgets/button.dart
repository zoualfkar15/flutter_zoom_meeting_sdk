import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({Key? key, required this.onTap, required this.label}) : super(key: key);
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue),
            onPressed: onTap,
            child: Text(label ?? "default"),
          );
        },
      ),
    );
  }
}
