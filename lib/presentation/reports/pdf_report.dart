import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/presentation/reports/pdf_footer.dart';
import 'package:my_expenses/presentation/reports/pdf_header.dart';
import 'package:my_expenses/presentation/reports/pdf_summary.dart';
import 'package:my_expenses/presentation/reports/pdf_transaction_table.dart';
import 'package:my_expenses/presentation/shared/custom_assets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

Future<Document> buildPdf(
  String Function(double) formatter,
  List<TransactionItem> transactions,
  ReportTranslations translations,
  DateTime from,
  DateTime to,
  String appName,
  String version,
) async {
  final pdf = Document(
    pageMode: PdfPageMode.outlines,
    author: appName,
    creator: appName,
    keywords: '${translations.transactions}, ${translations.incomes}, ${translations.expenses}',
    title: translations.transactionsReport,
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
    image: resizedImg.data!.buffer.asUint8List(),
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
    header: (ctx) => PdfHeader(translations),
    footer: (ctx) => PdfFooter(translations),
    build: (ctx) => _buildPdfBody(ctx, pdf, version, image, transactions, translations, from, to, formatter),
  );

  pdf.addPage(page);

  return pdf;
}

List<Widget> _buildPdfBody(
  Context context,
  Document pdf,
  String version,
  PdfImage img,
  List<TransactionItem> transactions,
  ReportTranslations translations,
  DateTime from,
  DateTime to,
  String Function(double) formatter,
) {
  final summary = PdfSummary(version, img, transactions, translations, from, to, formatter);

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
              translations.noTransactionsForThisPeriod,
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
  final tables = transactionsMap.entries.map((kvp) => PdfTransactionTable(kvp.value, translations, formatter)).toList();
  return [
    summary,
    Partition(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: tables)),
  ];
}

Map<DateTime, List<TransactionItem>> _buildTransactionsPerMonth(List<TransactionItem> transactions) {
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
