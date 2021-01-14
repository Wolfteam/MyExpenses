import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:package_info/package_info.dart';

import '../../../common/utils/date_utils.dart';
import '../../../common/utils/transaction_utils.dart';
import '../../../generated/i18n.dart';
import '../../../models/transaction_item.dart';

class PdfSummary extends StatelessWidget {
  final PackageInfo packageInfo;
  final PdfImage img;
  final List<TransactionItem> transactions;
  final I18n i18n;
  final DateTime from;
  final DateTime to;
  final String Function(double) formatter;

  PdfSummary(
    this.packageInfo,
    this.img,
    this.transactions,
    this.i18n,
    this.from,
    this.to,
    this.formatter,
  );

  @override
  Widget build(Context context) {
    final generatedOn = DateUtils.formatDateWithoutLocale(DateTime.now(), DateUtils.monthDayYearAndHourFormat);

    final fromString = DateUtils.formatDateWithoutLocale(from, DateUtils.monthDayAndYearFormat);

    final toString = DateUtils.formatDateWithoutLocale(to, DateUtils.monthDayAndYearFormat);

    final incomeAmount = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: true);

    final expenseAmount = TransactionUtils.getTotalTransactionAmounts(transactions, onlyIncomes: false);

    final balance = TransactionUtils.roundDouble(incomeAmount + expenseAmount);

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              border: Border(
                bottom: BorderSide(color: PdfColors.pink),
                left: BorderSide(color: PdfColors.pink),
                right: BorderSide(color: PdfColors.pink),
                top: BorderSide(color: PdfColors.pink),
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
                  i18n.appVersion(packageInfo.version),
                  style: TextStyle(
                    color: PdfColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${i18n.incomes}: ${formatter(incomeAmount)}',
                  style: TextStyle(
                    color: PdfColors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${i18n.expenses}: ${formatter(expenseAmount)}',
                  style: TextStyle(
                    color: PdfColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${i18n.total}: ${formatter(balance)}',
                  style: TextStyle(
                    color: balance >= 0 ? PdfColors.green : PdfColors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Image(ImageProxy(img)),
        ],
      ),
    );
  }
}
