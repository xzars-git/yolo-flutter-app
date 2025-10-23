class DataDashboardPenelusur {
  int? code;
  DataDetailDashboardPenelusur? data;
  String? status;

  DataDashboardPenelusur({this.code, this.data, this.status});

  DataDashboardPenelusur.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? DataDetailDashboardPenelusur.fromJson(json['data']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = status;
    return data;
  }
}

class DataDetailDashboardPenelusur {
  JumlahPenelusuran? jumlahPenelusuran;
  TrenBulanan? trenBulanan;
  TrenPenelusuran? trenPenelusuran;

  DataDetailDashboardPenelusur({this.jumlahPenelusuran, this.trenBulanan, this.trenPenelusuran});

  DataDetailDashboardPenelusur.fromJson(Map<String, dynamic> json) {
    jumlahPenelusuran = json['jumlah_penelusuran'] != null
        ? JumlahPenelusuran.fromJson(json['jumlah_penelusuran'])
        : null;
    trenBulanan = json['tren_bulanan'] != null ? TrenBulanan.fromJson(json['tren_bulanan']) : null;
    trenPenelusuran = json['tren_penelusuran'] != null
        ? TrenPenelusuran.fromJson(json['tren_penelusuran'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (jumlahPenelusuran != null) {
      data['jumlah_penelusuran'] = jumlahPenelusuran!.toJson();
    }
    if (trenBulanan != null) {
      data['tren_bulanan'] = trenBulanan!.toJson();
    }
    if (trenPenelusuran != null) {
      data['tren_penelusuran'] = trenPenelusuran!.toJson();
    }
    return data;
  }
}

class JumlahPenelusuran {
  String? idPenelusur;
  int? daftarTelusur;
  int? menungguVerifikasi;
  int? penelusuranDiterima;
  int? penelusuranDitolak;
  int? sudahDitelusuri;
  int? jmlPembayaranPkbPok;
  int? jmlPembayaranPkbDen;
  int? jmlPembayaranOpsenPok;
  int? jmlPembayaranOpsenDen;
  int? jmlKendaraanDibayar;

  JumlahPenelusuran(
      {this.idPenelusur,
      this.daftarTelusur,
      this.menungguVerifikasi,
      this.penelusuranDiterima,
      this.penelusuranDitolak,
      this.sudahDitelusuri,
      this.jmlPembayaranPkbPok,
      this.jmlPembayaranPkbDen,
      this.jmlKendaraanDibayar});

  JumlahPenelusuran.fromJson(Map<String, dynamic> json) {
    idPenelusur = json['id_penelusur'];
    daftarTelusur = json['daftar_telusur'];
    menungguVerifikasi = json['menunggu_verifikasi'];
    penelusuranDiterima = json['penelusuran_diterima'];
    penelusuranDitolak = json['penelusuran_ditolak'];
    sudahDitelusuri = json['sudah_ditelusuri'];
    jmlPembayaranPkbPok = json['jml_pembayaran_pkb_pokok'];
    jmlPembayaranPkbDen = json['jml_pembayaran_pkb_denda'];
    jmlPembayaranOpsenPok = json['jml_pembayaran_opsen_pokok'];
    jmlPembayaranOpsenDen = json['jml_pembayaran_opsen_denda'];
    jmlKendaraanDibayar = json['jml_kendaraan_dibayar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id_penelusur'] = idPenelusur;
    data['daftar_telusur'] = daftarTelusur;
    data['menunggu_verifikasi'] = menungguVerifikasi;
    data['penelusuran_diterima'] = penelusuranDiterima;
    data['penelusuran_ditolak'] = penelusuranDitolak;
    data['sudah_ditelusuri'] = sudahDitelusuri;
    data['jml_pembayaran_pok'] = jmlPembayaranPkbPok;
    data['jml_pembayaran_den'] = jmlPembayaranPkbDen;
    data['jml_kendaraan_dibayar'] = jmlKendaraanDibayar;
    return data;
  }
}

class TrenBulanan {
  int? currentYear;
  Map<String, int>? dataBulanan;

  TrenBulanan({this.currentYear, this.dataBulanan});

  TrenBulanan.fromJson(Map<String, dynamic> json) {
    currentYear = json['current_year'];
    if (json['data_bulanan'] != null) {
      dataBulanan = Map<String, int>.from(json['data_bulanan']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_year'] = currentYear;
    if (dataBulanan != null) {
      data['data_bulanan'] = dataBulanan;
    }
    return data;
  }
}

class TrenPenelusuran {
  Map<String, int>? dataTren;
  int? rataRata;
  int? terendah;
  int? tertinggi;

  TrenPenelusuran({this.dataTren, this.rataRata, this.terendah, this.tertinggi});

  TrenPenelusuran.fromJson(Map<String, dynamic> json) {
    if (json['data_tren'] != null) {
      dataTren = Map<String, int>.from(json['data_tren']);
    }
    rataRata = json['rata-rata'];
    terendah = json['terendah'];
    tertinggi = json['tertinggi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dataTren != null) {
      data['data_tren'] = dataTren;
    }
    data['rata-rata'] = rataRata;
    data['terendah'] = terendah;
    data['tertinggi'] = tertinggi;
    return data;
  }
}
