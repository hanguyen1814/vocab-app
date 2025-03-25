import 'package:flutter/material.dart';

class HomeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const HomeTile(
      {super.key,
      required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
