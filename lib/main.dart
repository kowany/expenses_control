import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_control_app/login_state.dart';
import 'package:expenses_control_app/pages/add_page.dart';
import 'package:expenses_control_app/pages/home_page.dart';
import 'package:expenses_control_app/pages/login_page.dart';
void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginState>(
      create: ( BuildContext context ) => LoginState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expenses control',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          '/': ( BuildContext context ) {
            var state = Provider.of<LoginState>(context);
            if ( state.isLoggedIn ) {
              return HomePage();
            } else {
              return LoginPage();
            }
          },
          '/add': ( BuildContext context ) => AddPage()
        },
      ),
    );
  }
}

