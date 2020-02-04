import 'package:flutter/material.dart';

class ReportsBottomSheetDialog extends StatelessWidget {
  final _selectedReportItem = "Pdf";

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return ["Csv", "Pdf"].map((item) {
      return DropdownMenuItem<String>(child: Text(item), value: item);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        // color: Colors.green,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(
              child: SizedBox(
                width: 100,
                height: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Text(
              "Export from",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("Start date:"),
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
            Text("End date:"),
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
            Text("Report format"),
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
              buttonPadding: EdgeInsets.symmetric(horizontal: 20),
              children: <Widget>[
                OutlineButton(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RaisedButton(
                  color: Colors.blue,
                  child: Text(
                    "Generate",
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
