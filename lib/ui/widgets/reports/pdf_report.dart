import 'package:flutter/services.dart';
import 'package:image/image.dart' as image_lib;
import 'package:package_info/package_info.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../common/presentation/custom_assets.dart';
import '../../../common/utils/date_utils.dart';
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

  final header = Row(
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
          ],
        ),
      ),
      Image(
        img,
      ),
    ],
  );

  final rows = <TableRow>[
    //headers
    _buildRowHeader(i18n),
    //rows
    ...transactions
        .asMap()
        .map((index, t) => MapEntry(index, _buildRowItem(t, i18n)))
        .values
  ];

  final table = Table(
    border: const TableBorder(),
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: rows,
  );
  return [
    Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        padding: const EdgeInsets.only(
          bottom: 20,
        ),
        child: header,
      ),
    ),
    table,
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
        i18n.id,
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
        i18n.categoryName,
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
  ]);
}

TableRow _buildRowItem(
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
          t.id.toString(),
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
    ],
  );
}
