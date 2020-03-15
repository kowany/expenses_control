import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expenses_control_app/utils.dart';
import 'package:expenses_control_app/add_page_transition.dart';
import 'package:expenses_control_app/pages/add_page.dart';

import 'package:expenses_control_app/login_state.dart';

import 'package:expenses_control_app/month_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rect_getter/rect_getter.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var globalKey = RectGetter.createGlobalKey();
  Rect buttonRect;
  PageController _controller;
  int currentPage = DateTime.now().month - 1;
  Stream< QuerySnapshot > _query;
  GraphType currentType = GraphType.LINES;


  @override
  void initState() { 
    super.initState();
    
    
    
    _controller = PageController(
      initialPage: currentPage,
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
          var user = Provider.of<LoginState>(context, listen: false ).currentUser;
                  _query = Firestore.instance
                        .collection( 'users' )
                        .document( user.uid )
                        .collection( 'expenses' )
                        .where("month", isEqualTo: currentPage + 1 )
                        .snapshots();
      return Scaffold(
        bottomNavigationBar: BottomAppBar(
          notchMargin: 8.0,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _bottomAction( FontAwesomeIcons.chartLine, () {
                setState(() {
                  currentType = GraphType.LINES;
                });
              } ),
              _bottomAction( FontAwesomeIcons.chartPie, () {
                 setState(() {
                  currentType = GraphType.PIE;
                });
              } ),
              SizedBox( width: 48.0 ),
              _bottomAction( FontAwesomeIcons.wallet, () {} ),
              _bottomAction( Icons.settings, () {
                Provider.of<LoginState>(context, listen: false).logout();
              } ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: RectGetter(
          key: globalKey,
          child: FloatingActionButton(
            child: Icon( Icons.add ),
            onPressed: () {
              buttonRect = RectGetter.getRectFromKey( globalKey );
              print( buttonRect );
              var page = AddPageTransition(
                background: widget,
                page: AddPage(
                  buttonRect: buttonRect,
                )
              );
              Navigator.of( context ).push( page );
            }
          ),
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
                  days: daysInMonth( currentPage + 1),
                  documents: data.data.documents,
                  graphType: currentType,
                  month: currentPage,
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

    if ( position == currentPage ) {
      _alignment = Alignment.center;
    } else if ( position > currentPage ) {
      _alignment = Alignment.centerRight;
    } else {
      _alignment = Alignment.centerLeft;
    }


    return Align(
      alignment: _alignment,
      child: Text( 
        name,
        style: position == currentPage ? selected : unselected,
       )
    );
  }

  Widget _selector() {
    return SizedBox.fromSize(
      size: Size.fromHeight( 70.0 ),
      child: PageView(
        onPageChanged: ( newPage ) {
          setState(() {
            var user = Provider.of<LoginState>( context, listen: false).currentUser;
            currentPage = newPage;
            _query = Firestore.instance
                      .collection('users')
                      .document( user.uid )
                      .collection('expenses')
                      .where("month", isEqualTo: currentPage + 1 )
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