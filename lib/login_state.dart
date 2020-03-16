import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginState extends ChangeNotifier {

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  SharedPreferences _prefs;

  bool _loggedIn = false;
  bool _loading = false;
  FirebaseUser _user;

  LoginState() {
    loginState();
  }
  bool get isLoggedIn => _loggedIn;
  bool get isLoading => _loading;
  FirebaseUser get currentUser => _user;

  void login () async {
    _loading = true;
    notifyListeners();

    _user = await _handleSignIn();

    _loading = false;
    if ( _user != null ) {
      _prefs.setBool( 'isLoggedIn', true );
      _loggedIn = true;
      notifyListeners();
    } else {
      _loggedIn = false;
      notifyListeners();
    }

    _loggedIn = true;
    notifyListeners();
  }
  void logout () {
    _prefs.clear();
    _googleSignIn.signOut();
    _loggedIn = false;
    notifyListeners();
  }

  Future<FirebaseUser> _handleSignIn() async {
    // el método signIn abre el selector de cuentas de google
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
    print("signed in " + user.displayName);
    return user;
  }

  void loginState() async {
    _prefs = await SharedPreferences.getInstance();

    if ( _prefs.containsKey( 'isLoggedIn' ) ) {
      _user = await _auth.currentUser();
      _loggedIn = _user != null;
      _loading = false;
      notifyListeners();
    } else {
      _loading = false;
      notifyListeners();
    }
  }
}