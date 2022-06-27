import 'package:flutter/material.dart';

ThemeData get appTheme => ThemeData(
      scaffoldBackgroundColor: Colors.grey[200],
      primarySwatch: Colors.indigo,
      accentColor: Colors.blueGrey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'Quicksand',
      appBarTheme: ThemeData.light().appBarTheme.copyWith(
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 19,
                  ),
                ),
            brightness: Brightness.dark,
          ),
      textTheme: ThemeData.light().textTheme.copyWith(
            headline3: TextStyle(
              color: Colors.grey[800],
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
            headline4: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
            headline5: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            headline6: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
    );
