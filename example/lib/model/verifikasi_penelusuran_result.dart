class VerifikasiPenelusuranResult {
  int? code;
  DataVerifikasiPenelusuran? data;
  String? message;
  String? status;

  VerifikasiPenelusuranResult({this.code, this.data, this.message, this.status});

  VerifikasiPenelusuranResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? DataVerifikasiPenelusuran.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

class DataVerifikasiPenelusuran {
  String? id;
  String? idPenelusur;
  String? tahun;
  String? kdWil;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? noRangka;
  String? kdPlat;
  String? tglTelusur;
  String? kdTelusur;
  String? ketAlasan;
  String? noPonsel;
  String? latitude;
  String? longitude;
  String? fotoKtp;
  String? fotoStnk;
  String? fotoSkpd;
  String? fotoKendaraan;
  String? fotoLokasi;
  String? fotoTtd;
  String? kdStatus;
  String? idSpkp2kb;
  String? ketDitolak;

  DataVerifikasiPenelusuran(
      {this.id,
      this.idPenelusur,
      this.tahun,
      this.kdWil,
      this.noPolisi1,
      this.noPolisi2,
      this.noPolisi3,
      this.noRangka,
      this.kdPlat,
      this.tglTelusur,
      this.kdTelusur,
      this.ketAlasan,
      this.noPonsel,
      this.latitude,
      this.longitude,
      this.fotoKtp,
      this.fotoStnk,
      this.fotoSkpd,
      this.fotoKendaraan,
      this.fotoLokasi,
      this.fotoTtd,
      this.kdStatus,
      this.idSpkp2kb,
      this.ketDitolak});

  DataVerifikasiPenelusuran.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idPenelusur = json['id_penelusur'];
    tahun = json['tahun'];
    kdWil = json['kd_wil'];
    noPolisi1 = json['no_polisi1'];
    noPolisi2 = json['no_polisi2'];
    noPolisi3 = json['no_polisi3'];
    noRangka = json['no_rangka'];
    kdPlat = json['kd_plat'];
    tglTelusur = json['tgl_telusur'];
    kdTelusur = json['kd_telusur'];
    ketAlasan = json['ket_alasan'];
    noPonsel = json['no_ponsel'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    fotoKtp = json['foto_ktp'];
    fotoStnk = json['foto_stnk'];
    fotoSkpd = json['foto_skpd'];
    fotoKendaraan = json['foto_kendaraan'];
    fotoLokasi = json['foto_lokasi'];
    fotoTtd = json['foto_ttd'];
    kdStatus = json['kd_status'];
    idSpkp2kb = json['id_spkp2kb'];
    ketDitolak = json['ket_ditolak'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_penelusur'] = idPenelusur;
    data['tahun'] = tahun;
    data['kd_wil'] = kdWil;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['no_rangka'] = noRangka;
    data['kd_plat'] = kdPlat;
    data['tgl_telusur'] = tglTelusur;
    data['kd_telusur'] = kdTelusur;
    data['ket_alasan'] = ketAlasan;
    data['no_ponsel'] = noPonsel;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['foto_ktp'] = fotoKtp;
    data['foto_stnk'] = fotoStnk;
    data['foto_skpd'] = fotoSkpd;
    data['foto_kendaraan'] = fotoKendaraan;
    data['foto_lokasi'] = fotoLokasi;
    data['foto_ttd'] = fotoTtd;
    data['kd_status'] = kdStatus;
    data['id_spkp2kb'] = idSpkp2kb;
    data['ket_ditolak'] = ketDitolak;
    return data;
  }
}
