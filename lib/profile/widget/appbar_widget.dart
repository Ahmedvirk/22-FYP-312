import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../themes.dart';

AppBar buildAppBar(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  const icon = CupertinoIcons.moon_stars;

  return AppBar(
    leading: const BackButton(
      color: Colors.black,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: const Icon(icon),
        onPressed: () {
          final theme = isDarkMode ? MyThemes.lightTheme : MyThemes.darkTheme;
        },
      ),
    ],
  );
}
