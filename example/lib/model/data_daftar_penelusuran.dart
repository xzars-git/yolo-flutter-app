class DataDaftarPenelusuranResult {
  int? code;
  List<DataDaftarPenelusuran>? data;
  int? limit;
  String? message;
  int? page;
  String? status;
  int? totalData;
  int? totalPage;

  DataDaftarPenelusuranResult(
      {this.code,
      this.data,
      this.limit,
      this.message,
      this.page,
      this.status,
      this.totalData,
      this.totalPage});

  DataDaftarPenelusuranResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataDaftarPenelusuran>[];
      json['data'].forEach((v) {
        data!.add(DataDaftarPenelusuran.fromJson(v));
      });
    }
    limit = json['limit'];
    message = json['message'];
    page = json['page'];
    status = json['status'];
    totalData = json['total_data'];
    totalPage = json['total_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['limit'] = limit;
    data['message'] = message;
    data['page'] = page;
    data['status'] = status;
    data['total_data'] = totalData;
    data['total_page'] = totalPage;
    return data;
  }
}

class DataDaftarPenelusuran {
  String? id;
  String? kdStatus;
  String? idTelusur;
  String? kdWil;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? kdPlat;
  String? kdJenis;
  String? noRangka;
  String? noKtp;
  String? noHp;
  String? tglCetak;
  String? tglTelusur;
  String? kdTelusur;
  String? ketAlasan;
  String? noSurat;
  String? noSpkp2kb;
  String? nmPemilik;
  String? alamatPemilik;
  String? kdKecamatan;
  String? kdPos;
  String? tglAkhirPajak;
  String? tglAkhirStnk;
  String? idPenelusur;
  String? nmPenelusur;
  String? tglDitugaskan;
  String? nmMerekKb;
  String? nmModelKb;
  String? thBuatan;
  String? warnaKb;
  String? nmKecamatan;
  String? nmKelurahan;
  int? jmlPkbPok;
  int? jmlPkbDen;
  String? tglProsBayar;
  String? radiusLongtitude;
  String? radiusLatitude;

  DataDaftarPenelusuran(
      {this.id,
      this.kdStatus,
      this.idTelusur,
      this.kdWil,
      this.noPolisi1,
      this.noPolisi2,
      this.noPolisi3,
      this.kdPlat,
      this.kdJenis,
      this.noRangka,
      this.noKtp,
      this.noHp,
      this.tglCetak,
      this.tglTelusur,
      this.kdTelusur,
      this.ketAlasan,
      this.noSurat,
      this.noSpkp2kb,
      this.nmPemilik,
      this.alamatPemilik,
      this.kdKecamatan,
      this.kdPos,
      this.tglAkhirPajak,
      this.tglAkhirStnk,
      this.idPenelusur,
      this.nmPenelusur,
      this.tglDitugaskan,
      this.nmMerekKb,
      this.nmModelKb,
      this.thBuatan,
      this.warnaKb,
      this.nmKecamatan,
      this.nmKelurahan,
      this.jmlPkbPok,
      this.jmlPkbDen,
      this.tglProsBayar,
      this.radiusLongtitude,
      this.radiusLatitude});

  DataDaftarPenelusuran.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kdStatus = json['kd_status'];
    idTelusur = json['id_telusur'];
    kdWil = json['kd_wil'];
    noPolisi1 = json['no_polisi1'];
    noPolisi2 = json['no_polisi2'];
    noPolisi3 = json['no_polisi3'];
    kdPlat = json['kd_plat'];
    kdJenis = json['kd_jenis'];
    noRangka = json['no_rangka'];
    noKtp = json['no_ktp'];
    noHp = json['no_hp'];
    tglCetak = json['tgl_cetak'];
    tglTelusur = json['tgl_telusur'];
    kdTelusur = json['kd_telusur'];
    ketAlasan = json['ket_alasan'];
    noSurat = json['no_surat'];
    noSpkp2kb = json['no_spkp2kb'];
    nmPemilik = json['nm_pemilik'];
    alamatPemilik = json['alamat_pemilik'];
    kdKecamatan = json['kd_kecamatan'];
    kdPos = json['kd_pos'];
    tglAkhirPajak = json['tgl_akhir_pajak'];
    tglAkhirStnk = json['tgl_akhir_stnk'];
    idPenelusur = json['id_penelusur'];
    nmPenelusur = json['nm_penelusur'];
    tglDitugaskan = json['tgl_ditugaskan'];
    nmMerekKb = json['nm_merek_kb'];
    nmModelKb = json['nm_model_kb'];
    thBuatan = json['th_buatan'];
    warnaKb = json['warna_kb'];
    nmKecamatan = json['nm_kecamatan'];
    nmKelurahan = json['nm_kelurahan'];
    jmlPkbPok = json['jml_pkb_pok'];
    jmlPkbDen = json['jml_pkb_den'];
    tglProsBayar = json['tgl_pros_bayar'];
    radiusLongtitude = json['radius_longtitude'];
    radiusLatitude = json['radius_latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kd_status'] = kdStatus;
    data['id_telusur'] = idTelusur;
    data['kd_wil'] = kdWil;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['kd_plat'] = kdPlat;
    data['kd_jenis'] = kdJenis;
    data['no_rangka'] = noRangka;
    data['no_ktp'] = noKtp;
    data['no_hp'] = noHp;
    data['tgl_cetak'] = tglCetak;
    data['tgl_telusur'] = tglTelusur;
    data['kd_telusur'] = kdTelusur;
    data['ket_alasan'] = ketAlasan;
    data['no_surat'] = noSurat;
    data['no_spkp2kb'] = noSpkp2kb;
    data['nm_pemilik'] = nmPemilik;
    data['alamat_pemilik'] = alamatPemilik;
    data['kd_kecamatan'] = kdKecamatan;
    data['kd_pos'] = kdPos;
    data['tgl_akhir_pajak'] = tglAkhirPajak;
    data['tgl_akhir_stnk'] = tglAkhirStnk;
    data['id_penelusur'] = idPenelusur;
    data['nm_penelusur'] = nmPenelusur;
    data['tgl_ditugaskan'] = tglDitugaskan;
    data['nm_merek_kb'] = nmMerekKb;
    data['nm_model_kb'] = nmModelKb;
    data['th_buatan'] = thBuatan;
    data['warna_kb'] = warnaKb;
    data['nm_kecamatan'] = nmKecamatan;
    data['nm_kelurahan'] = nmKelurahan;
    data['jml_pkb_pok'] = jmlPkbPok;
    data['jml_pkb_den'] = jmlPkbDen;
    data['tgl_pros_bayar'] = tglProsBayar;
    data['radius_longtitude'] = radiusLongtitude;
    data['radius_latitude'] = radiusLatitude;
    return data;
  }
}
