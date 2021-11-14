import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfTransactionTable extends StatelessWidget {
  final List<TransactionItem> transactions;
  final ReportTranslations translations;
  final String Function(double) formatter;

  PdfTransactionTable(
    this.transactions,
    this.translations,
    this.formatter,
  );

  @override
  Widget build(Context context) {
    transactions.sort((x, y) => x.transactionDate.compareTo(y.transactionDate));

    final firstDate = transactions.first.transactionDate;
    final lastDate = transactions.last.transactionDate;
    final firstFormattedDate = DateUtils.formatDateWithoutLocale(firstDate, DateUtils.monthDayAndYearFormat);
    final lastFormattedDate = DateUtils.formatDateWithoutLocale(lastDate, DateUtils.monthDayAndYearFormat);

    final incomeAmount = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);
    final expenseAmount = TransactionUtils.getTotalTransactionAmounts(transactions);
    final balance = TransactionUtils.roundDouble(incomeAmount + expenseAmount);

    final rows = <TableRow>[
      //headers
      _buildRowHeader(context, translations),
      //rows
      ...transactions.asMap().map((index, t) => MapEntry(index, _buildRowItem(context, index + 1, t, translations, formatter))).values
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 5),
            child: Text(
              '${translations.period}: $firstFormattedDate - $lastFormattedDate',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: PdfColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Table(
            border: TableBorder.all(),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: rows,
          ),
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${translations.incomes}: ${formatter(incomeAmount)}',
                  style: TextStyle(
                    color: PdfColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${translations.expenses}: ${formatter(expenseAmount)}',
                  style: TextStyle(
                    color: PdfColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${translations.total}: ${formatter(balance)}',
                  style: TextStyle(
                    color: balance >= 0 ? PdfColors.green : PdfColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildRowHeader(Context context, ReportTranslations translations) {
    final tableCellHeaderStyle = Theme.of(context).tableHeader.copyWith(color: PdfColors.white);
    const headerCellPadding = EdgeInsets.all(5);
    return TableRow(
      children: [
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            '#',
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.description,
            textAlign: TextAlign.left,
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.amount,
            textAlign: TextAlign.center,
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.date,
            textAlign: TextAlign.center,
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.category,
            textAlign: TextAlign.center,
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.type,
            textAlign: TextAlign.right,
            style: tableCellHeaderStyle,
          ),
        ),
        Container(
          padding: headerCellPadding,
          alignment: Alignment.center,
          color: PdfColors.black,
          child: Text(
            translations.recurring,
            textAlign: TextAlign.right,
            style: tableCellHeaderStyle,
          ),
        ),
      ],
    );
  }

  TableRow _buildRowItem(
    Context context,
    int index,
    TransactionItem t,
    ReportTranslations translations,
    String Function(double) formatter,
  ) {
    final textStyle = Theme.of(context).tableCell;
    const cellPadding = EdgeInsets.symmetric(horizontal: 5);
    return TableRow(
      children: [
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            index.toString(),
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.centerLeft,
          child: Text(
            t.description,
            textAlign: TextAlign.left,
            style: textStyle,
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            formatter(t.amount),
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            DateUtils.formatDateWithoutLocale(
              t.transactionDate,
              DateUtils.monthDayAndYearFormat,
            ),
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            t.category.name,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            t.category.isAnIncome ? translations.income : translations.expense,
            textAlign: TextAlign.center,
            style: textStyle.copyWith(color: t.category.isAnIncome ? PdfColors.green : PdfColors.red),
          ),
        ),
        Container(
          padding: cellPadding,
          alignment: Alignment.center,
          child: Text(
            t.isChildTransaction ? translations.yes : translations.no,
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}
