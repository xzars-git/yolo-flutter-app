import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/util/date_formater/date_formater.dart';
import 'package:ultralytics_yolo_example/util/formater/formater.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class PajakPdfGenerator {
  static Future<Uint8List> generate(
    DataKendaraan dataKendaraan,
    DataHitungPajak? dataHitungPajak,
  ) async {
    final pdf = pw.Document();

    // Ambil data besaran pajak dari model
    final nominalPkb = getNominalPkb(dataHitungPajak);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll57,
        margin: pw.EdgeInsets.zero,
        build: (context) {
          return pw.Container(
            color: PdfColors.white,
            padding: pw.EdgeInsets.zero,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'DOKUMEN NOMINAL PAJAK',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                      ),
                      pw.Text(
                        'PEMERINTAH PROVINSI JAWA BARAT',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                      ),
                      pw.Text(
                        'BADAN PENDAPATAN',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 2.0),
                pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 2),
                pw.SizedBox(height: 2.0),
                pw.Text(
                  'Informasi Objek Pajak',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                ),
                pw.SizedBox(height: 2),
                // Tampilkan dua _oneDataPdf per baris
                () {
                  final items = [
                    _oneDataPdf(
                      'Nomor Polisi',
                      trimStringStrip(
                        "${dataKendaraan.noPolisi1}-${dataKendaraan.noPolisi2}-${dataKendaraan.noPolisi3}",
                      ),
                    ),
                    _oneDataPdf('Merek', trimStringStrip("${dataKendaraan.nmMerekKb}")),
                    _oneDataPdf('Model', trimStringStrip("${dataKendaraan.nmModelKb}")),
                    _oneDataPdf('Warna Kendaraan', trimStringStrip("${dataKendaraan.warnaKb}")),
                    _oneDataPdf('Tgl. Akhir Pajak', formatDateFull(dataKendaraan.tgAkhirPajak)),
                    _oneDataPdf('Tgl. Akhir STNK', formatDateFull(dataKendaraan.tgAkhirStnk)),
                    _oneDataPdf('Milik Ke - ', trimStringStrip("${dataKendaraan.milikKe}")),
                    _oneDataPdf('No. Whatsapp', trimStringStrip("${dataKendaraan.noWa}")),
                    _oneDataPdf('Email', trimStringStrip("${dataKendaraan.email}")),
                  ];

                  return pw.Column(
                    children: [
                      for (var i = 0; i < items.length; i += 2)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 2),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Expanded(child: items[i]),
                              pw.SizedBox(width: 4),
                              pw.Expanded(
                                child: i + 1 < items.length ? items[i + 1] : pw.Container(),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }(),
                pw.Divider(borderStyle: pw.BorderStyle.dashed, height: 2),
                pw.SizedBox(height: 2.0),
                pw.Text(
                  'Informasi Besaran Pajak',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                ),
                pw.SizedBox(height: 2),
                pw.Container(
                  padding: const pw.EdgeInsets.all(2),
                  height: 10,
                  child: pw.Row(
                    children: [
                      pw.Expanded(child: pw.Container()),
                      pw.VerticalDivider(thickness: 0.3, width: 1),
                      pw.Expanded(
                        child: pw.Text(
                          'Pokok',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                      pw.VerticalDivider(thickness: 0.3, width: 1),
                      pw.Expanded(
                        child: pw.Text(
                          'Denda',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 2.0),
                pw.Divider(thickness: 0.1, height: 2),
                pw.SizedBox(height: 2.0),
                _rowDataPdf(title: 'PKB', pokok: nominalPkb.pkbPokok, denda: nominalPkb.pkbDenda),
                _rowDataPdf(
                  title: 'PKB (Opsen)',
                  pokok: nominalPkb.opsenPkbPokok,
                  denda: nominalPkb.opsenPkbDenda,
                ),
                _rowDataPdf(
                  title: 'SWDKLLJ',
                  pokok: nominalPkb.swdklljPokok,
                  denda: nominalPkb.swdklljDenda,
                ),
                _rowDataPdf(title: 'PNBP STNK', pokok: nominalPkb.pnbpStnk, denda: ''),
                _rowDataPdf(title: 'PNBP TNKB', pokok: nominalPkb.pnbpTnkb, denda: ''),
                pw.Divider(thickness: 0.1, height: 2),
                pw.SizedBox(height: 2.0),
                pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              'TOTAL',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                            ),
                          ),
                          pw.Text(
                            ':',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 2.0),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Rp',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              formatMoney(nominalPkb.total),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

// Helper untuk informasi objek pajak di PDF
pw.Widget _oneDataPdf(String title, String value) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(title, style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold)),
      pw.Text(value, style: const pw.TextStyle(fontSize: 6)),
    ],
  );
}

pw.Widget _rowDataPdf({required String title, required String pokok, required String denda}) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Text(
            title,
            textAlign: pw.TextAlign.left,
            style: const pw.TextStyle(fontSize: 6),
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Rp", textAlign: pw.TextAlign.left, style: const pw.TextStyle(fontSize: 6)),
              pw.Expanded(
                child: pw.Text(
                  formatMoney(pokok),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(fontSize: 6),
                ),
              ),
            ],
          ),
        ),
      ),
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(2),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Rp", textAlign: pw.TextAlign.left, style: const pw.TextStyle(fontSize: 6)),
              pw.Expanded(
                child: pw.Text(
                  formatMoney(denda),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(fontSize: 6),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
