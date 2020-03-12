import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_control_app/login_state.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: Text(
            'Sign in'
          ),
          onPressed: () {
            Provider.of<LoginState>( context, listen: false ).login();
          },
        )
      ),
    );
  }
}