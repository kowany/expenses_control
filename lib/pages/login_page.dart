import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_control_app/login_state.dart';

class LoginPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer<LoginState>(
          builder: (BuildContext context, LoginState value, Widget child) { 
            if ( value.isLoding ) {
              return CircularProgressIndicator();
            } else {
              return child;
            }
          },
          child: RaisedButton(
            child: Text(
              'Sign in'
            ),
            onPressed: () {
              Provider.of<LoginState>( context, listen: false ).login();
            },
          ),
        )
      ),
    );
  }
}