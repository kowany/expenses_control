import 'package:flutter/material.dart';

class LoginState extends ChangeNotifier {

  bool _loggedIn = false;

  bool get isLoggedIn => _loggedIn;

  void login () {
    _loggedIn = true;
    print( 'adentro LOGIN $_loggedIn',  );
    notifyListeners();
  }
  void logout () {
    print( 'adentro LOGIN $_loggedIn',  );
    _loggedIn = false;
    notifyListeners();
  }


}