import 'package:flutter/material.dart';
import './transaction_item.dart';

class TransactionsCardContainer extends StatelessWidget {
  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "01/15 Thursday",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          RichText(
            text: TextSpan(
              // Note: Styles for TextSpans must be explicitly defined.
              // Child text spans will inherit styles from parent
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Expenses: 142',
                ),
                TextSpan(text: '  '),
                TextSpan(
                  text: 'Income: 0',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Divider(
              color: Colors.grey,
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: 3,
              itemBuilder: (context, _) {
                return TransactionItem();
              },
            )
          ],
        ),
      ),
    );
  }
}
