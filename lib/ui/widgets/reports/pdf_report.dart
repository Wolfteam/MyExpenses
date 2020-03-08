import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:package_info/package_info.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../common/presentation/custom_assets.dart';
import '../../../common/utils/date_utils.dart';
import '../../../common/utils/transaction_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/transaction_item.dart';

Future<Document> buildPdf(
  List<TransactionItem> transactions,
  I18n i18n,
  DateTime from,
  DateTime to,
) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final pdf = Document(
    author: packageInfo.appName,
    creator: packageInfo.appName,
    keywords: '${i18n.transactions}, ${i18n.incomes}, ${i18n.expenses}',
    title: i18n.transactionsReport,
    theme: Theme.withFont(
      base: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansRegular),
      ),
      bold: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansBold),
      ),
      italic: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansItalic),
      ),
      boldItalic:
          Font.ttf(await rootBundle.load(CustomAssets.fontOpenSansBoldItalic)),
    ),
  );
  final imgBytes = await rootBundle.load(CustomAssets.appIcon);
  final img = image_lib.decodeImage(imgBytes.buffer.asUint8List());
  final resizedImg = image_lib.copyResize(img, width: 120, height: 120);
  final image = PdfImage(
    pdf.document,
    image: resizedImg.data.buffer.asUint8List(),
    width: resizedImg.width,
    height: resizedImg.height,
  );

  pdf.addPage(
    MultiPage(
      pageFormat: PdfPageFormat.letter,
      header: (ctx) => _buildPdfHeader(ctx, i18n),
      footer: (ctx) => _buildPdfFooter(ctx, i18n),
      build: (ctx) => _buildPdfBody(
        ctx,
        pdf,
        packageInfo,
        image,
        transactions,
        i18n,
        from,
        to,
      ),
    ),
  );

  return pdf;
}

Widget _buildPdfHeader(
  Context context,
  I18n i18n,
) {
  if (context.pageNumber == 1) {
    return null;
  }
  return Container(
    alignment: Alignment.centerRight,
    margin: const EdgeInsets.only(
      bottom: 3.0 * PdfPageFormat.mm,
    ),
    padding: const EdgeInsets.only(
      bottom: 3.0 * PdfPageFormat.mm,
    ),
    decoration: const BoxDecoration(
      border: BoxBorder(
        bottom: true,
        width: 0.5,
        color: PdfColors.grey,
      ),
    ),
    child: Text(
      i18n.appName,
      style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
    ),
  );
}

Widget _buildPdfFooter(
  Context context,
  I18n i18n,
) {
  return Container(
    alignment: Alignment.centerRight,
    margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
    child: Text(
      i18n.pageXOfY('${context.pageNumber}', '${context.pagesCount}'),
      style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
    ),
  );
}

List<Widget> _buildPdfBody(
  Context context,
  Document pdf,
  PackageInfo packageInfo,
  PdfImage img,
  List<TransactionItem> transactions,
  I18n i18n,
  DateTime from,
  DateTime to,
) {
  final generatedOn = DateUtils.formatDateWithoutLocale(
    DateTime.now(),
    DateUtils.monthDayYearAndHourFormat,
  );

  final fromString = DateUtils.formatDateWithoutLocale(
    from,
    DateUtils.monthDayAndYearFormat,
  );

  final toString = DateUtils.formatDateWithoutLocale(
    to,
    DateUtils.monthDayAndYearFormat,
  );

  final incomeAmount = TransactionUtils.getTotalTransactionAmounts(
    transactions,
    onlyIncomes: true,
  );

  final expenseAmount = TransactionUtils.getTotalTransactionAmounts(
    transactions,
    onlyIncomes: false,
  );

  final balance = TransactionUtils.roundDouble(incomeAmount + expenseAmount);

  final summary = Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: 5,
          shape: BoxShape.rectangle,
          border: BoxBorder(
            color: PdfColors.black,
            bottom: true,
            left: true,
            right: true,
            top: true,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              i18n.transactionsReport,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${i18n.period}: $fromString - $toString',
              style: TextStyle(
                color: PdfColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              i18n.generatedOn(generatedOn),
              style: TextStyle(
                color: PdfColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${i18n.appVersion(packageInfo.version)}',
              style: TextStyle(
                color: PdfColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${i18n.incomes}: \$ $incomeAmount',
              style: TextStyle(
                color: PdfColors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${i18n.expenses}: \$ $expenseAmount',
              style: TextStyle(
                color: PdfColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${i18n.total}: \$ $balance',
              style: TextStyle(
                color: balance >= 0 ? PdfColors.green : PdfColors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      Image(
        img,
      ),
    ],
  );

  final transactionsMap = _buildTransactionsPerMonth(transactions);
  final tables = transactionsMap.entries
      .map((kvp) => _buildTable(kvp.key, kvp.value, i18n));

  return [
    Align(
      alignment: Alignment.centerLeft,
      child: summary,
    ),
    ...tables,
  ];
}

TableRow _buildRowHeader(I18n i18n) {
  const tableCellHeaderStyle = TextStyle(color: PdfColors.white);
  const headerCellPadding = EdgeInsets.all(5);
  return TableRow(children: [
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
        i18n.description,
        textAlign: TextAlign.left,
        style: tableCellHeaderStyle,
      ),
    ),
    Container(
      padding: headerCellPadding,
      alignment: Alignment.center,
      color: PdfColors.black,
      child: Text(
        i18n.amount,
        textAlign: TextAlign.center,
        style: tableCellHeaderStyle,
      ),
    ),
    Container(
      padding: headerCellPadding,
      alignment: Alignment.center,
      color: PdfColors.black,
      child: Text(
        i18n.date,
        textAlign: TextAlign.center,
        style: tableCellHeaderStyle,
      ),
    ),
    Container(
      padding: headerCellPadding,
      alignment: Alignment.center,
      color: PdfColors.black,
      child: Text(
        i18n.category,
        textAlign: TextAlign.center,
        style: tableCellHeaderStyle,
      ),
    ),
    Container(
      padding: headerCellPadding,
      alignment: Alignment.center,
      color: PdfColors.black,
      child: Text(
        i18n.type,
        textAlign: TextAlign.right,
        style: tableCellHeaderStyle,
      ),
    ),
    Container(
      padding: headerCellPadding,
      alignment: Alignment.center,
      color: PdfColors.black,
      child: Text(
        i18n.recurring,
        textAlign: TextAlign.right,
        style: tableCellHeaderStyle,
      ),
    ),
  ]);
}

TableRow _buildRowItem(
  int index,
  TransactionItem t,
  I18n i18n,
) {
  const cellPadding = EdgeInsets.symmetric(horizontal: 5);
  return TableRow(
    children: [
      Container(
        padding: cellPadding,
        alignment: Alignment.center,
        child: Text(
          index.toString(),
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: cellPadding,
        alignment: Alignment.centerLeft,
        child: Text(
          t.description,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: cellPadding,
        alignment: Alignment.center,
        child: Text(
          '${t.amount} \$',
          textAlign: TextAlign.center,
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
        ),
      ),
      Container(
        padding: cellPadding,
        alignment: Alignment.center,
        child: Text(
          t.category.name,
          textAlign: TextAlign.center,
        ),
      ),
      Container(
        padding: cellPadding,
        alignment: Alignment.center,
        child: Text(
          t.category.isAnIncome ? i18n.income : i18n.expense,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: t.category.isAnIncome ? PdfColors.green : PdfColors.red,
          ),
        ),
      ),
      Container(
        padding: cellPadding,
        alignment: Alignment.center,
        child: Text(
          t.isChildTransaction ? i18n.yes : i18n.no,
          textAlign: TextAlign.center,
        ),
      ),
    ],
  );
}

Widget _buildTable(
  DateTime date,
  List<TransactionItem> transactions,
  I18n i18n,
) {
  final firstDate = DateUtils.getFirstDayDateOfTheMonth(date);
  final lastDate = DateUtils.getLastDayDateOfTheMonth(date);
  final firstFormattedDate = DateUtils.formatDateWithoutLocale(
    firstDate,
    DateUtils.monthDayAndYearFormat,
  );
  final lastFormattedDate = DateUtils.formatDateWithoutLocale(
    lastDate,
    DateUtils.monthDayAndYearFormat,
  );

  final incomeAmount = TransactionUtils.getTotalTransactionAmounts(
    transactions,
    onlyIncomes: true,
  );
  final expenseAmount = TransactionUtils.getTotalTransactionAmounts(
    transactions,
    onlyIncomes: false,
  );
  final balance = TransactionUtils.roundDouble(incomeAmount + expenseAmount);

  final rows = <TableRow>[
    //headers
    _buildRowHeader(i18n),
    //rows
    ...transactions
        .asMap()
        .map((index, t) => MapEntry(index, _buildRowItem(index + 1, t, i18n)))
        .values
  ];
  return Container(
    margin: const EdgeInsets.symmetric(
      vertical: 20,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          alignment: Alignment.centerRight,
          margin: const EdgeInsets.only(bottom: 5),
          child: Text(
            '${i18n.period}: $firstFormattedDate - $lastFormattedDate',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: PdfColors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Table(
          border: const TableBorder(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: rows,
        ),
        Container(
          alignment: Alignment.centerRight,
          // decoration: const BoxDecoration(
          //   borderRadius: 5,
          //   border: BoxBorder(
          //     bottom: true,
          //     right: true,
          //     top: true,
          //     left: true,
          //   ),
          // ),
          margin: const EdgeInsets.only(top: 5),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${i18n.incomes}: \$ $incomeAmount',
                style: TextStyle(
                  color: PdfColors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${i18n.expenses}: \$ $expenseAmount',
                style: TextStyle(
                  color: PdfColors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${i18n.total}: \$ $balance',
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

Map<DateTime, List<TransactionItem>> _buildTransactionsPerMonth(
  List<TransactionItem> transactions,
) {
  final transPerMonth = <DateTime, List<TransactionItem>>{};

  for (final transaction in transactions) {
    final date = DateTime(
      transaction.transactionDate.year,
      transaction.transactionDate.month,
    );

    if (transPerMonth.keys.any((key) => key == date)) {
      transPerMonth[date].add(transaction);
    } else {
      transPerMonth.addAll({
        date: [transaction]
      });
    }
  }

  return SplayTreeMap<DateTime, List<TransactionItem>>.from(
    transPerMonth,
    (a, b) => a.compareTo(b),
  );
}
