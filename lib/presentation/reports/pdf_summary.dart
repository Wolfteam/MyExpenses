import 'package:my_expenses/domain/models/models.dart';
import 'package:my_expenses/domain/utils/date_utils.dart';
import 'package:my_expenses/domain/utils/transaction_utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfSummary extends StatelessWidget {
  final String version;
  final PdfImage img;
  final List<TransactionItem> transactions;
  final ReportTranslations translations;
  final DateTime from;
  final DateTime to;
  final String Function(double) formatter;

  PdfSummary(
    this.version,
    this.img,
    this.transactions,
    this.translations,
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
    final expenseAmount = TransactionUtils.getTotalTransactionAmounts(transactions);
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
                  translations.transactionsReport,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${translations.period}: $fromString - $toString',
                  style: TextStyle(
                    color: PdfColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  translations.generatedOn(generatedOn),
                  style: TextStyle(
                    color: PdfColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  translations.appVersion(version),
                  style: TextStyle(
                    color: PdfColors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
          Image(ImageProxy(img)),
        ],
      ),
    );
  }
}
