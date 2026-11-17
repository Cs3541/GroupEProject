import 'package:flutter/material.dart';

class NavCard extends StatelessWidget{
  final VoidCallback onPressed;
  final String title;
  final Color backgroundColor;

  const NavCard({required this.onPressed, required this.title, required this.backgroundColor, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 80,
            horizontal: 24,
          ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    ),
  );
  }
}