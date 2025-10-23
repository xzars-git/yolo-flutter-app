class DetailHistoryPenelusuranResult {
  int? code;
  DataDetailHistoryPenelusuran? data;
  String? message;
  String? status;

  DetailHistoryPenelusuranResult({this.code, this.data, this.message, this.status});

  DetailHistoryPenelusuranResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? DataDetailHistoryPenelusuran.fromJson(json['data']) : null;
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

class DataDetailHistoryPenelusuran {
  String? id;
  String? kdStatus;
  String? nmStatus;
  String? idTelusur;
  String? kdWil;
  String? kdJenis;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? kdPlat;
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
  String? tglDitugaskan;
  String? nmPenelusur;
  String? username;
  String? nmMerekKb;
  String? nmModelKb;
  String? thBuatan;
  String? warnaKb;
  String? nmKecamatan;
  String? nmKelurahan;
  String? fotoKtp;
  String? fotoStnk;
  String? fotoSkpd;
  String? fotoKendaraan;
  String? fotoLokasi;
  String? fotoTtd;
  String? latitude;
  String? longitude;
  String? ketDitolak;
  String? tglVerifikasi;
  String? verifikatorId;
  String? isMockLocation;
  String? radius;
  String? metaFotoKtp;
  String? metaFotoStnk;
  String? metaFotoSkpd;
  String? metaFotoKendaraan;
  String? metaFotoLokasi;

  DataDetailHistoryPenelusuran(
      {this.id,
      this.kdStatus,
      this.nmStatus,
      this.idTelusur,
      this.kdWil,
      this.kdJenis,
      this.noPolisi1,
      this.noPolisi2,
      this.noPolisi3,
      this.kdPlat,
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
      this.tglDitugaskan,
      this.nmPenelusur,
      this.username,
      this.nmMerekKb,
      this.nmModelKb,
      this.thBuatan,
      this.warnaKb,
      this.nmKecamatan,
      this.nmKelurahan,
      this.fotoKtp,
      this.fotoStnk,
      this.fotoSkpd,
      this.fotoKendaraan,
      this.fotoLokasi,
      this.fotoTtd,
      this.latitude,
      this.longitude,
      this.ketDitolak,
      this.tglVerifikasi,
      this.verifikatorId,
      this.isMockLocation,
      this.radius,
      this.metaFotoKtp,
      this.metaFotoStnk,
      this.metaFotoSkpd,
      this.metaFotoKendaraan,
      this.metaFotoLokasi});

  DataDetailHistoryPenelusuran.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    kdStatus = json['kd_status'];
    nmStatus = json['nm_status'];
    idTelusur = json['id_telusur'];
    kdWil = json['kd_wil'];
    kdJenis = json['kd_jenis'];
    noPolisi1 = json['no_polisi1'];
    noPolisi2 = json['no_polisi2'];
    noPolisi3 = json['no_polisi3'];
    kdPlat = json['kd_plat'];
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
    tglDitugaskan = json['tgl_ditugaskan'];
    nmPenelusur = json['nm_penelusur'];
    username = json['username'];
    nmMerekKb = json['nm_merek_kb'];
    nmModelKb = json['nm_model_kb'];
    thBuatan = json['th_buatan'];
    warnaKb = json['warna_kb'];
    nmKecamatan = json['nm_kecamatan'];
    nmKelurahan = json['nm_kelurahan'];
    fotoKtp = json['foto_ktp'];
    fotoStnk = json['foto_stnk'];
    fotoSkpd = json['foto_skpd'];
    fotoKendaraan = json['foto_kendaraan'];
    fotoLokasi = json['foto_lokasi'];
    fotoTtd = json['foto_ttd'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    ketDitolak = json['ket_ditolak'];
    tglVerifikasi = json['tgl_verifikasi'];
    verifikatorId = json['verifikator_id'];
    isMockLocation = json['is_mock_location'];
    radius = json['radius'];
    metaFotoKtp = json['meta_foto_ktp'];
    metaFotoStnk = json['meta_foto_stnk'];
    metaFotoSkpd = json['meta_foto_skpd'];
    metaFotoKendaraan = json['meta_foto_kendaraan'];
    metaFotoLokasi = json['meta_foto_lokasi'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['kd_status'] = kdStatus;
    data['nm_status'] = nmStatus;
    data['id_telusur'] = idTelusur;
    data['kd_wil'] = kdWil;
    data['kd_jenis'] = kdJenis;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['kd_plat'] = kdPlat;
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
    data['tgl_ditugaskan'] = tglDitugaskan;
    data['nm_penelusur'] = nmPenelusur;
    data['username'] = username;
    data['nm_merek_kb'] = nmMerekKb;
    data['nm_model_kb'] = nmModelKb;
    data['th_buatan'] = thBuatan;
    data['warna_kb'] = warnaKb;
    data['nm_kecamatan'] = nmKecamatan;
    data['nm_kelurahan'] = nmKelurahan;
    data['foto_ktp'] = fotoKtp;
    data['foto_stnk'] = fotoStnk;
    data['foto_skpd'] = fotoSkpd;
    data['foto_kendaraan'] = fotoKendaraan;
    data['foto_lokasi'] = fotoLokasi;
    data['foto_ttd'] = fotoTtd;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['ket_ditolak'] = ketDitolak;
    data['tgl_verifikasi'] = tglVerifikasi;
    data['verifikator_id'] = verifikatorId;
    data['is_mock_location'] = isMockLocation;
    data['radius'] = radius;
    data['meta_foto_ktp'] = metaFotoKtp;
    data['meta_foto_stnk'] = metaFotoStnk;
    data['meta_foto_skpd'] = metaFotoSkpd;
    data['meta_foto_kendaraan'] = metaFotoKendaraan;
    data['meta_foto_lokasi'] = metaFotoLokasi;
    return data;
  }
}
