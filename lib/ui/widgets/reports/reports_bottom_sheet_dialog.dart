import 'package:flutter/material.dart';
import 'package:my_expenses/generated/i18n.dart';

class ReportsBottomSheetDialog extends StatelessWidget {
  final _selectedReportItem = "Pdf";

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return ["Csv", "Pdf"].map((item) {
      return DropdownMenuItem<String>(child: Text(item), value: item);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18n.of(context);

    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        // color: Colors.green,
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 15),
                child: SizedBox(
                  width: 100,
                  height: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            Text(
              i18n.exportFrom,
              style: Theme.of(context).textTheme.title,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
              ),
              child: Text('${i18n.startDate}:'),
            ),
            FlatButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2018),
                    lastDate: DateTime(2030),
                  );
                },
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "2012-10-30",
                  ),
                )),
            Text('${i18n.endDate}:'),
            FlatButton(
              onPressed: () {
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2018),
                  lastDate: DateTime(2030),
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("2019-10-30"),
              ),
            ),
            Text(i18n.reportFormat),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text(i18n.selectFormat),
                iconSize: 24,
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                value: _selectedReportItem,
                items: _buildDropdownItems(),
                onChanged: (newValue) {},
              ),
            ),
            /*Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select a format"),
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                value: _selectedReportItem,
                items: _buildDropdownItems(),
                onChanged: (newValue) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select a format"),
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                value: _selectedReportItem,
                items: _buildDropdownItems(),
                onChanged: (newValue) {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                hint: Text("Please select a format"),
                icon: Icon(Icons.arrow_downward),
                iconSize: 24,
                style: TextStyle(color: Colors.deepPurple),
                underline: Container(
                  height: 0,
                  color: Colors.transparent,
                ),
                value: _selectedReportItem,
                items: _buildDropdownItems(),
                onChanged: (newValue) {},
              ),
            ),
            */
            ButtonBar(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                OutlineButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    i18n.cancel,
                    style: TextStyle(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                RaisedButton(
                  color: theme.primaryColor,
                  child: Text(
                    i18n.generate,
                  ),
                  onPressed: () {},
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}