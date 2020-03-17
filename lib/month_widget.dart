import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_control_app/graph_widget.dart';
import 'package:expenses_control_app/pages/details_page_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum GraphType {
  LINES,
  PIE
}

class MonthWidget extends StatefulWidget {

  final List< DocumentSnapshot > documents;
  final double total;
  final List<double> perDay;
  final Map< String, double > categories;
  final GraphType graphType;
  final int month;

  // para inicializar una variable de tipo final lo podemos
  // realizar desde el constructor, antes de llamar al padre ( super )
  MonthWidget({Key key, this.documents, days, @required this.month, this.graphType }) :

    total = documents.map(( doc ) => doc['value'] )
                     .fold( 0.0, (previousValue, element) => previousValue + element ),
    perDay = List.generate( days, ( int index ) {
      return documents.where(( doc ) => doc[ 'day' ] == ( index + 1 )  )
                .map(( doc ) => doc['value'] )
                .fold( 0.0, (previousValue, element) => previousValue + element );
    }),
    categories = documents.fold({}, ( Map< String, double > map, document ) {
      if ( !map.containsKey( document['category'] ) ) {
        map[document['category']] = 0.0;
      }
      
      map[document['category']] += document['value'];

      return map;

    }),
    super(key: key);

  // para el cálculo del valor total hay que crear una 'cloud function' que permita crear
  // un acumulado por cada transacción que se realice
  @override
  _MonthWidgetState createState() => _MonthWidgetState();
}

class _MonthWidgetState extends State<MonthWidget> {
  @override
  Widget build(BuildContext context) {
    print( widget.categories );
    return Container(
       child: Expanded(
          child: Column(
           children: <Widget> [
            _expenses(),
            _graph(),
            Container(
              color: Colors.blueAccent.withOpacity( 0.15 ),
              height: 24.0,
            ),
            _list()
           ]
         ),
       ),
    );
  }

  Widget _expenses() {
    return Column(
      children: <Widget> [
        Text( 
          '\$${ widget.total.toStringAsFixed( 2 ) }',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40.0
          ),  
        ),
        Text( 
          'Total expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.0,
            color: Colors.blueGrey
          ),
        )
      ]
    );
  }

  Widget _graph() {
    if (widget.graphType == GraphType.LINES) {
      return Container(
        height: 250.0,
        child: LinesGraphWidget(
          data: widget.perDay,
        ),
      );
    } else {
      var perCategory = widget.categories.keys.map((valueCategory) => widget.categories[valueCategory] / widget.total).toList();
      return Container(
        height: 250.0,
        child: PieGraphWidget(
          data: perCategory,
        ),
      );
    }
  }

  // Widget _graph() {
  //   return Container(
  //     height: 250.0,
  //     child: GraphWidget(
  //       data: widget.perDay
  //     )
  //   );
  // }

  Widget _item( IconData icon, String category, int percent, double value ) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed( '/details', arguments: DetailsParams( category, widget.month ) );
      },
      leading: Icon( icon, color: Colors.blueAccent, size: 32.0, ),
      title: Text(category),
      subtitle: Text( '$percent% of expenses' ),
      trailing: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity( 0.2 ),
          borderRadius: BorderRadius.circular( 5.0 )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text( 
            '\$$value',
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.w500,
              fontSize: 16.0
            ),
          ),
        ),
        
      ),

    );
  }

  Widget _list() {
    return Expanded(
      child: ListView.separated(
        itemCount: widget.categories.length,
        itemBuilder: ( BuildContext context, int index ) { 
          var key = widget.categories.keys.elementAt( index );
          var data = widget.categories[ key ];
         return _item( FontAwesomeIcons.shoppingCart, key , 100 * data ~/ widget.total, data );
        },
        separatorBuilder: ( BuildContext context, int index ) {
          return Container(
            color: Colors.blueAccent.withOpacity( 0.15 ),
            height: 2.0
          );
        },
      ),
    );
  }

}