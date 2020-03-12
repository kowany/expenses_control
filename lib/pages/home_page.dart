import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expenses_control_app/login_state.dart';

import 'package:expenses_control_app/month_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PageController _controller;
  int curremtPage = 2;
  Stream< QuerySnapshot > _query;


  @override
  void initState() { 
    super.initState();
    
    _query = Firestore.instance
              .collection('expenses')
              .where("month", isEqualTo: curremtPage + 1 )
              .snapshots();
    
    _controller = PageController(
      initialPage: curremtPage,
      viewportFraction: 0.3
    );
  }


  Widget _bottomAction( IconData icon, Function callback ) {
    // el widget InkWell permite que al presionar un botón haga el efecto de onda
    return InkWell(
      child: Icon( icon ),
      onTap: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _bottomAction( FontAwesomeIcons.history, () {} ),
            _bottomAction( FontAwesomeIcons.chartPie, () {} ),
            SizedBox( width: 48.0 ),
            _bottomAction( FontAwesomeIcons.wallet, () {} ),
            _bottomAction( Icons.settings, () {
              Provider.of<LoginState>(context, listen: false).logout();
            } ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon( Icons.add ),
        onPressed: () {
          Navigator.of( context ).pushNamed( '/add' );
        }
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return SafeArea(
      child: Column(
        children: <Widget> [
          _selector(),
          StreamBuilder<QuerySnapshot>(
            stream: _query,
            builder: ( BuildContext context, AsyncSnapshot < QuerySnapshot > data ) {

              if ( data.connectionState == ConnectionState.waiting ) {
                return Center(
                  child: CircularProgressIndicator()
                );
              } else {
                return MonthWidget(
                  documents: data.data.documents 
                );
              }

            }
          )
        ]
      )
    );
  }

  Widget _pageItem( String name, int position ) {
    var _alignment;

     final selected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Colors.blueGrey,
    );
    final unselected = TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.normal,
      color: Colors.blueGrey.withOpacity(0.4),
    );

    if ( position == curremtPage ) {
      _alignment = Alignment.center;
    } else if ( position > curremtPage ) {
      _alignment = Alignment.centerRight;
    } else {
      _alignment = Alignment.centerLeft;
    }


    return Align(
      alignment: _alignment,
      child: Text( 
        name,
        style: position == curremtPage ? selected : unselected,
       )
    );
  }

  Widget _selector() {
    return SizedBox.fromSize(
      size: Size.fromHeight( 70.0 ),
      child: PageView(
        onPageChanged: ( newPage ) {
          setState(() {
            curremtPage = newPage;
            _query = Firestore.instance
                      .collection('expenses')
                      .where("month", isEqualTo: curremtPage + 1 )
                      .snapshots();
          });
        },
        controller: _controller,
        children: <Widget>[
            _pageItem( 'Enero', 0 ),
            _pageItem( 'Febrero', 1 ),
            _pageItem( 'Marzo', 2 ),
            _pageItem( 'Abril', 3 ),
            _pageItem( 'Mayo', 4 ),
            _pageItem( 'Junio', 5 ),
            _pageItem( 'Julio', 6 ),
            _pageItem( 'Agosto', 7 ),
            _pageItem( 'Septiembre', 8 ),
            _pageItem( 'Octubre', 9 ),
            _pageItem( 'Noviembre', 10 ),
            _pageItem( 'Diciembre', 11 ),
          ]
      ),
    );
  }
  

}