import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DayExpenseListTile extends StatelessWidget {
  const DayExpenseListTile({
    Key key,
    @required this.document,
  }) : super(key: key);

  final DocumentSnapshot document;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: <Widget> [
          Icon( Icons.calendar_today, size: 40.0, color: Colors.blueAccent ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 8.0,
            child: Text(
              document['day'].toString(),
              textAlign: TextAlign.center,
            )
          )
        ]),
      title: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity( 0.2 ),
          borderRadius: BorderRadius.circular( 5.0 )
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text( 
            '\$${document['value'].toString()}',
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 16.0,
              fontWeight: FontWeight.w500
            ),
            textAlign: TextAlign.end,
          ),
        ),
      )
    );
  }
}