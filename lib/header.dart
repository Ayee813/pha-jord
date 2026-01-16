import 'package:flutter/material.dart';
import 'app_color.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      elevation: 0, // Modern flat design
      title: Text(
        title,
        style: const TextStyle(
          fontWeight:
              FontWeight.w600, // Slightly lighter than bold for modern look
          fontSize: 20,
          color: Colors.white, // White text on blue background
          letterSpacing: 0.5, // Subtle spacing for clarity
        ),
      ),
      centerTitle: true, // Optional: centers the title for modern aesthetic
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
