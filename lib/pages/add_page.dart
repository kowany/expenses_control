import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_control_app/login_state.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../category_selection_widget.dart';


class AddPage extends StatefulWidget {
  final Rect buttonRect;

  const AddPage({Key key, this.buttonRect}) : super(key: key);

  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {

  AnimationController _controller;
  Animation _buttonAnimation;
  Animation _pageAnimation;

  String category;
  int value = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration( milliseconds: 1750 ),
      vsync: this
    );

    _buttonAnimation = Tween<double>(begin: 0.0, end: 1.0 ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceInOut )
    );

    _pageAnimation = Tween<double>(begin: -1.0, end: 1.0 ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceInOut )
    );
    _controller.addListener(() {
      setState( () {});
    });

    _controller.addStatusListener((status) {
      if ( status == AnimationStatus.dismissed ) {
        Navigator.of(context).pop();
      }
    });
    _controller.forward( from: 0.0 );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Transform.translate(
          offset: Offset( 0, h * ( 1 - _pageAnimation.value )),
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              title: Text(
                'Category',
                style: TextStyle(
                  color: Colors.grey
                ),
              ),
              centerTitle: false,
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _controller.reverse();
                    // Navigator.of(context).pop();
                  }
                )
              ],
            ),
            body: _body(),
          ),
        ),
        _submit()
      ]
    );
  }

  Widget _body () {
    var h = MediaQuery.of(context).size.height;
    return Column(
      children: <Widget>[
        _categorySelector(),
        _currentValue(),
        _numpad(),
        SizedBox(
          height: h - widget.buttonRect.top,
        )
      ],
    );
  }

  Widget _categorySelector() {
    return Container(
      height: 80.0,
      child: CategorySelectionWidget(
        categories: {
          'Shopping': Icons.shopping_cart,
          'Alcohol': FontAwesomeIcons.beer,
          'Fast food': FontAwesomeIcons.hamburger,
          'Bills': FontAwesomeIcons.wallet
        },
        onValueChanged: ( newCategory ) => category = newCategory
      )
    );
  }

  Widget _currentValue() {
    var realValue = value / 100.0;
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 18.0),
      child: Text(
        '\$${realValue.toStringAsFixed( 2 )}',
        style: TextStyle(
          fontSize: 50.0,
          color: Colors.blueAccent,
          fontWeight: FontWeight.w500
        ),
      ),
    );
  }

  Widget _num ( String text, double height ) {
    return GestureDetector(
      // permite que al hacer click sobre cualquier espacio del
      // contenedor del número, sea lo mismo que al hacerlo sobre
      // el propio número
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          if ( text == ',' ) {
            value = value * 100;
          } else {
            value = value * 10 + int.parse( text );
          }
        });
      },
      child: Container(
        height: height,
        child: Center(
          child: Text( 
            text,
            style: TextStyle(
              fontSize: 40.0,
              color: Colors.grey
            ),
          ),
        )
      ),
    );
  }

  Widget _numpad() {
    return Expanded(
      child: LayoutBuilder(
        builder: ( BuildContext context, BoxConstraints constrainsts) {
          var height = constrainsts.biggest.height / 4.0;
          return Table(
            border: TableBorder.all(
              color: Colors.grey,
              width: 1.0
            ),
            children: [
              TableRow(
                children: [
                  _num( '1', height ),
                  _num( '2', height ),
                  _num( '3', height ),
                ]
              ),
              TableRow(
                children: [
                  _num( '4', height ),
                  _num( '5', height ),
                  _num( '6', height ),
                ]
              ),
              TableRow(
                children: [
                  _num( '7', height ),
                  _num( '8', height ),
                  _num( '9', height ),
                ]
              ),
              TableRow(
                children: [
                  _num( ',', height ),
                  _num( '0', height ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        value = value ~/ 10;
                      });
                    },
                    child: Container(
                      height: height,
                      child: Center(
                        child: Icon(
                          Icons.backspace,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                      ),
                    ),
                  )
                ]
              ),
            ],
          );
        },
      )
    );
  }
  Widget _submit( ) {
    // El Builder proporciona un contexto
    // completo sin un método build
    if ( _controller.value < 1 ) {
      var buttonWidth = widget.buttonRect.right - widget.buttonRect.left;
      var w = MediaQuery.of(context).size.width;
      return Positioned(
         left: (widget.buttonRect.left) * (1 - _buttonAnimation.value),
          //<-- Margin from left
          right: (w - widget.buttonRect.right) * (1 - _buttonAnimation.value),
          //<-- Margin from right
          top: widget.buttonRect.top,
          //<-- Margin from top
          bottom: (MediaQuery.of(context).size.height - widget.buttonRect.bottom) *
              (1 - _buttonAnimation.value),
          //<-- Margin from bottom
           child: Container(
            width: double.infinity,
            //<-- Blue cirle
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  buttonWidth * (1 - _buttonAnimation.value)),
              color: Colors.blueAccent,
            ),
            child: MaterialButton(
              onPressed: () {},
              child: Text(
                "Add expense",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
        // child: Container(
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular( buttonWidth * ( 1 - _buttonAnimation.value ) ),
        //     color: Colors.blueAccent
        //   ),
        // )
    } else {
      return Positioned(
        top: widget.buttonRect.top,
        bottom: 0.0,
        left: 0.0,
        right: 0.0,
        child: Builder(
          builder: ( BuildContext context ) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent
              ),
              child: MaterialButton(
                child: Text( 
                  'Add expense',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500
                  ),
                ),
                onPressed: () {
                  var user = Provider.of<LoginState>(context, listen: false).currentUser;
                  var today = DateTime.now();
                  if ( value > 0 && category != null ) {
                    Firestore.instance
                      .collection( 'users' )
                      .document( user.uid )
                      .collection( 'expenses' )
                      .document()
                      .setData({
                        'category': category,
                        'value': value / 100.0,
                        'month': today.month,
                        'day': today.day,
                        'year': today.year
                      });
                      Navigator.of( context ).pop();
                  } else {
                      showDialog(
                        context: context,
                        builder: ( context ) => AlertDialog(
                          content: Text( 'Enter a value and select a category'),
                          actions: <Widget>[
                            FlatButton(
                              child: Text( 'Ok' ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }, 
                            )
                          ],                       )
                      );
                      // Scaffold.of(context).showSnackBar(
                      //   SnackBar( content: Text( 'Enter a value and select a category' ) )
                      // );
                    }
                }
              )
            );
          },
        ),
      );
    }
  }

}