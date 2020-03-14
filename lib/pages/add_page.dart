import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_control_app/login_state.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../category_selection_widget.dart';


class AddPage extends StatefulWidget {
  @override
  _AddPageState createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  String category;
  int value = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Navigator.of(context).pop();
            }
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body () {
    return Column(
      children: <Widget>[
        _categorySelector(),
        _currentValue(),
        _numpad(),
        _submit()
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
    return Builder(
      builder: ( BuildContext context ) {
        return Container(
          height: 50.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.blueAccent
          ),
          child: MaterialButton(
            child: Text( 
              'Add expense',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.w500
              ),
            ),
            onPressed: () {
              var user = Provider.of<LoginState>(context, listen: false).currentUser;

              if ( value > 0 && category != null ) {
                Firestore.instance
                  .collection( 'users' )
                  .document( user.uid )
                  .collection( 'expenses' )
                  .document()
                  .setData({
                    'category': category,
                    'value': value / 100.0,
                    'month': DateTime.now().month,
                    'day': DateTime.now().day
                  });
                  Navigator.of( context ).pop();
              } else {
                  Scaffold.of(context).showSnackBar(
                    SnackBar( content: Text( 'Enter a value and select a category' ) )
                  );

                }

              
            }
          )
        );
      },
    );
  }
}