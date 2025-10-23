import 'package:ultralytics_yolo_example/util/string_util/string_util.dart';

class GetDataTelusurMandiri {
  int? code;
  List<DataTelusurMandiri>? data;
  int? limit;
  int? page;
  String? status;
  int? totalData;
  int? totalPage;

  GetDataTelusurMandiri({
    this.code,
    this.data,
    this.limit,
    this.page,
    this.status,
    this.totalData,
    this.totalPage,
  });

  GetDataTelusurMandiri.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    if (json['data'] != null) {
      data = <DataTelusurMandiri>[];
      json['data'].forEach((v) {
        data!.add(DataTelusurMandiri.fromJson(v));
      });
    }
    limit = json['limit'];
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
    data['page'] = page;
    data['status'] = status;
    data['total_data'] = totalData;
    data['total_page'] = totalPage;
    return data;
  }
}

class DataTelusurMandiri {
  String? id;
  String? idPenelusur;
  String? noIdentitas;
  String? noMesin;
  String? noPolisi1;
  String? noPolisi2;
  String? noPolisi3;
  String? noRangka;
  String? tgAkhirPajak;
  String? tgAkhirStnk;
  String? tgProsesTetap;
  String? thBuatan;
  String? tglTelusur;
  String? warnaKb;
  String? alPemilik;
  String? nmPemilik;
  String? bobot;
  String? email;
  String? jenisIdentitas;
  String? kdBlockir;
  String? kdFungsiKb;
  String? kdMerekKb;
  String? kdProteksi;
  String? kdWil;
  String? subKdWil;
  String? milikKe;
  String? nilaiJual;
  String? nmFungsiKb;
  String? nmJenisKb;
  String? nmMerekKb;
  String? nmModelKb;
  String? nmWil;
  String? noWa;
  String? noHp;
  String? besaranPajak;
  String? besaranOps;
  String? besaranDenda;
  String? besaranDendaOps;
  String? fotoStikerKb;
  String? kdPlat;
  String? statusTelusur;
  String? kdWilKb;
  String? namaPenelusur;
  String? username;

  DataTelusurMandiri({
    this.id,
    this.idPenelusur,
    this.noIdentitas,
    this.noMesin,
    this.noPolisi1,
    this.noPolisi2,
    this.noPolisi3,
    this.noRangka,
    this.tgAkhirPajak,
    this.tgAkhirStnk,
    this.tgProsesTetap,
    this.thBuatan,
    this.tglTelusur,
    this.warnaKb,
    this.alPemilik,
    this.nmPemilik,
    this.bobot,
    this.email,
    this.jenisIdentitas,
    this.kdBlockir,
    this.kdFungsiKb,
    this.kdMerekKb,
    this.kdProteksi,
    this.kdWil,
    this.subKdWil,
    this.milikKe,
    this.nilaiJual,
    this.nmFungsiKb,
    this.nmJenisKb,
    this.nmMerekKb,
    this.nmModelKb,
    this.nmWil,
    this.noWa,
    this.noHp,
    this.besaranPajak,
    this.besaranOps,
    this.besaranDenda,
    this.besaranDendaOps,
    this.fotoStikerKb,
    this.kdPlat,
    this.statusTelusur,
    this.kdWilKb,
    this.namaPenelusur,
    this.username,
  });

  DataTelusurMandiri.fromJson(Map<String, dynamic> json) {
    id = checkModel(json['id']);
    idPenelusur = checkModel(json['id_penelusur']);
    noIdentitas = checkModel(json['no_identitas']);
    noMesin = checkModel(json['no_mesin']);
    noPolisi1 = checkModel(json['no_polisi1']);
    noPolisi2 = checkModel(json['no_polisi2']);
    noPolisi3 = checkModel(json['no_polisi3']);
    noRangka = checkModel(json['no_rangka']);
    tgAkhirPajak = checkModel(json['tg_akhir_pajak']);
    tgAkhirStnk = checkModel(json['tg_akhir_stnk']);
    tgProsesTetap = checkModel(json['tg_proses_tetap']);
    thBuatan = checkModel(json['th_buatan']);
    tglTelusur = checkModel(json['tgl_telusur']);
    warnaKb = checkModel(json['warna_kb']);
    alPemilik = checkModel(json['al_pemilik']);
    nmPemilik = checkModel(json['nm_pemilik']);
    bobot = checkModel(json['bobot']);
    email = checkModel(json['email']);
    jenisIdentitas = checkModel(json['jenis_identitas']);
    kdBlockir = checkModel(json['kd_blockir']);
    kdFungsiKb = checkModel(json['kd_fungsi_kb']);
    kdMerekKb = checkModel(json['kd_merek_kb']);
    kdProteksi = checkModel(json['kd_proteksi']);
    kdWil = checkModel(json['kd_wil']);
    subKdWil = checkModel(json['sub_kd_wil']);
    milikKe = checkModel(json['milik_ke']);
    nilaiJual = checkModel(json['nilai_jual']);
    nmFungsiKb = checkModel(json['nm_fungsi_kb']);
    nmJenisKb = checkModel(json['nm_jenis_kb']);
    nmMerekKb = checkModel(json['nm_merek_kb']);
    nmModelKb = checkModel(json['nm_model_kb']);
    nmWil = checkModel(json['nm_wil']);
    noWa = checkModel(json['no_wa']);
    noHp = checkModel(json['no_hp']);
    besaranPajak = checkModel(json['besaran_pajak']);
    besaranOps = checkModel(json['besaran_ops']);
    besaranDenda = checkModel(json['besaran_denda']);
    besaranDendaOps = checkModel(json['besaran_denda_ops']);
    fotoStikerKb = checkModel(json['foto_stiker_kb']);
    kdPlat = checkModel(json['kd_plat']);
    statusTelusur = checkModel(json['status_telusur']);
    kdWilKb = checkModel(json['kd_wil_kb']);
    namaPenelusur = checkModel(json['nama_penelusur']);
    username = checkModel(json['username']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['id_penelusur'] = idPenelusur;
    data['no_identitas'] = noIdentitas;
    data['no_mesin'] = noMesin;
    data['no_polisi1'] = noPolisi1;
    data['no_polisi2'] = noPolisi2;
    data['no_polisi3'] = noPolisi3;
    data['no_rangka'] = noRangka;
    data['tg_akhir_pajak'] = tgAkhirPajak;
    data['tg_akhir_stnk'] = tgAkhirStnk;
    data['tg_proses_tetap'] = tgProsesTetap;
    data['th_buatan'] = thBuatan;
    data['tgl_telusur'] = tglTelusur;
    data['warna_kb'] = warnaKb;
    data['al_pemilik'] = alPemilik;
    data['nm_pemilik'] = nmPemilik;
    data['bobot'] = bobot;
    data['email'] = email;
    data['jenis_identitas'] = jenisIdentitas;
    data['kd_blockir'] = kdBlockir;
    data['kd_fungsi_kb'] = kdFungsiKb;
    data['kd_merek_kb'] = kdMerekKb;
    data['kd_proteksi'] = kdProteksi;
    data['kd_wil'] = kdWil;
    data['sub_kd_wil'] = subKdWil;
    data['milik_ke'] = milikKe;
    data['nilai_jual'] = nilaiJual;
    data['nm_fungsi_kb'] = nmFungsiKb;
    data['nm_jenis_kb'] = nmJenisKb;
    data['nm_merek_kb'] = nmMerekKb;
    data['nm_model_kb'] = nmModelKb;
    data['nm_wil'] = nmWil;
    data['no_wa'] = noWa;
    data['no_hp'] = noHp;
    data['besaran_pajak'] = besaranPajak;
    data['besaran_ops'] = besaranOps;
    data['besaran_denda'] = besaranDenda;
    data['besaran_denda_ops'] = besaranDendaOps;
    data['foto_stiker_kb'] = fotoStikerKb;
    data['kd_plat'] = kdPlat;
    data['status_telusur'] = statusTelusur;
    data['kd_wil_kb'] = kdWilKb;
    data['nama_penelusur'] = namaPenelusur;
    data['username'] = username;
    return data;
  }
}
