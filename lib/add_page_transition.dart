import 'package:flutter/material.dart';

class AddPageTransition extends PageRouteBuilder {
  final Widget page;
  final Widget background;

  AddPageTransition( { this.page, this.background } ) : super (
    transitionDuration: Duration( microseconds: 0 ),
    pageBuilder: ( context, animation1, animation2 ) => page,
    transitionsBuilder: ( context, animation1, animation, child ) => Stack(
      children: <Widget>[ background, child ],
    )
  );
}