import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_control_app/pages/ui/day_expense_list_tile.dart';

class DetailsPage extends StatelessWidget {

  final String categoryName;
  final List<DocumentSnapshot> documents;
  final Function( String documentID ) onDelete;

  const DetailsPage( { Key key, this.categoryName, this.documents, this.onDelete } ) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( categoryName )
      ),
      body: ListView.builder(
              itemCount: documents.length,
              itemBuilder: ( BuildContext context, int index ) {
                var document = documents[ index ];
                return Dismissible(
                  key: Key( document.documentID ),
                  onDismissed: ( direction ) {
                    onDelete( document.documentID );
                  },
                  child: DayExpenseListTile(document: document),
                );
              },
      )
    );
  }
}