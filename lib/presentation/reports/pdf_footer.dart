import 'package:my_expenses/domain/models/models.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfFooter extends StatelessWidget {
  final ReportTranslations translations;

  PdfFooter(this.translations);

  @override
  Widget build(Context context) {
    return Container(
      alignment: Alignment.centerRight,
      // margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: Text(
        translations.pageXOfY(context.pageNumber, context.pagesCount),
        style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
      ),
    );
  }
}
