import 'dart:convert';

import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class DataBesaranPajakResult {
  final String? code;
  final DataKendaraan? data;
  final String? message;
  final bool? success;

  DataBesaranPajakResult({this.code, this.data, this.message, this.success});

  factory DataBesaranPajakResult.fromRawJson(String str) =>
      DataBesaranPajakResult.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DataBesaranPajakResult.fromJson(Map<String, dynamic> json) => DataBesaranPajakResult(
    code: json["code"],
    data: json["data"] == null ? null : DataKendaraan.fromJson(json["data"]),
    message: json["message"],
    success: json["success"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": data?.toJson(),
    "message": message,
    "success": success,
  };
}

class DataKendaraan {
  final bool? ableBayarEsamsat;
  final bool? ableBayarPajak;
  final String? alPemilik;
  final String? bobot;
  final DataHitungPajak? dataHitungPajak;
  final String? email;
  final String? jenisIdentitas;
  final String? kdFungsiKb;
  final String? kdMerekKb;
  final String? kdWil;
  final String? milikKe;
  final String? nilaiJual;
  final String? nmFungsiKb;
  final String? nmJenisKb;
  final String? nmMerekKb;
  final String? nmModelKb;
  final String? nmPemilik;
  final String? nmWil;
  final String? noIdentitas;
  final String? noMesin;
  final String? noPolisi1;
  final String? noPolisi2;
  final String? noPolisi3;
  final String? noRangka;
  final String? noHp;
  final String? noWa;
  final String? tgAkhirPajak;
  final String? tgAkhirStnk;
  final String? tgKepemilikan;
  final String? tgProsesTetap;
  final String? thBuatan;
  final String? warnaKb;
  final String? kodeBlockir;
  final String? kodeTerproteksi;

  DataKendaraan({
    this.ableBayarEsamsat,
    this.ableBayarPajak,
    this.alPemilik,
    this.bobot,
    this.dataHitungPajak,
    this.email,
    this.jenisIdentitas,
    this.kdFungsiKb,
    this.kdMerekKb,
    this.kdWil,
    this.milikKe,
    this.nilaiJual,
    this.nmFungsiKb,
    this.nmJenisKb,
    this.nmMerekKb,
    this.nmModelKb,
    this.nmPemilik,
    this.nmWil,
    this.noIdentitas,
    this.noMesin,
    this.noPolisi1,
    this.noPolisi2,
    this.noPolisi3,
    this.noRangka,
    this.noHp,
    this.noWa,
    this.tgAkhirPajak,
    this.tgAkhirStnk,
    this.tgKepemilikan,
    this.tgProsesTetap,
    this.thBuatan,
    this.warnaKb,
    this.kodeBlockir,
    this.kodeTerproteksi,
  });

  factory DataKendaraan.fromRawJson(String str) => DataKendaraan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DataKendaraan.fromJson(Map<String, dynamic> json) => DataKendaraan(
    ableBayarEsamsat: json["able_bayar_esamsat"],
    ableBayarPajak: json["able_bayar_pajak"],
    alPemilik: checkModel(json["al_pemilik"]),
    bobot: checkModel(json["bobot"]),
    dataHitungPajak: json["data_hitung_pajak"] == null
        ? null
        : DataHitungPajak.fromJson(json["data_hitung_pajak"]),
    email: checkModel(json["email"]),
    jenisIdentitas: checkModel(json["jenis_identitas"]),
    kdFungsiKb: checkModel(json["kd_fungsi_kb"]),
    kdMerekKb: checkModel(json["kd_merek_kb"]),
    kdWil: checkModel(json["kd_wil"]),
    milikKe: checkModel(json["milik_ke"]),
    nilaiJual: checkModel(json["nilai_jual"]),
    nmFungsiKb: checkModel(json["nm_fungsi_kb"]),
    nmJenisKb: checkModel(json["nm_jenis_kb"]),
    nmMerekKb: checkModel(json["nm_merek_kb"]),
    nmModelKb: checkModel(json["nm_model_kb"]),
    nmPemilik: checkModel(json["nm_pemilik"]),
    nmWil: checkModel(json["nm_wil"]),
    noIdentitas: checkModel(json["no_identitas"]),
    noMesin: checkModel(json["no_mesin"]),
    noPolisi1: checkModel(json["no_polisi1"]),
    noPolisi2: checkModel(json["no_polisi2"]),
    noPolisi3: checkModel(json["no_polisi3"]),
    noRangka: checkModel(json["no_rangka"]),
    noWa: checkModel(json["no_wa"]),
    noHp: checkModel(json["no_hp"]),
    tgAkhirPajak: checkModel(json["tg_akhir_pajak"]),
    tgAkhirStnk: checkModel(json["tg_akhir_stnk"]),
    tgKepemilikan: checkModel(json["tg_kepemilikan"]),
    tgProsesTetap: checkModel(json["tg_proses_tetap"]),
    thBuatan: checkModel(json["th_buatan"]),
    warnaKb: checkModel(json["warna_kb"]),
    kodeBlockir: checkModel(json["kd_blockir"]),
    kodeTerproteksi: checkModel(json["kd_proteksi"]),
  );

  Map<String, dynamic> toJson() => {
    "able_bayar_esamsat": ableBayarEsamsat,
    "able_bayar_pajak": ableBayarPajak,
    "al_pemilik": alPemilik,
    "bobot": bobot,
    "data_hitung_pajak": dataHitungPajak?.toJson(),
    "email": email,
    "jenis_identitas": jenisIdentitas,
    "kd_fungsi_kb": kdFungsiKb,
    "kd_merek_kb": kdMerekKb,
    "kd_wil": kdWil,
    "milik_ke": milikKe,
    "nilai_jual": nilaiJual,
    "nm_fungsi_kb": nmFungsiKb,
    "nm_jenis_kb": nmJenisKb,
    "nm_merek_kb": nmMerekKb,
    "nm_model_kb": nmModelKb,
    "nm_pemilik": nmPemilik,
    "nm_wil": nmWil,
    "no_identitas": noIdentitas,
    "no_mesin": noMesin,
    "no_polisi1": noPolisi1,
    "no_polisi2": noPolisi2,
    "no_polisi3": noPolisi3,
    "no_rangka": noRangka,
    "no_wa": noWa,
    "no_hp": noHp,
    "tg_akhir_pajak": tgAkhirPajak,
    "tg_akhir_stnk": tgAkhirStnk,
    "tg_kepemilikan": tgKepemilikan,
    "tg_proses_tetap": tgProsesTetap,
    "th_buatan": thBuatan,
    "warna_kb": warnaKb,
    "kd_blockir": kodeBlockir,
    "kd_proteksi": kodeTerproteksi,
  };
}

class DataHitungPajak {
  final String? beaAdmStnk;
  final String? beaAdmStnkNonprog;
  final String? beaAdmTnkb;
  final String? beaAdmTnkbNonprog;
  final String? beaBbnkb1Den;
  final String? beaBbnkb1DenNonprog;
  final String? beaBbnkb1Ops;
  final String? beaBbnkb1OpsDen;
  final String? beaBbnkb1OpsDenNonprog;
  final String? beaBbnkb1OpsNonprog;
  final String? beaBbnkb1Pok;
  final String? beaBbnkb1PokNonprog;
  final String? beaBbnkb2Den;
  final String? beaBbnkb2DenNonprog;
  final String? beaBbnkb2Ops;
  final String? beaBbnkb2OpsDen;
  final String? beaBbnkb2OpsDenNonprog;
  final String? beaBbnkb2OpsNonprog;
  final String? beaBbnkb2Pok;
  final String? beaBbnkb2PokNonprog;
  final String? beaPkbDen0;
  final String? beaPkbDen0Nonprog;
  final String? beaPkbDen1;
  final String? beaPkbDen1Nonprog;
  final String? beaPkbDen2;
  final String? beaPkbDen2Nonprog;
  final String? beaPkbDen3;
  final String? beaPkbDen3Nonprog;
  final String? beaPkbDen4;
  final String? beaPkbDen4Nonprog;
  final String? beaPkbDen5;
  final String? beaPkbDen5Nonprog;
  final String? beaPkbOps0;
  final String? beaPkbOps0Nonprog;
  final String? beaPkbOps1;
  final String? beaPkbOps1Nonprog;
  final String? beaPkbOps2;
  final String? beaPkbOps2Nonprog;
  final String? beaPkbOps3;
  final String? beaPkbOps3Nonprog;
  final String? beaPkbOps4;
  final String? beaPkbOps4Nonprog;
  final String? beaPkbOps5;
  final String? beaPkbOps5Nonprog;
  final String? beaPkbOpsDen0;
  final String? beaPkbOpsDen0Nonprog;
  final String? beaPkbOpsDen1;
  final String? beaPkbOpsDen1Nonprog;
  final String? beaPkbOpsDen2;
  final String? beaPkbOpsDen2Nonprog;
  final String? beaPkbOpsDen3;
  final String? beaPkbOpsDen3Nonprog;
  final String? beaPkbOpsDen4;
  final String? beaPkbOpsDen4Nonprog;
  final String? beaPkbOpsDen5;
  final String? beaPkbOpsDen5Nonprog;
  final String? beaPkbPok0;
  final String? beaPkbPok0Nonprog;
  final String? beaPkbPok1;
  final String? beaPkbPok1Nonprog;
  final String? beaPkbPok2;
  final String? beaPkbPok2Nonprog;
  final String? beaPkbPok3;
  final String? beaPkbPok3Nonprog;
  final String? beaPkbPok4;
  final String? beaPkbPok4Nonprog;
  final String? beaPkbPok5;
  final String? beaPkbPok5Nonprog;
  final String? beaSwdklljDen0;
  final String? beaSwdklljDen0Nonprog;
  final String? beaSwdklljDen1;
  final String? beaSwdklljDen1Nonprog;
  final String? beaSwdklljDen2;
  final String? beaSwdklljDen2Nonprog;
  final String? beaSwdklljDen3;
  final String? beaSwdklljDen3Nonprog;
  final String? beaSwdklljDen4;
  final String? beaSwdklljDen4Nonprog;
  final String? beaSwdklljDen5;
  final String? beaSwdklljDen5Nonprog;
  final String? beaSwdklljPok0;
  final String? beaSwdklljPok0Nonprog;
  final String? beaSwdklljPok1;
  final String? beaSwdklljPok1Nonprog;
  final String? beaSwdklljPok2;
  final String? beaSwdklljPok2Nonprog;
  final String? beaSwdklljPok3;
  final String? beaSwdklljPok3Nonprog;
  final String? beaSwdklljPok4;
  final String? beaSwdklljPok4Nonprog;
  final String? beaSwdklljPok5;
  final String? beaSwdklljPok5Nonprog;
  final String? bobot;
  final String? bobotLama;
  final String? jrRefId;
  final String? ket1;
  final String? ket2;
  final String? ket3;
  final String? kodeGolJr;
  final String? kodeJenisJr;
  final String? nilaiJual;
  final String? nilaiJualLama;
  final String? selangBulan;
  final String? selangHari;
  final String? selangTahun;
  final String? tgAkhirPajakBaru;
  final String? tgAkhirStnkBaru;

  DataHitungPajak({
    this.beaAdmStnk,
    this.beaAdmStnkNonprog,
    this.beaAdmTnkb,
    this.beaAdmTnkbNonprog,
    this.beaBbnkb1Den,
    this.beaBbnkb1DenNonprog,
    this.beaBbnkb1Ops,
    this.beaBbnkb1OpsDen,
    this.beaBbnkb1OpsDenNonprog,
    this.beaBbnkb1OpsNonprog,
    this.beaBbnkb1Pok,
    this.beaBbnkb1PokNonprog,
    this.beaBbnkb2Den,
    this.beaBbnkb2DenNonprog,
    this.beaBbnkb2Ops,
    this.beaBbnkb2OpsDen,
    this.beaBbnkb2OpsDenNonprog,
    this.beaBbnkb2OpsNonprog,
    this.beaBbnkb2Pok,
    this.beaBbnkb2PokNonprog,
    this.beaPkbDen0,
    this.beaPkbDen0Nonprog,
    this.beaPkbDen1,
    this.beaPkbDen1Nonprog,
    this.beaPkbDen2,
    this.beaPkbDen2Nonprog,
    this.beaPkbDen3,
    this.beaPkbDen3Nonprog,
    this.beaPkbDen4,
    this.beaPkbDen4Nonprog,
    this.beaPkbDen5,
    this.beaPkbDen5Nonprog,
    this.beaPkbOps0,
    this.beaPkbOps0Nonprog,
    this.beaPkbOps1,
    this.beaPkbOps1Nonprog,
    this.beaPkbOps2,
    this.beaPkbOps2Nonprog,
    this.beaPkbOps3,
    this.beaPkbOps3Nonprog,
    this.beaPkbOps4,
    this.beaPkbOps4Nonprog,
    this.beaPkbOps5,
    this.beaPkbOps5Nonprog,
    this.beaPkbOpsDen0,
    this.beaPkbOpsDen0Nonprog,
    this.beaPkbOpsDen1,
    this.beaPkbOpsDen1Nonprog,
    this.beaPkbOpsDen2,
    this.beaPkbOpsDen2Nonprog,
    this.beaPkbOpsDen3,
    this.beaPkbOpsDen3Nonprog,
    this.beaPkbOpsDen4,
    this.beaPkbOpsDen4Nonprog,
    this.beaPkbOpsDen5,
    this.beaPkbOpsDen5Nonprog,
    this.beaPkbPok0,
    this.beaPkbPok0Nonprog,
    this.beaPkbPok1,
    this.beaPkbPok1Nonprog,
    this.beaPkbPok2,
    this.beaPkbPok2Nonprog,
    this.beaPkbPok3,
    this.beaPkbPok3Nonprog,
    this.beaPkbPok4,
    this.beaPkbPok4Nonprog,
    this.beaPkbPok5,
    this.beaPkbPok5Nonprog,
    this.beaSwdklljDen0,
    this.beaSwdklljDen0Nonprog,
    this.beaSwdklljDen1,
    this.beaSwdklljDen1Nonprog,
    this.beaSwdklljDen2,
    this.beaSwdklljDen2Nonprog,
    this.beaSwdklljDen3,
    this.beaSwdklljDen3Nonprog,
    this.beaSwdklljDen4,
    this.beaSwdklljDen4Nonprog,
    this.beaSwdklljDen5,
    this.beaSwdklljDen5Nonprog,
    this.beaSwdklljPok0,
    this.beaSwdklljPok0Nonprog,
    this.beaSwdklljPok1,
    this.beaSwdklljPok1Nonprog,
    this.beaSwdklljPok2,
    this.beaSwdklljPok2Nonprog,
    this.beaSwdklljPok3,
    this.beaSwdklljPok3Nonprog,
    this.beaSwdklljPok4,
    this.beaSwdklljPok4Nonprog,
    this.beaSwdklljPok5,
    this.beaSwdklljPok5Nonprog,
    this.bobot,
    this.bobotLama,
    this.jrRefId,
    this.ket1,
    this.ket2,
    this.ket3,
    this.kodeGolJr,
    this.kodeJenisJr,
    this.nilaiJual,
    this.nilaiJualLama,
    this.selangBulan,
    this.selangHari,
    this.selangTahun,
    this.tgAkhirPajakBaru,
    this.tgAkhirStnkBaru,
  });

  factory DataHitungPajak.fromRawJson(String str) => DataHitungPajak.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DataHitungPajak.fromJson(Map<String, dynamic> json) => DataHitungPajak(
    beaAdmStnk: checkModel(json["bea_adm_stnk"]),
    beaAdmStnkNonprog: checkModel(json["bea_adm_stnk_nonprog"]),
    beaAdmTnkb: checkModel(json["bea_adm_tnkb"]),
    beaAdmTnkbNonprog: checkModel(json["bea_adm_tnkb_nonprog"]),
    beaBbnkb1Den: checkModel(json["bea_bbnkb1_den"]),
    beaBbnkb1DenNonprog: checkModel(json["bea_bbnkb1_den_nonprog"]),
    beaBbnkb1Ops: checkModel(json["bea_bbnkb1_ops"]),
    beaBbnkb1OpsDen: checkModel(json["bea_bbnkb1_ops_den"]),
    beaBbnkb1OpsDenNonprog: checkModel(json["bea_bbnkb1_ops_den_nonprog"]),
    beaBbnkb1OpsNonprog: checkModel(json["bea_bbnkb1_ops_nonprog"]),
    beaBbnkb1Pok: checkModel(json["bea_bbnkb1_pok"]),
    beaBbnkb1PokNonprog: checkModel(json["bea_bbnkb1_pok_nonprog"]),
    beaBbnkb2Den: checkModel(json["bea_bbnkb2_den"]),
    beaBbnkb2DenNonprog: checkModel(json["bea_bbnkb2_den_nonprog"]),
    beaBbnkb2Ops: checkModel(json["bea_bbnkb2_ops"]),
    beaBbnkb2OpsDen: checkModel(json["bea_bbnkb2_ops_den"]),
    beaBbnkb2OpsDenNonprog: checkModel(json["bea_bbnkb2_ops_den_nonprog"]),
    beaBbnkb2OpsNonprog: checkModel(json["bea_bbnkb2_ops_nonprog"]),
    beaBbnkb2Pok: checkModel(json["bea_bbnkb2_pok"]),
    beaBbnkb2PokNonprog: checkModel(json["bea_bbnkb2_pok_nonprog"]),
    beaPkbDen0: checkModel(json["bea_pkb_den0"]),
    beaPkbDen0Nonprog: checkModel(json["bea_pkb_den0_nonprog"]),
    beaPkbDen1: checkModel(json["bea_pkb_den1"]),
    beaPkbDen1Nonprog: checkModel(json["bea_pkb_den1_nonprog"]),
    beaPkbDen2: checkModel(json["bea_pkb_den2"]),
    beaPkbDen2Nonprog: checkModel(json["bea_pkb_den2_nonprog"]),
    beaPkbDen3: checkModel(json["bea_pkb_den3"]),
    beaPkbDen3Nonprog: checkModel(json["bea_pkb_den3_nonprog"]),
    beaPkbDen4: checkModel(json["bea_pkb_den4"]),
    beaPkbDen4Nonprog: checkModel(json["bea_pkb_den4_nonprog"]),
    beaPkbDen5: checkModel(json["bea_pkb_den5"]),
    beaPkbDen5Nonprog: checkModel(json["bea_pkb_den5_nonprog"]),
    beaPkbOps0: checkModel(json["bea_pkb_ops0"]),
    beaPkbOps0Nonprog: checkModel(json["bea_pkb_ops0_nonprog"]),
    beaPkbOps1: checkModel(json["bea_pkb_ops1"]),
    beaPkbOps1Nonprog: checkModel(json["bea_pkb_ops1_nonprog"]),
    beaPkbOps2: checkModel(json["bea_pkb_ops2"]),
    beaPkbOps2Nonprog: checkModel(json["bea_pkb_ops2_nonprog"]),
    beaPkbOps3: checkModel(json["bea_pkb_ops3"]),
    beaPkbOps3Nonprog: checkModel(json["bea_pkb_ops3_nonprog"]),
    beaPkbOps4: checkModel(json["bea_pkb_ops4"]),
    beaPkbOps4Nonprog: checkModel(json["bea_pkb_ops4_nonprog"]),
    beaPkbOps5: checkModel(json["bea_pkb_ops5"]),
    beaPkbOps5Nonprog: checkModel(json["bea_pkb_ops5_nonprog"]),
    beaPkbOpsDen0: checkModel(json["bea_pkb_ops_den0"]),
    beaPkbOpsDen0Nonprog: checkModel(json["bea_pkb_ops_den0_nonprog"]),
    beaPkbOpsDen1: checkModel(json["bea_pkb_ops_den1"]),
    beaPkbOpsDen1Nonprog: checkModel(json["bea_pkb_ops_den1_nonprog"]),
    beaPkbOpsDen2: checkModel(json["bea_pkb_ops_den2"]),
    beaPkbOpsDen2Nonprog: checkModel(json["bea_pkb_ops_den2_nonprog"]),
    beaPkbOpsDen3: checkModel(json["bea_pkb_ops_den3"]),
    beaPkbOpsDen3Nonprog: checkModel(json["bea_pkb_ops_den3_nonprog"]),
    beaPkbOpsDen4: checkModel(json["bea_pkb_ops_den4"]),
    beaPkbOpsDen4Nonprog: checkModel(json["bea_pkb_ops_den4_nonprog"]),
    beaPkbOpsDen5: checkModel(json["bea_pkb_ops_den5"]),
    beaPkbOpsDen5Nonprog: checkModel(json["bea_pkb_ops_den5_nonprog"]),
    beaPkbPok0: checkModel(json["bea_pkb_pok0"]),
    beaPkbPok0Nonprog: checkModel(json["bea_pkb_pok0_nonprog"]),
    beaPkbPok1: checkModel(json["bea_pkb_pok1"]),
    beaPkbPok1Nonprog: checkModel(json["bea_pkb_pok1_nonprog"]),
    beaPkbPok2: checkModel(json["bea_pkb_pok2"]),
    beaPkbPok2Nonprog: checkModel(json["bea_pkb_pok2_nonprog"]),
    beaPkbPok3: checkModel(json["bea_pkb_pok3"]),
    beaPkbPok3Nonprog: checkModel(json["bea_pkb_pok3_nonprog"]),
    beaPkbPok4: checkModel(json["bea_pkb_pok4"]),
    beaPkbPok4Nonprog: checkModel(json["bea_pkb_pok4_nonprog"]),
    beaPkbPok5: checkModel(json["bea_pkb_pok5"]),
    beaPkbPok5Nonprog: checkModel(json["bea_pkb_pok5_nonprog"]),
    beaSwdklljDen0: checkModel(json["bea_swdkllj_den0"]),
    beaSwdklljDen0Nonprog: checkModel(json["bea_swdkllj_den0_nonprog"]),
    beaSwdklljDen1: checkModel(json["bea_swdkllj_den1"]),
    beaSwdklljDen1Nonprog: checkModel(json["bea_swdkllj_den1_nonprog"]),
    beaSwdklljDen2: checkModel(json["bea_swdkllj_den2"]),
    beaSwdklljDen2Nonprog: checkModel(json["bea_swdkllj_den2_nonprog"]),
    beaSwdklljDen3: checkModel(json["bea_swdkllj_den3"]),
    beaSwdklljDen3Nonprog: checkModel(json["bea_swdkllj_den3_nonprog"]),
    beaSwdklljDen4: checkModel(json["bea_swdkllj_den4"]),
    beaSwdklljDen4Nonprog: checkModel(json["bea_swdkllj_den4_nonprog"]),
    beaSwdklljDen5: checkModel(json["bea_swdkllj_den5"]),
    beaSwdklljDen5Nonprog: checkModel(json["bea_swdkllj_den5_nonprog"]),
    beaSwdklljPok0: checkModel(json["bea_swdkllj_pok0"]),
    beaSwdklljPok0Nonprog: checkModel(json["bea_swdkllj_pok0_nonprog"]),
    beaSwdklljPok1: checkModel(json["bea_swdkllj_pok1"]),
    beaSwdklljPok1Nonprog: checkModel(json["bea_swdkllj_pok1_nonprog"]),
    beaSwdklljPok2: checkModel(json["bea_swdkllj_pok2"]),
    beaSwdklljPok2Nonprog: checkModel(json["bea_swdkllj_pok2_nonprog"]),
    beaSwdklljPok3: checkModel(json["bea_swdkllj_pok3"]),
    beaSwdklljPok3Nonprog: checkModel(json["bea_swdkllj_pok3_nonprog"]),
    beaSwdklljPok4: checkModel(json["bea_swdkllj_pok4"]),
    beaSwdklljPok4Nonprog: checkModel(json["bea_swdkllj_pok4_nonprog"]),
    beaSwdklljPok5: checkModel(json["bea_swdkllj_pok5"]),
    beaSwdklljPok5Nonprog: checkModel(json["bea_swdkllj_pok5_nonprog"]),
    bobot: checkModel(json["bobot"]),
    bobotLama: checkModel(json["bobot_lama"]),
    jrRefId: checkModel(json["jr_ref_id"]),
    ket1: checkModel(json["ket1"]),
    ket2: checkModel(json["ket2"]),
    ket3: checkModel(json["ket3"]),
    kodeGolJr: checkModel(json["kode_gol_jr"]),
    kodeJenisJr: checkModel(json["kode_jenis_jr"]),
    nilaiJual: checkModel(json["nilai_jual"]),
    nilaiJualLama: checkModel(json["nilai_jual_lama"]),
    selangBulan: checkModel(json["selang_bulan"]),
    selangHari: checkModel(json["selang_hari"]),
    selangTahun: checkModel(json["selang_tahun"]),
    tgAkhirPajakBaru: checkModel(json["tg_akhir_pajak_baru"]),
    tgAkhirStnkBaru: checkModel(json["tg_akhir_stnk_baru"]),
  );

  Map<String, dynamic> toJson() => {
    "bea_adm_stnk": beaAdmStnk,
    "bea_adm_stnk_nonprog": beaAdmStnkNonprog,
    "bea_adm_tnkb": beaAdmTnkb,
    "bea_adm_tnkb_nonprog": beaAdmTnkbNonprog,
    "bea_bbnkb1_den": beaBbnkb1Den,
    "bea_bbnkb1_den_nonprog": beaBbnkb1DenNonprog,
    "bea_bbnkb1_ops": beaBbnkb1Ops,
    "bea_bbnkb1_ops_den": beaBbnkb1OpsDen,
    "bea_bbnkb1_ops_den_nonprog": beaBbnkb1OpsDenNonprog,
    "bea_bbnkb1_ops_nonprog": beaBbnkb1OpsNonprog,
    "bea_bbnkb1_pok": beaBbnkb1Pok,
    "bea_bbnkb1_pok_nonprog": beaBbnkb1PokNonprog,
    "bea_bbnkb2_den": beaBbnkb2Den,
    "bea_bbnkb2_den_nonprog": beaBbnkb2DenNonprog,
    "bea_bbnkb2_ops": beaBbnkb2Ops,
    "bea_bbnkb2_ops_den": beaBbnkb2OpsDen,
    "bea_bbnkb2_ops_den_nonprog": beaBbnkb2OpsDenNonprog,
    "bea_bbnkb2_ops_nonprog": beaBbnkb2OpsNonprog,
    "bea_bbnkb2_pok": beaBbnkb2Pok,
    "bea_bbnkb2_pok_nonprog": beaBbnkb2PokNonprog,
    "bea_pkb_den0": beaPkbDen0,
    "bea_pkb_den0_nonprog": beaPkbDen0Nonprog,
    "bea_pkb_den1": beaPkbDen1,
    "bea_pkb_den1_nonprog": beaPkbDen1Nonprog,
    "bea_pkb_den2": beaPkbDen2,
    "bea_pkb_den2_nonprog": beaPkbDen2Nonprog,
    "bea_pkb_den3": beaPkbDen3,
    "bea_pkb_den3_nonprog": beaPkbDen3Nonprog,
    "bea_pkb_den4": beaPkbDen4,
    "bea_pkb_den4_nonprog": beaPkbDen4Nonprog,
    "bea_pkb_den5": beaPkbDen5,
    "bea_pkb_den5_nonprog": beaPkbDen5Nonprog,
    "bea_pkb_ops0": beaPkbOps0,
    "bea_pkb_ops0_nonprog": beaPkbOps0Nonprog,
    "bea_pkb_ops1": beaPkbOps1,
    "bea_pkb_ops1_nonprog": beaPkbOps1Nonprog,
    "bea_pkb_ops2": beaPkbOps2,
    "bea_pkb_ops2_nonprog": beaPkbOps2Nonprog,
    "bea_pkb_ops3": beaPkbOps3,
    "bea_pkb_ops3_nonprog": beaPkbOps3Nonprog,
    "bea_pkb_ops4": beaPkbOps4,
    "bea_pkb_ops4_nonprog": beaPkbOps4Nonprog,
    "bea_pkb_ops5": beaPkbOps5,
    "bea_pkb_ops5_nonprog": beaPkbOps5Nonprog,
    "bea_pkb_ops_den0": beaPkbOpsDen0,
    "bea_pkb_ops_den0_nonprog": beaPkbOpsDen0Nonprog,
    "bea_pkb_ops_den1": beaPkbOpsDen1,
    "bea_pkb_ops_den1_nonprog": beaPkbOpsDen1Nonprog,
    "bea_pkb_ops_den2": beaPkbOpsDen2,
    "bea_pkb_ops_den2_nonprog": beaPkbOpsDen2Nonprog,
    "bea_pkb_ops_den3": beaPkbOpsDen3,
    "bea_pkb_ops_den3_nonprog": beaPkbOpsDen3Nonprog,
    "bea_pkb_ops_den4": beaPkbOpsDen4,
    "bea_pkb_ops_den4_nonprog": beaPkbOpsDen4Nonprog,
    "bea_pkb_ops_den5": beaPkbOpsDen5,
    "bea_pkb_ops_den5_nonprog": beaPkbOpsDen5Nonprog,
    "bea_pkb_pok0": beaPkbPok0,
    "bea_pkb_pok0_nonprog": beaPkbPok0Nonprog,
    "bea_pkb_pok1": beaPkbPok1,
    "bea_pkb_pok1_nonprog": beaPkbPok1Nonprog,
    "bea_pkb_pok2": beaPkbPok2,
    "bea_pkb_pok2_nonprog": beaPkbPok2Nonprog,
    "bea_pkb_pok3": beaPkbPok3,
    "bea_pkb_pok3_nonprog": beaPkbPok3Nonprog,
    "bea_pkb_pok4": beaPkbPok4,
    "bea_pkb_pok4_nonprog": beaPkbPok4Nonprog,
    "bea_pkb_pok5": beaPkbPok5,
    "bea_pkb_pok5_nonprog": beaPkbPok5Nonprog,
    "bea_swdkllj_den0": beaSwdklljDen0,
    "bea_swdkllj_den0_nonprog": beaSwdklljDen0Nonprog,
    "bea_swdkllj_den1": beaSwdklljDen1,
    "bea_swdkllj_den1_nonprog": beaSwdklljDen1Nonprog,
    "bea_swdkllj_den2": beaSwdklljDen2,
    "bea_swdkllj_den2_nonprog": beaSwdklljDen2Nonprog,
    "bea_swdkllj_den3": beaSwdklljDen3,
    "bea_swdkllj_den3_nonprog": beaSwdklljDen3Nonprog,
    "bea_swdkllj_den4": beaSwdklljDen4,
    "bea_swdkllj_den4_nonprog": beaSwdklljDen4Nonprog,
    "bea_swdkllj_den5": beaSwdklljDen5,
    "bea_swdkllj_den5_nonprog": beaSwdklljDen5Nonprog,
    "bea_swdkllj_pok0": beaSwdklljPok0,
    "bea_swdkllj_pok0_nonprog": beaSwdklljPok0Nonprog,
    "bea_swdkllj_pok1": beaSwdklljPok1,
    "bea_swdkllj_pok1_nonprog": beaSwdklljPok1Nonprog,
    "bea_swdkllj_pok2": beaSwdklljPok2,
    "bea_swdkllj_pok2_nonprog": beaSwdklljPok2Nonprog,
    "bea_swdkllj_pok3": beaSwdklljPok3,
    "bea_swdkllj_pok3_nonprog": beaSwdklljPok3Nonprog,
    "bea_swdkllj_pok4": beaSwdklljPok4,
    "bea_swdkllj_pok4_nonprog": beaSwdklljPok4Nonprog,
    "bea_swdkllj_pok5": beaSwdklljPok5,
    "bea_swdkllj_pok5_nonprog": beaSwdklljPok5Nonprog,
    "bobot": bobot,
    "bobot_lama": bobotLama,
    "jr_ref_id": jrRefId,
    "ket1": ket1,
    "ket2": ket2,
    "ket3": ket3,
    "kode_gol_jr": kodeGolJr,
    "kode_jenis_jr": kodeJenisJr,
    "nilai_jual": nilaiJual,
    "nilai_jual_lama": nilaiJualLama,
    "selang_bulan": selangBulan,
    "selang_hari": selangHari,
    "selang_tahun": selangTahun,
    "tg_akhir_pajak_baru": tgAkhirPajakBaru,
    "tg_akhir_stnk_baru": tgAkhirStnkBaru,
  };
}
