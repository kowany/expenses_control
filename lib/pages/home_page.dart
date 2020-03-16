import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:expenses_control_app/utils.dart';

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

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() { 
    super.initState();
    
    _controller = PageController(
      initialPage: currentPage,
      viewportFraction: 0.3
    );

    setupNotificationPlugin();

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
              // var page = AddPageTransition(
              //   page: AddPage(
              //     buttonRect: buttonRect,
              //   )
              // );
              Navigator.of( context ).pushNamed( '/add', arguments: buttonRect );
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
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator()
                  ),
                );
              } else {
                if ( data.data.documents.length > 0 ) {
                  return MonthWidget(
                    days: daysInMonth( currentPage + 1),
                    documents: data.data.documents,
                    graphType: currentType,
                    month: currentPage,
                  );
                } else {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset( 'assets/no_data.png' ),
                        SizedBox( height: 80.0 ),
                        Text(
                          'Add an expense to begin',
                          style: Theme.of(context).textTheme.caption,
                        )
                      ],
                    )
                  );
                }
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
  void setupNotificationPlugin() {

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );
    var initializationSettings = new InitializationSettings(
      initializationSettingsAndroid,
      initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin
        .initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    )
        .then((init) {
      setupNotification();
    });
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text("Don't forget to add your expenses"),
              actions: <Widget>[
                FlatButton(
                  child: Text('Ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }

  void setupNotification() async {
    var time = new Time( 21, 51, 0);
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'daily-notifications', 'Daily Notifications', 'Daily Notifications');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'Spend-o-meter',
        "Don't forget to add your expenses", time, platformChannelSpecifics);
  }
//   Future onSelectNotification(String payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: ' + payload);
//     }
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => HomePage()),
//     );
// }

//   Future onDidReceiveLocalNotification(
//       int id, String title, String body, String payload) async {
//     // display a dialog with the notification details, tap ok to go to another page
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               content: Text( "Don't forget to add your expenses" ),
//               actions: <Widget>[
//                 FlatButton(
//                   child: Text('Ok'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             )
//     );
//   }


//   void setupNotificationPlugin () async {
    
// // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
//     var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
//     var initializationSettingsIOS = IOSInitializationSettings(
//         onDidReceiveLocalNotification: onDidReceiveLocalNotification);
//     var initializationSettings = InitializationSettings(
//         initializationSettingsAndroid, initializationSettingsIOS);
//     await flutterLocalNotificationsPlugin.initialize(
//         initializationSettings,
//         onSelectNotification: onSelectNotification
//     ).then( ( init ) {
//       setupNotification();
//     });
//   }

//   void setupNotification() async{
//     var time = new Time( 19, 45, 0 );
//     var androidPlatformChannelSpecifics =
//     AndroidNotificationDetails(
//       'daily-notifications',
//       'Daily Notifications',
//       'Daily Notifications'
//     );
//     var iOSPlatformChannelSpecifics = IOSNotificationDetails();
//     var platformChannelSpecifics = NotificationDetails(
//     androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
//     await flutterLocalNotificationsPlugin.showDailyAtTime(
//       0,
//       'Spend-o-meter',
//       "Don't forget to add your expenses",
//       time,
//       platformChannelSpecifics
//     );
//   }

}