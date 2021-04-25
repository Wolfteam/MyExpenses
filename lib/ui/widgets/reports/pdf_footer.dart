import 'package:my_expenses/generated/l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfFooter extends StatelessWidget {
  final S i18n;

  PdfFooter(this.i18n);

  @override
  Widget build(Context context) {
    return Container(
      alignment: Alignment.centerRight,
      // margin: const EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
      child: Text(
        i18n.pageXOfY('${context.pageNumber}', '${context.pagesCount}'),
        style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
      ),
    );
  }
}
