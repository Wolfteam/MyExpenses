import 'package:my_expenses/generated/l10n.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class PdfHeader extends StatelessWidget {
  final S i18n;

  PdfHeader(this.i18n);

  @override
  Widget build(Context context) {
    if (context.pageNumber == 1) {
      return Container();
    }
    return Container(
      alignment: Alignment.centerRight,
      // margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      // padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PdfColors.purple, width: 0.5)),
      ),
      child: Text(
        i18n.appName,
        style: Theme.of(context).defaultTextStyle.copyWith(color: PdfColors.grey),
      ),
    );
  }
}
