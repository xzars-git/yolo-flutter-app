import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/model/data_besaran_pajak.dart';
import 'package:ultralytics_yolo_example/model/nominal_pkb_model.dart';
import 'package:ultralytics_yolo_example/theme/theme_config.dart';
import 'package:ultralytics_yolo_example/util/date_formater/date_formater.dart';
import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class DetailTelusurMandiriOcrUtils {
  static List<Widget> listInformasiObjekPajak(DataKendaraan? dataKendaraan) {
    return [
      _oneData(
        "Nomor Polisi",
        trimStringStrip(
          "${dataKendaraan?.noPolisi1}-${dataKendaraan?.noPolisi2}-${dataKendaraan?.noPolisi3}",
        ),
      ),
      _oneData("Merek", trimStringStrip("${dataKendaraan?.nmMerekKb}")),
      _oneData("Model", trimStringStrip("${dataKendaraan?.nmModelKb}")),
      _oneData("Warna Kendaraan", trimStringStrip("${dataKendaraan?.warnaKb}")),
      _oneData("Tgl. Akhir Pajak", formatDateFull(dataKendaraan?.tgAkhirPajak)),
      _oneData("Tgl. Akhir STNK", formatDateFull(dataKendaraan?.tgAkhirStnk)),
      _oneData("Milik Ke - ", trimStringStrip("${dataKendaraan?.milikKe}")),
      _oneData("No. Whatsapp", trimStringStrip("${dataKendaraan?.noWa}")),
      _oneData("Email", trimStringStrip("${dataKendaraan?.email}")),
    ];
  }

  static List<Widget> listBesaranPajak(DataHitungPajak? dataHitungPajak) {
    NominalPkbModel nominalPkb = getNominalPkb(dataHitungPajak);
    return [
      _bodyBesaranPajak(title: "PKB", pokok: nominalPkb.pkbPokok, denda: nominalPkb.pkbDenda),
      _bodyBesaranPajak(
        title: "PKB (Opsen)",
        pokok: nominalPkb.opsenPkbPokok,
        denda: nominalPkb.opsenPkbDenda,
      ),
      _bodyBesaranPajak(
        title: "SWDKLLJ",
        pokok: nominalPkb.swdklljPokok,
        denda: nominalPkb.swdklljDenda,
      ),
      _bodyBesaranPajak(title: "PNBP STNK", pokok: nominalPkb.pnbpStnk, denda: ""),
      _bodyBesaranPajak(title: "PNBP TNKB", pokok: nominalPkb.pnbpTnkb, denda: ""),
    ];
  }
}

Widget _bodyBesaranPajak({required String title, required String pokok, required String denda}) {
  return IntrinsicHeight(
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: myTextTheme.bodySmall?.copyWith(color: gray600)),
        ),
        const VerticalDivider(color: Colors.transparent),
        Expanded(
          flex: title.contains("PNBP") ? 2 : 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Rp", style: myTextTheme.bodySmall?.copyWith(color: gray600)),
              Text(pokok, style: myTextTheme.bodyMedium),
            ],
          ),
        ),
        const VerticalDivider(color: Colors.transparent),
        if (!title.contains("PNBP"))
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Rp", style: myTextTheme.bodySmall?.copyWith(color: gray600)),
                Text(denda, style: myTextTheme.bodyMedium),
              ],
            ),
          ),
      ],
    ),
  );
}

Widget _oneData(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: myTextTheme.labelLarge),
      Text(value, style: myTextTheme.bodyMedium?.copyWith(color: gray600)),
    ],
  );
}
