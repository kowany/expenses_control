import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenses_control_app/expenses_repository.dart';
import 'package:expenses_control_app/pages/details_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsParams {
  final String categoryName;
  final int month;

  DetailsParams(this.categoryName, this.month);
}

class DetailsPageContainer extends StatefulWidget {
  final DetailsParams params;

  const DetailsPageContainer({Key key, this.params}) : super(key: key);
  @override
  _DetailsPageContainerState createState() => _DetailsPageContainerState();
}

class _DetailsPageContainerState extends State<DetailsPageContainer> {
  Stream<QuerySnapshot> _query;

  @override
  Widget build(BuildContext context) {
    return Consumer< ExpensesRepository >(
      builder: ( BuildContext context, ExpensesRepository db, Widget child) { 
        _query = db.queryByCategory( widget.params.month + 1, widget.params.categoryName );
        return StreamBuilder<QuerySnapshot>(
            stream: _query,
            builder: ( BuildContext context, AsyncSnapshot<QuerySnapshot> data) {
              if ( data.connectionState == ConnectionState.waiting ) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator()
                  ),
                );
              } else {
                return DetailsPage( 
                  categoryName: widget.params.categoryName, 
                  documents: data.data.documents,
                  onDelete: ( documentID ) {
                    db.delete( documentID );
                  },
                );
              }
            });
      }
    );
  }
}