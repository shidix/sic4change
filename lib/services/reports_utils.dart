import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class ReportPDF {
  Widget getCell(
    String text, {
    TextStyle style = const TextStyle(fontSize: 8, color: PdfColors.black),
    EdgeInsets padding = const EdgeInsets.all(5),
    TextAlign align = TextAlign.left,
    double height = 20.0,
  }) {
    return SizedBox(
        width: double.infinity, // Full width for the cell
        height: height, // Fixed height for the cell
        child: Container(
          width: double.infinity, // Full width for the cell
          decoration: style.background != null
              ? BoxDecoration(color: style.background!.color)
              : null,
          alignment: align == TextAlign.left
              ? Alignment.centerLeft
              : align == TextAlign.right
                  ? Alignment.centerRight
                  : Alignment.center,
          padding: padding,
          child: Text(
            text,
            style: style,
            textAlign: align,
          ),
        ));
  }

  TableRow getRow(List<String> texts,
      {List<TextStyle?> styles = const [],
      List<TextAlign?> aligns = const [],
      EdgeInsets padding = const EdgeInsets.all(5),
      double height = 20.0}) {
    if (styles.isEmpty) {
      styles = List.generate(texts.length,
          (index) => const TextStyle(fontSize: 10, color: PdfColors.black));
    }
    if (aligns.isEmpty) {
      aligns = List.generate(texts.length, (index) => TextAlign.left);
    }
    if (styles.length < texts.length) {
      styles.addAll(List.generate(
          texts.length - styles.length,
          (index) =>
              styles[styles.length - 1] ??
              const TextStyle(fontSize: 10, color: PdfColors.black)));
    }
    if (aligns.length < texts.length) {
      aligns.addAll(List.generate(texts.length - aligns.length,
          (index) => aligns[aligns.length - 1] ?? TextAlign.left));
    }

    return TableRow(
      verticalAlignment: TableCellVerticalAlignment.middle,
      children: texts.map((text) {
        int index = texts.indexOf(text);
        TextStyle style = styles.isNotEmpty && styles.length > index
            ? styles[index]!
            : const TextStyle(fontSize: 10, color: PdfColors.black);
        return getCell(text,
            style: style,
            padding: padding,
            height: height,
            align: aligns.isNotEmpty && aligns.length > index
                ? aligns[index]!
                : TextAlign.left);
      }).toList(),
    );
  }
}
