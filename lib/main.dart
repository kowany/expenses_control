import 'package:expenses_control_app/pages/add_page.dart';
import 'package:expenses_control_app/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': ( BuildContext context ) => HomePage(),
        '/add': ( BuildContext context ) => AddPage()
      },
    );
  }
}

