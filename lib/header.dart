import 'package:flutter/material.dart';
import 'app_color.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  //primary colors

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryColor,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
