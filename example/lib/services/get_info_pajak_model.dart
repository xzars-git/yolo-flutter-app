class GetInfoPajak {
	String? code;
	Data? data;
	String? message;
	Param? param;
	bool? success;

	GetInfoPajak({this.code, this.data, this.message, this.param, this.success});

	GetInfoPajak.fromJson(Map<String, dynamic> json) {
		code = json['code'];
		data = json['data'] != null ? new Data.fromJson(json['data']) : null;
		message = json['message'];
		param = json['param'] != null ? new Param.fromJson(json['param']) : null;
		success = json['success'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['code'] = this.code;
		if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
		data['message'] = this.message;
		if (this.param != null) {
      data['param'] = this.param!.toJson();
    }
		data['success'] = this.success;
		return data;
	}
}

class Data {
	bool? ableBayarEsamsat;
	bool? ableBayarPajak;
	String? alPemilik;
	String? bobot;
	DataHitungPajak? dataHitungPajak;
	String? email;
	String? jenisIdentitas;
	String? kdBlockir;
	String? kdFungsiKb;
	String? kdMerekKb;
	String? kdProteksi;
	String? kdWil;
	int? milikKe;  // ✅ FIXED: API returns int (e.g., 2)
	String? nilaiJual;
	String? nmFungsiKb;
	String? nmJenisKb;
	String? nmMerekKb;
	String? nmModelKb;
	String? nmPemilik;
	String? nmWil;
	String? noHp;
	String? noIdentitas;
	String? noMesin;
	String? noPolisi1;
	String? noPolisi2;
	String? noPolisi3;
	String? noRangka;
	String? noWa;
	String? tgAkhirPajak;
	String? tgAkhirStnk;
	String? tgKepemilikan;
	String? tgProsesTetap;
	int? thBuatan;  // ✅ FIXED: API returns int (e.g., 2022)
	String? warnaKb;

	Data({this.ableBayarEsamsat, this.ableBayarPajak, this.alPemilik, this.bobot, this.dataHitungPajak, this.email, this.jenisIdentitas, this.kdBlockir, this.kdFungsiKb, this.kdMerekKb, this.kdProteksi, this.kdWil, this.milikKe, this.nilaiJual, this.nmFungsiKb, this.nmJenisKb, this.nmMerekKb, this.nmModelKb, this.nmPemilik, this.nmWil, this.noHp, this.noIdentitas, this.noMesin, this.noPolisi1, this.noPolisi2, this.noPolisi3, this.noRangka, this.noWa, this.tgAkhirPajak, this.tgAkhirStnk, this.tgKepemilikan, this.tgProsesTetap, this.thBuatan, this.warnaKb});

	Data.fromJson(Map<String, dynamic> json) {
		ableBayarEsamsat = json['able_bayar_esamsat'];
		ableBayarPajak = json['able_bayar_pajak'];
		alPemilik = json['al_pemilik'];
		bobot = json['bobot'];
		dataHitungPajak = json['data_hitung_pajak'] != null ? new DataHitungPajak.fromJson(json['data_hitung_pajak']) : null;
		email = json['email'];
		jenisIdentitas = json['jenis_identitas'];
		kdBlockir = json['kd_blockir'];
		kdFungsiKb = json['kd_fungsi_kb'];
		kdMerekKb = json['kd_merek_kb'];
		kdProteksi = json['kd_proteksi'];
		kdWil = json['kd_wil'];
		milikKe = json['milik_ke'];
		nilaiJual = json['nilai_jual'];
		nmFungsiKb = json['nm_fungsi_kb'];
		nmJenisKb = json['nm_jenis_kb'];
		nmMerekKb = json['nm_merek_kb'];
		nmModelKb = json['nm_model_kb'];
		nmPemilik = json['nm_pemilik'];
		nmWil = json['nm_wil'];
		noHp = json['no_hp'];
		noIdentitas = json['no_identitas'];
		noMesin = json['no_mesin'];
		noPolisi1 = json['no_polisi1'];
		noPolisi2 = json['no_polisi2'];
		noPolisi3 = json['no_polisi3'];
		noRangka = json['no_rangka'];
		noWa = json['no_wa'];
		tgAkhirPajak = json['tg_akhir_pajak'];
		tgAkhirStnk = json['tg_akhir_stnk'];
		tgKepemilikan = json['tg_kepemilikan'];
		tgProsesTetap = json['tg_proses_tetap'];
		thBuatan = json['th_buatan'];
		warnaKb = json['warna_kb'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['able_bayar_esamsat'] = this.ableBayarEsamsat;
		data['able_bayar_pajak'] = this.ableBayarPajak;
		data['al_pemilik'] = this.alPemilik;
		data['bobot'] = this.bobot;
		if (this.dataHitungPajak != null) {
      data['data_hitung_pajak'] = this.dataHitungPajak!.toJson();
    }
		data['email'] = this.email;
		data['jenis_identitas'] = this.jenisIdentitas;
		data['kd_blockir'] = this.kdBlockir;
		data['kd_fungsi_kb'] = this.kdFungsiKb;
		data['kd_merek_kb'] = this.kdMerekKb;
		data['kd_proteksi'] = this.kdProteksi;
		data['kd_wil'] = this.kdWil;
		data['milik_ke'] = this.milikKe;
		data['nilai_jual'] = this.nilaiJual;
		data['nm_fungsi_kb'] = this.nmFungsiKb;
		data['nm_jenis_kb'] = this.nmJenisKb;
		data['nm_merek_kb'] = this.nmMerekKb;
		data['nm_model_kb'] = this.nmModelKb;
		data['nm_pemilik'] = this.nmPemilik;
		data['nm_wil'] = this.nmWil;
		data['no_hp'] = this.noHp;
		data['no_identitas'] = this.noIdentitas;
		data['no_mesin'] = this.noMesin;
		data['no_polisi1'] = this.noPolisi1;
		data['no_polisi2'] = this.noPolisi2;
		data['no_polisi3'] = this.noPolisi3;
		data['no_rangka'] = this.noRangka;
		data['no_wa'] = this.noWa;
		data['tg_akhir_pajak'] = this.tgAkhirPajak;
		data['tg_akhir_stnk'] = this.tgAkhirStnk;
		data['tg_kepemilikan'] = this.tgKepemilikan;
		data['tg_proses_tetap'] = this.tgProsesTetap;
		data['th_buatan'] = this.thBuatan;
		data['warna_kb'] = this.warnaKb;
		return data;
	}
}

class DataHitungPajak {
	int? beaAdmStnk;
	int? beaAdmStnkNonprog;
	int? beaAdmTnkb;
	int? beaAdmTnkbNonprog;
	int? beaBbnkb1Den;
	int? beaBbnkb1DenNonprog;
	int? beaBbnkb1Ops;
	int? beaBbnkb1OpsDen;
	int? beaBbnkb1OpsDenNonprog;
	int? beaBbnkb1OpsNonprog;
	int? beaBbnkb1Pok;
	int? beaBbnkb1PokNonprog;
	int? beaBbnkb2Den;
	int? beaBbnkb2DenNonprog;
	int? beaBbnkb2Ops;
	int? beaBbnkb2OpsDen;
	int? beaBbnkb2OpsDenNonprog;
	int? beaBbnkb2OpsNonprog;
	int? beaBbnkb2Pok;
	int? beaBbnkb2PokNonprog;
	int? beaPkbDen0;
	int? beaPkbDen0Nonprog;
	int? beaPkbDen1;
	int? beaPkbDen1Nonprog;
	int? beaPkbDen2;
	int? beaPkbDen2Nonprog;
	int? beaPkbDen3;
	int? beaPkbDen3Nonprog;
	int? beaPkbDen4;
	int? beaPkbDen4Nonprog;
	int? beaPkbDen5;
	int? beaPkbDen5Nonprog;
	int? beaPkbOps0;
	int? beaPkbOps0Nonprog;
	int? beaPkbOps1;
	int? beaPkbOps1Nonprog;
	int? beaPkbOps2;
	int? beaPkbOps2Nonprog;
	int? beaPkbOps3;
	int? beaPkbOps3Nonprog;
	int? beaPkbOps4;
	int? beaPkbOps4Nonprog;
	int? beaPkbOps5;
	int? beaPkbOps5Nonprog;
	int? beaPkbOpsDen0;
	int? beaPkbOpsDen0Nonprog;
	int? beaPkbOpsDen1;
	int? beaPkbOpsDen1Nonprog;
	int? beaPkbOpsDen2;
	int? beaPkbOpsDen2Nonprog;
	int? beaPkbOpsDen3;
	int? beaPkbOpsDen3Nonprog;
	int? beaPkbOpsDen4;
	int? beaPkbOpsDen4Nonprog;
	int? beaPkbOpsDen5;
	int? beaPkbOpsDen5Nonprog;
	int? beaPkbPok0;
	int? beaPkbPok0Nonprog;
	int? beaPkbPok1;
	int? beaPkbPok1Nonprog;
	int? beaPkbPok2;
	int? beaPkbPok2Nonprog;
	int? beaPkbPok3;
	int? beaPkbPok3Nonprog;
	int? beaPkbPok4;
	int? beaPkbPok4Nonprog;
	int? beaPkbPok5;
	int? beaPkbPok5Nonprog;
	int? beaSwdklljDen0;
	int? beaSwdklljDen0Nonprog;
	int? beaSwdklljDen1;
	int? beaSwdklljDen1Nonprog;
	int? beaSwdklljDen2;
	int? beaSwdklljDen2Nonprog;
	int? beaSwdklljDen3;
	int? beaSwdklljDen3Nonprog;
	int? beaSwdklljDen4;
	int? beaSwdklljDen4Nonprog;
	int? beaSwdklljDen5;
	int? beaSwdklljDen5Nonprog;
	int? beaSwdklljPok0;
	int? beaSwdklljPok0Nonprog;
	int? beaSwdklljPok1;
	int? beaSwdklljPok1Nonprog;
	int? beaSwdklljPok2;
	int? beaSwdklljPok2Nonprog;
	int? beaSwdklljPok3;
	int? beaSwdklljPok3Nonprog;
	int? beaSwdklljPok4;
	int? beaSwdklljPok4Nonprog;
	int? beaSwdklljPok5;
	int? beaSwdklljPok5Nonprog;
	String? bobot;
	int? bobotLama;
	String? jrRefId;
	String? ket1;
	String? ket2;
	String? ket3;
	String? kodeGolJr;
	String? kodeJenisJr;
	String? nilaiJual;
	int? nilaiJualLama;
	int? selangBulan;
	int? selangHari;
	int? selangTahun;
	String? tgAkhirPajakBaru;
	String? tgAkhirStnkBaru;

	DataHitungPajak({this.beaAdmStnk, this.beaAdmStnkNonprog, this.beaAdmTnkb, this.beaAdmTnkbNonprog, this.beaBbnkb1Den, this.beaBbnkb1DenNonprog, this.beaBbnkb1Ops, this.beaBbnkb1OpsDen, this.beaBbnkb1OpsDenNonprog, this.beaBbnkb1OpsNonprog, this.beaBbnkb1Pok, this.beaBbnkb1PokNonprog, this.beaBbnkb2Den, this.beaBbnkb2DenNonprog, this.beaBbnkb2Ops, this.beaBbnkb2OpsDen, this.beaBbnkb2OpsDenNonprog, this.beaBbnkb2OpsNonprog, this.beaBbnkb2Pok, this.beaBbnkb2PokNonprog, this.beaPkbDen0, this.beaPkbDen0Nonprog, this.beaPkbDen1, this.beaPkbDen1Nonprog, this.beaPkbDen2, this.beaPkbDen2Nonprog, this.beaPkbDen3, this.beaPkbDen3Nonprog, this.beaPkbDen4, this.beaPkbDen4Nonprog, this.beaPkbDen5, this.beaPkbDen5Nonprog, this.beaPkbOps0, this.beaPkbOps0Nonprog, this.beaPkbOps1, this.beaPkbOps1Nonprog, this.beaPkbOps2, this.beaPkbOps2Nonprog, this.beaPkbOps3, this.beaPkbOps3Nonprog, this.beaPkbOps4, this.beaPkbOps4Nonprog, this.beaPkbOps5, this.beaPkbOps5Nonprog, this.beaPkbOpsDen0, this.beaPkbOpsDen0Nonprog, this.beaPkbOpsDen1, this.beaPkbOpsDen1Nonprog, this.beaPkbOpsDen2, this.beaPkbOpsDen2Nonprog, this.beaPkbOpsDen3, this.beaPkbOpsDen3Nonprog, this.beaPkbOpsDen4, this.beaPkbOpsDen4Nonprog, this.beaPkbOpsDen5, this.beaPkbOpsDen5Nonprog, this.beaPkbPok0, this.beaPkbPok0Nonprog, this.beaPkbPok1, this.beaPkbPok1Nonprog, this.beaPkbPok2, this.beaPkbPok2Nonprog, this.beaPkbPok3, this.beaPkbPok3Nonprog, this.beaPkbPok4, this.beaPkbPok4Nonprog, this.beaPkbPok5, this.beaPkbPok5Nonprog, this.beaSwdklljDen0, this.beaSwdklljDen0Nonprog, this.beaSwdklljDen1, this.beaSwdklljDen1Nonprog, this.beaSwdklljDen2, this.beaSwdklljDen2Nonprog, this.beaSwdklljDen3, this.beaSwdklljDen3Nonprog, this.beaSwdklljDen4, this.beaSwdklljDen4Nonprog, this.beaSwdklljDen5, this.beaSwdklljDen5Nonprog, this.beaSwdklljPok0, this.beaSwdklljPok0Nonprog, this.beaSwdklljPok1, this.beaSwdklljPok1Nonprog, this.beaSwdklljPok2, this.beaSwdklljPok2Nonprog, this.beaSwdklljPok3, this.beaSwdklljPok3Nonprog, this.beaSwdklljPok4, this.beaSwdklljPok4Nonprog, this.beaSwdklljPok5, this.beaSwdklljPok5Nonprog, this.bobot, this.bobotLama, this.jrRefId, this.ket1, this.ket2, this.ket3, this.kodeGolJr, this.kodeJenisJr, this.nilaiJual, this.nilaiJualLama, this.selangBulan, this.selangHari, this.selangTahun, this.tgAkhirPajakBaru, this.tgAkhirStnkBaru});

	DataHitungPajak.fromJson(Map<String, dynamic> json) {
		beaAdmStnk = json['bea_adm_stnk'];
		beaAdmStnkNonprog = json['bea_adm_stnk_nonprog'];
		beaAdmTnkb = json['bea_adm_tnkb'];
		beaAdmTnkbNonprog = json['bea_adm_tnkb_nonprog'];
		beaBbnkb1Den = json['bea_bbnkb1_den'];
		beaBbnkb1DenNonprog = json['bea_bbnkb1_den_nonprog'];
		beaBbnkb1Ops = json['bea_bbnkb1_ops'];
		beaBbnkb1OpsDen = json['bea_bbnkb1_ops_den'];
		beaBbnkb1OpsDenNonprog = json['bea_bbnkb1_ops_den_nonprog'];
		beaBbnkb1OpsNonprog = json['bea_bbnkb1_ops_nonprog'];
		beaBbnkb1Pok = json['bea_bbnkb1_pok'];
		beaBbnkb1PokNonprog = json['bea_bbnkb1_pok_nonprog'];
		beaBbnkb2Den = json['bea_bbnkb2_den'];
		beaBbnkb2DenNonprog = json['bea_bbnkb2_den_nonprog'];
		beaBbnkb2Ops = json['bea_bbnkb2_ops'];
		beaBbnkb2OpsDen = json['bea_bbnkb2_ops_den'];
		beaBbnkb2OpsDenNonprog = json['bea_bbnkb2_ops_den_nonprog'];
		beaBbnkb2OpsNonprog = json['bea_bbnkb2_ops_nonprog'];
		beaBbnkb2Pok = json['bea_bbnkb2_pok'];
		beaBbnkb2PokNonprog = json['bea_bbnkb2_pok_nonprog'];
		beaPkbDen0 = json['bea_pkb_den0'];
		beaPkbDen0Nonprog = json['bea_pkb_den0_nonprog'];
		beaPkbDen1 = json['bea_pkb_den1'];
		beaPkbDen1Nonprog = json['bea_pkb_den1_nonprog'];
		beaPkbDen2 = json['bea_pkb_den2'];
		beaPkbDen2Nonprog = json['bea_pkb_den2_nonprog'];
		beaPkbDen3 = json['bea_pkb_den3'];
		beaPkbDen3Nonprog = json['bea_pkb_den3_nonprog'];
		beaPkbDen4 = json['bea_pkb_den4'];
		beaPkbDen4Nonprog = json['bea_pkb_den4_nonprog'];
		beaPkbDen5 = json['bea_pkb_den5'];
		beaPkbDen5Nonprog = json['bea_pkb_den5_nonprog'];
		beaPkbOps0 = json['bea_pkb_ops0'];
		beaPkbOps0Nonprog = json['bea_pkb_ops0_nonprog'];
		beaPkbOps1 = json['bea_pkb_ops1'];
		beaPkbOps1Nonprog = json['bea_pkb_ops1_nonprog'];
		beaPkbOps2 = json['bea_pkb_ops2'];
		beaPkbOps2Nonprog = json['bea_pkb_ops2_nonprog'];
		beaPkbOps3 = json['bea_pkb_ops3'];
		beaPkbOps3Nonprog = json['bea_pkb_ops3_nonprog'];
		beaPkbOps4 = json['bea_pkb_ops4'];
		beaPkbOps4Nonprog = json['bea_pkb_ops4_nonprog'];
		beaPkbOps5 = json['bea_pkb_ops5'];
		beaPkbOps5Nonprog = json['bea_pkb_ops5_nonprog'];
		beaPkbOpsDen0 = json['bea_pkb_ops_den0'];
		beaPkbOpsDen0Nonprog = json['bea_pkb_ops_den0_nonprog'];
		beaPkbOpsDen1 = json['bea_pkb_ops_den1'];
		beaPkbOpsDen1Nonprog = json['bea_pkb_ops_den1_nonprog'];
		beaPkbOpsDen2 = json['bea_pkb_ops_den2'];
		beaPkbOpsDen2Nonprog = json['bea_pkb_ops_den2_nonprog'];
		beaPkbOpsDen3 = json['bea_pkb_ops_den3'];
		beaPkbOpsDen3Nonprog = json['bea_pkb_ops_den3_nonprog'];
		beaPkbOpsDen4 = json['bea_pkb_ops_den4'];
		beaPkbOpsDen4Nonprog = json['bea_pkb_ops_den4_nonprog'];
		beaPkbOpsDen5 = json['bea_pkb_ops_den5'];
		beaPkbOpsDen5Nonprog = json['bea_pkb_ops_den5_nonprog'];
		beaPkbPok0 = json['bea_pkb_pok0'];
		beaPkbPok0Nonprog = json['bea_pkb_pok0_nonprog'];
		beaPkbPok1 = json['bea_pkb_pok1'];
		beaPkbPok1Nonprog = json['bea_pkb_pok1_nonprog'];
		beaPkbPok2 = json['bea_pkb_pok2'];
		beaPkbPok2Nonprog = json['bea_pkb_pok2_nonprog'];
		beaPkbPok3 = json['bea_pkb_pok3'];
		beaPkbPok3Nonprog = json['bea_pkb_pok3_nonprog'];
		beaPkbPok4 = json['bea_pkb_pok4'];
		beaPkbPok4Nonprog = json['bea_pkb_pok4_nonprog'];
		beaPkbPok5 = json['bea_pkb_pok5'];
		beaPkbPok5Nonprog = json['bea_pkb_pok5_nonprog'];
		beaSwdklljDen0 = json['bea_swdkllj_den0'];
		beaSwdklljDen0Nonprog = json['bea_swdkllj_den0_nonprog'];
		beaSwdklljDen1 = json['bea_swdkllj_den1'];
		beaSwdklljDen1Nonprog = json['bea_swdkllj_den1_nonprog'];
		beaSwdklljDen2 = json['bea_swdkllj_den2'];
		beaSwdklljDen2Nonprog = json['bea_swdkllj_den2_nonprog'];
		beaSwdklljDen3 = json['bea_swdkllj_den3'];
		beaSwdklljDen3Nonprog = json['bea_swdkllj_den3_nonprog'];
		beaSwdklljDen4 = json['bea_swdkllj_den4'];
		beaSwdklljDen4Nonprog = json['bea_swdkllj_den4_nonprog'];
		beaSwdklljDen5 = json['bea_swdkllj_den5'];
		beaSwdklljDen5Nonprog = json['bea_swdkllj_den5_nonprog'];
		beaSwdklljPok0 = json['bea_swdkllj_pok0'];
		beaSwdklljPok0Nonprog = json['bea_swdkllj_pok0_nonprog'];
		beaSwdklljPok1 = json['bea_swdkllj_pok1'];
		beaSwdklljPok1Nonprog = json['bea_swdkllj_pok1_nonprog'];
		beaSwdklljPok2 = json['bea_swdkllj_pok2'];
		beaSwdklljPok2Nonprog = json['bea_swdkllj_pok2_nonprog'];
		beaSwdklljPok3 = json['bea_swdkllj_pok3'];
		beaSwdklljPok3Nonprog = json['bea_swdkllj_pok3_nonprog'];
		beaSwdklljPok4 = json['bea_swdkllj_pok4'];
		beaSwdklljPok4Nonprog = json['bea_swdkllj_pok4_nonprog'];
		beaSwdklljPok5 = json['bea_swdkllj_pok5'];
		beaSwdklljPok5Nonprog = json['bea_swdkllj_pok5_nonprog'];
		bobot = json['bobot'];
		bobotLama = json['bobot_lama'];
		jrRefId = json['jr_ref_id'];
		ket1 = json['ket1'];
		ket2 = json['ket2'];
		ket3 = json['ket3'];
		kodeGolJr = json['kode_gol_jr'];
		kodeJenisJr = json['kode_jenis_jr'];
		nilaiJual = json['nilai_jual'];
		nilaiJualLama = json['nilai_jual_lama'];
		selangBulan = json['selang_bulan'];
		selangHari = json['selang_hari'];
		selangTahun = json['selang_tahun'];
		tgAkhirPajakBaru = json['tg_akhir_pajak_baru'];
		tgAkhirStnkBaru = json['tg_akhir_stnk_baru'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['bea_adm_stnk'] = this.beaAdmStnk;
		data['bea_adm_stnk_nonprog'] = this.beaAdmStnkNonprog;
		data['bea_adm_tnkb'] = this.beaAdmTnkb;
		data['bea_adm_tnkb_nonprog'] = this.beaAdmTnkbNonprog;
		data['bea_bbnkb1_den'] = this.beaBbnkb1Den;
		data['bea_bbnkb1_den_nonprog'] = this.beaBbnkb1DenNonprog;
		data['bea_bbnkb1_ops'] = this.beaBbnkb1Ops;
		data['bea_bbnkb1_ops_den'] = this.beaBbnkb1OpsDen;
		data['bea_bbnkb1_ops_den_nonprog'] = this.beaBbnkb1OpsDenNonprog;
		data['bea_bbnkb1_ops_nonprog'] = this.beaBbnkb1OpsNonprog;
		data['bea_bbnkb1_pok'] = this.beaBbnkb1Pok;
		data['bea_bbnkb1_pok_nonprog'] = this.beaBbnkb1PokNonprog;
		data['bea_bbnkb2_den'] = this.beaBbnkb2Den;
		data['bea_bbnkb2_den_nonprog'] = this.beaBbnkb2DenNonprog;
		data['bea_bbnkb2_ops'] = this.beaBbnkb2Ops;
		data['bea_bbnkb2_ops_den'] = this.beaBbnkb2OpsDen;
		data['bea_bbnkb2_ops_den_nonprog'] = this.beaBbnkb2OpsDenNonprog;
		data['bea_bbnkb2_ops_nonprog'] = this.beaBbnkb2OpsNonprog;
		data['bea_bbnkb2_pok'] = this.beaBbnkb2Pok;
		data['bea_bbnkb2_pok_nonprog'] = this.beaBbnkb2PokNonprog;
		data['bea_pkb_den0'] = this.beaPkbDen0;
		data['bea_pkb_den0_nonprog'] = this.beaPkbDen0Nonprog;
		data['bea_pkb_den1'] = this.beaPkbDen1;
		data['bea_pkb_den1_nonprog'] = this.beaPkbDen1Nonprog;
		data['bea_pkb_den2'] = this.beaPkbDen2;
		data['bea_pkb_den2_nonprog'] = this.beaPkbDen2Nonprog;
		data['bea_pkb_den3'] = this.beaPkbDen3;
		data['bea_pkb_den3_nonprog'] = this.beaPkbDen3Nonprog;
		data['bea_pkb_den4'] = this.beaPkbDen4;
		data['bea_pkb_den4_nonprog'] = this.beaPkbDen4Nonprog;
		data['bea_pkb_den5'] = this.beaPkbDen5;
		data['bea_pkb_den5_nonprog'] = this.beaPkbDen5Nonprog;
		data['bea_pkb_ops0'] = this.beaPkbOps0;
		data['bea_pkb_ops0_nonprog'] = this.beaPkbOps0Nonprog;
		data['bea_pkb_ops1'] = this.beaPkbOps1;
		data['bea_pkb_ops1_nonprog'] = this.beaPkbOps1Nonprog;
		data['bea_pkb_ops2'] = this.beaPkbOps2;
		data['bea_pkb_ops2_nonprog'] = this.beaPkbOps2Nonprog;
		data['bea_pkb_ops3'] = this.beaPkbOps3;
		data['bea_pkb_ops3_nonprog'] = this.beaPkbOps3Nonprog;
		data['bea_pkb_ops4'] = this.beaPkbOps4;
		data['bea_pkb_ops4_nonprog'] = this.beaPkbOps4Nonprog;
		data['bea_pkb_ops5'] = this.beaPkbOps5;
		data['bea_pkb_ops5_nonprog'] = this.beaPkbOps5Nonprog;
		data['bea_pkb_ops_den0'] = this.beaPkbOpsDen0;
		data['bea_pkb_ops_den0_nonprog'] = this.beaPkbOpsDen0Nonprog;
		data['bea_pkb_ops_den1'] = this.beaPkbOpsDen1;
		data['bea_pkb_ops_den1_nonprog'] = this.beaPkbOpsDen1Nonprog;
		data['bea_pkb_ops_den2'] = this.beaPkbOpsDen2;
		data['bea_pkb_ops_den2_nonprog'] = this.beaPkbOpsDen2Nonprog;
		data['bea_pkb_ops_den3'] = this.beaPkbOpsDen3;
		data['bea_pkb_ops_den3_nonprog'] = this.beaPkbOpsDen3Nonprog;
		data['bea_pkb_ops_den4'] = this.beaPkbOpsDen4;
		data['bea_pkb_ops_den4_nonprog'] = this.beaPkbOpsDen4Nonprog;
		data['bea_pkb_ops_den5'] = this.beaPkbOpsDen5;
		data['bea_pkb_ops_den5_nonprog'] = this.beaPkbOpsDen5Nonprog;
		data['bea_pkb_pok0'] = this.beaPkbPok0;
		data['bea_pkb_pok0_nonprog'] = this.beaPkbPok0Nonprog;
		data['bea_pkb_pok1'] = this.beaPkbPok1;
		data['bea_pkb_pok1_nonprog'] = this.beaPkbPok1Nonprog;
		data['bea_pkb_pok2'] = this.beaPkbPok2;
		data['bea_pkb_pok2_nonprog'] = this.beaPkbPok2Nonprog;
		data['bea_pkb_pok3'] = this.beaPkbPok3;
		data['bea_pkb_pok3_nonprog'] = this.beaPkbPok3Nonprog;
		data['bea_pkb_pok4'] = this.beaPkbPok4;
		data['bea_pkb_pok4_nonprog'] = this.beaPkbPok4Nonprog;
		data['bea_pkb_pok5'] = this.beaPkbPok5;
		data['bea_pkb_pok5_nonprog'] = this.beaPkbPok5Nonprog;
		data['bea_swdkllj_den0'] = this.beaSwdklljDen0;
		data['bea_swdkllj_den0_nonprog'] = this.beaSwdklljDen0Nonprog;
		data['bea_swdkllj_den1'] = this.beaSwdklljDen1;
		data['bea_swdkllj_den1_nonprog'] = this.beaSwdklljDen1Nonprog;
		data['bea_swdkllj_den2'] = this.beaSwdklljDen2;
		data['bea_swdkllj_den2_nonprog'] = this.beaSwdklljDen2Nonprog;
		data['bea_swdkllj_den3'] = this.beaSwdklljDen3;
		data['bea_swdkllj_den3_nonprog'] = this.beaSwdklljDen3Nonprog;
		data['bea_swdkllj_den4'] = this.beaSwdklljDen4;
		data['bea_swdkllj_den4_nonprog'] = this.beaSwdklljDen4Nonprog;
		data['bea_swdkllj_den5'] = this.beaSwdklljDen5;
		data['bea_swdkllj_den5_nonprog'] = this.beaSwdklljDen5Nonprog;
		data['bea_swdkllj_pok0'] = this.beaSwdklljPok0;
		data['bea_swdkllj_pok0_nonprog'] = this.beaSwdklljPok0Nonprog;
		data['bea_swdkllj_pok1'] = this.beaSwdklljPok1;
		data['bea_swdkllj_pok1_nonprog'] = this.beaSwdklljPok1Nonprog;
		data['bea_swdkllj_pok2'] = this.beaSwdklljPok2;
		data['bea_swdkllj_pok2_nonprog'] = this.beaSwdklljPok2Nonprog;
		data['bea_swdkllj_pok3'] = this.beaSwdklljPok3;
		data['bea_swdkllj_pok3_nonprog'] = this.beaSwdklljPok3Nonprog;
		data['bea_swdkllj_pok4'] = this.beaSwdklljPok4;
		data['bea_swdkllj_pok4_nonprog'] = this.beaSwdklljPok4Nonprog;
		data['bea_swdkllj_pok5'] = this.beaSwdklljPok5;
		data['bea_swdkllj_pok5_nonprog'] = this.beaSwdklljPok5Nonprog;
		data['bobot'] = this.bobot;
		data['bobot_lama'] = this.bobotLama;
		data['jr_ref_id'] = this.jrRefId;
		data['ket1'] = this.ket1;
		data['ket2'] = this.ket2;
		data['ket3'] = this.ket3;
		data['kode_gol_jr'] = this.kodeGolJr;
		data['kode_jenis_jr'] = this.kodeJenisJr;
		data['nilai_jual'] = this.nilaiJual;
		data['nilai_jual_lama'] = this.nilaiJualLama;
		data['selang_bulan'] = this.selangBulan;
		data['selang_hari'] = this.selangHari;
		data['selang_tahun'] = this.selangTahun;
		data['tg_akhir_pajak_baru'] = this.tgAkhirPajakBaru;
		data['tg_akhir_stnk_baru'] = this.tgAkhirStnkBaru;
		return data;
	}
}

class Param {
	String? bayarKedepan;
	List<WhereClause>? where;

	Param({this.bayarKedepan, this.where});

	Param.fromJson(Map<String, dynamic> json) {
		bayarKedepan = json['bayar_kedepan'];
		if (json['where'] != null) {
			where = <WhereClause>[];
			json['where'].forEach((v) { 
				where!.add(WhereClause.fromJson(v)); 
			});
		}
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['bayar_kedepan'] = this.bayarKedepan;
		if (this.where != null) {
      data['where'] = this.where!.map((v) => v.toJson()).toList();
    }
		return data;
	}
}

class WhereClause {
	String? key;
	String? method;
	String? value;

	WhereClause({this.key, this.method, this.value});

	WhereClause.fromJson(Map<String, dynamic> json) {
		key = json['key'];
		method = json['method'];
		value = json['value'];
	}

	Map<String, dynamic> toJson() {
		final Map<String, dynamic> data = new Map<String, dynamic>();
		data['key'] = this.key;
		data['method'] = this.method;
		data['value'] = this.value;
		return data;
	}
}
