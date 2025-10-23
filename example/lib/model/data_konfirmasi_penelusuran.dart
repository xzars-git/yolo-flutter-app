import 'package:hive/hive.dart';
part 'data_konfirmasi_penelusuran.g.dart';

@HiveType(typeId: 3)
class DataKonfirmasiPenelusuranResult {
  @HiveField(0)
  List<DataKonfirmasiPenelusuran>? listDataDaftarPenelusuran;

  DataKonfirmasiPenelusuranResult({this.listDataDaftarPenelusuran});
  DataKonfirmasiPenelusuranResult.copy(DataKonfirmasiPenelusuranResult other) {
    listDataDaftarPenelusuran = other.listDataDaftarPenelusuran;
  }
}

@HiveType(typeId: 4)
class DataKonfirmasiPenelusuran {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? kdStatus;
  @HiveField(2)
  String? idTelusur;
  @HiveField(3)
  String? kdWil;
  @HiveField(5)
  String? kdPlat;
  @HiveField(6)
  String? kdJenis;
  @HiveField(7)
  String? noRangka;
  @HiveField(8)
  String? noKtp;
  @HiveField(9)
  String? noHp;
  @HiveField(10)
  String? tglCetak;
  @HiveField(11)
  String? tglTelusur;
  @HiveField(12)
  String? kdTelusur;
  @HiveField(13)
  String? ketAlasan;
  @HiveField(14)
  String? noSurat;
  @HiveField(15)
  String? noSpkp2kb;
  @HiveField(16)
  String? nmPemilik;
  @HiveField(17)
  String? alamatPemilik;
  @HiveField(18)
  String? kdKecamatan;
  @HiveField(19)
  String? kdPos;
  @HiveField(20)
  String? tglAkhirPajak;
  @HiveField(21)
  String? tglAkhirStnk;
  @HiveField(22)
  String? idPenelusur;
  @HiveField(23)
  String? nmPenelusur;
  @HiveField(24)
  String? tglDitugaskan;
  @HiveField(25)
  String? nmMerekKb;
  @HiveField(26)
  String? nmModelKb;
  @HiveField(27)
  String? thBuatan;
  @HiveField(28)
  String? warnaKb;
  @HiveField(29)
  String? nmKecamatan;
  @HiveField(30)
  String? nmKelurahan;
  @HiveField(31)
  int? jmlPkbPok;
  @HiveField(32)
  int? jmlPkbDen;
  @HiveField(33)
  String? radiusLongtitude;
  @HiveField(34)
  String? radiusLatitude;
  @HiveField(35)
  String? pathKtp;
  @HiveField(36)
  String? pathStnk;
  @HiveField(37)
  String? pathSkpd;
  @HiveField(38)
  String? pathKendaraan;
  @HiveField(39)
  String? pathLokasi;
  @HiveField(40)
  String? pathTtd;
  @HiveField(41)
  String? selectedKriteria;
  @HiveField(42)
  String? inputNoHp;
  @HiveField(43)
  String? latitudePicture;
  @HiveField(44)
  String? longitudePicture;
  @HiveField(45)
  String? uraianKriteria;
  @HiveField(46)
  bool? uraianKriteriaBoolean;
  @HiveField(47)
  String? base64DataTandaTangan;
  @HiveField(48)
  Map<dynamic, dynamic>? jsonDataTandaTangan;
  @HiveField(49)
  String? siapBayar;
  @HiveField(50)
  String? tglPembayaran;
  @HiveField(51)
  String? rangePengambilanPhoto;
  @HiveField(52)
  String? informationKtp;
  @HiveField(53)
  String? informationStnk;
  @HiveField(54)
  String? informationSkpd;
  @HiveField(55)
  String? informationKendaraan;
  @HiveField(56)
  String? informationLokasi;
  @HiveField(57)
  bool isUploadTandaTangan;
  @HiveField(58)
  String? base64Ktp;
  @HiveField(59)
  String? base64Stnk;
  @HiveField(60)
  String? base64Skpd;
  @HiveField(61)
  String? base64Kendaraan;
  @HiveField(62)
  String? base64Lokasi;
  @HiveField(63)
  String? noPolisi1;
  @HiveField(64)
  String? noPolisi2;
  @HiveField(65)
  String? noPolisi3;

  DataKonfirmasiPenelusuran({
    this.id,
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
    this.radiusLongtitude,
    this.radiusLatitude,
    this.pathKtp,
    this.pathStnk,
    this.pathSkpd,
    this.pathKendaraan,
    this.pathLokasi,
    this.pathTtd,
    this.selectedKriteria,
    this.inputNoHp,
    this.latitudePicture,
    this.longitudePicture,
    this.uraianKriteria,
    this.uraianKriteriaBoolean,
    this.base64DataTandaTangan,
    this.jsonDataTandaTangan,
    this.siapBayar,
    this.tglPembayaran,
    this.rangePengambilanPhoto,
    this.informationKtp,
    this.informationStnk,
    this.informationSkpd,
    this.informationKendaraan,
    this.informationLokasi,
    this.isUploadTandaTangan = false,
    this.base64Ktp,
    this.base64Stnk,
    this.base64Skpd,
    this.base64Kendaraan,
    this.base64Lokasi,
  });
}
