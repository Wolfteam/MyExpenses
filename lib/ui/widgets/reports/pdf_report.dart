import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:my_expenses/generated/l10n.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../common/presentation/custom_assets.dart';
import '../../../models/transaction_item.dart';
import 'pdf_footer.dart';
import 'pdf_header.dart';
import 'pdf_summary.dart';
import 'pdf_transaction_table.dart';

Future<Document> buildPdf(
  String Function(double) formater,
  List<TransactionItem> transactions,
  S i18n,
  DateTime from,
  DateTime to,
) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final pdf = Document(
    pageMode: PdfPageMode.outlines,
    author: packageInfo.appName,
    creator: packageInfo.appName,
    keywords: '${i18n.transactions}, ${i18n.incomes}, ${i18n.expenses}',
    title: i18n.transactionsReport,
    theme: ThemeData.withFont(
      base: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansRegular),
      ),
      bold: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansBold),
      ),
      italic: Font.ttf(
        await rootBundle.load(CustomAssets.fontOpenSansItalic),
      ),
      boldItalic: Font.ttf(await rootBundle.load(CustomAssets.fontOpenSansBoldItalic)),
    ),
  );

  final imgBytes = await rootBundle.load(CustomAssets.appIcon);
  final img = image_lib.decodeImage(imgBytes.buffer.asUint8List());
  final resizedImg = image_lib.copyResize(img!, width: 120, height: 120);
  final image = PdfImage(
    pdf.document,
    image: resizedImg.data.buffer.asUint8List(),
    width: resizedImg.width,
    height: resizedImg.height,
  );
  // pdf.addPage(
  //   MultiPage(
  //     pageFormat: PdfPageFormat.letter,
  //     header: (ctx) => PdfHeader(i18n),
  //     footer: (ctx) => PdfFooter(i18n),
  //     build: (Context context) => <Widget>[
  //       Partition(
  //         // flex: 1618,
  //         child: Column(
  //           children: List<Widget>.generate(100, (int i) => Text('$i')),
  //         ),
  //       ),
  //       Partition(
  //         // flex: 1000,
  //         // width: 100,
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: List<Widget>.generate(20, (int i) => Text('$i')),
  //         ),
  //       ),
  //     ],
  //   ),
  // );

  // transactions.addAll([...transactions]);
//TODO: FIX THIS SHIT
  final page = MultiPage(
    margin: const EdgeInsets.only(
      left: 0.8 * PdfPageFormat.cm,
      top: 1 * PdfPageFormat.cm,
      right: 0.8 * PdfPageFormat.cm,
      bottom: 1 * PdfPageFormat.cm,
    ),
    pageFormat: PdfPageFormat.letter,
    maxPages: 100,
    header: (ctx) => PdfHeader(i18n),
    footer: (ctx) => PdfFooter(i18n),
    build: (ctx) => _buildPdfBody(
      ctx,
      pdf,
      packageInfo,
      image,
      transactions,
      i18n,
      from,
      to,
      formater,
    ),
  );

  pdf.addPage(page);

  return pdf;
}

List<Widget> _buildPdfBody(
  Context context,
  Document pdf,
  PackageInfo packageInfo,
  PdfImage img,
  List<TransactionItem> transactions,
  S i18n,
  DateTime from,
  DateTime to,
  String Function(double) formatter,
) {
  final summary = PdfSummary(packageInfo, img, transactions, i18n, from, to, formatter);

  final transactionsMap = _buildTransactionsPerMonth(transactions);
  if (transactionsMap.isEmpty) {
    return [
      summary,
      Padding(
        padding: const EdgeInsets.only(top: 30, right: 20, left: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              i18n.noTransactionsForThisPeriod,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ];
  }
  final tables = transactionsMap.entries.map((kvp) => PdfTransactionTable(kvp.value, i18n, formatter)).toList();
  return [
    summary,
    Partition(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: tables)),
  ];
}

Map<DateTime, List<TransactionItem>> _buildTransactionsPerMonth(
  List<TransactionItem> transactions,
) {
  final transPerMonth = <DateTime, List<TransactionItem>>{};

  for (final transaction in transactions) {
    final date = DateTime(transaction.transactionDate.year, transaction.transactionDate.month);

    if (transPerMonth.keys.any((key) => key == date)) {
      transPerMonth[date]!.add(transaction);
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
