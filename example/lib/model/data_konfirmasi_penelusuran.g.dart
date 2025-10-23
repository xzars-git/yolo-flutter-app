// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_konfirmasi_penelusuran.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataKonfirmasiPenelusuranResultAdapter
    extends TypeAdapter<DataKonfirmasiPenelusuranResult> {
  @override
  final int typeId = 3;

  @override
  DataKonfirmasiPenelusuranResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataKonfirmasiPenelusuranResult(
      listDataDaftarPenelusuran:
          (fields[0] as List?)?.cast<DataKonfirmasiPenelusuran>(),
    );
  }

  @override
  void write(BinaryWriter writer, DataKonfirmasiPenelusuranResult obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.listDataDaftarPenelusuran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataKonfirmasiPenelusuranResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataKonfirmasiPenelusuranAdapter
    extends TypeAdapter<DataKonfirmasiPenelusuran> {
  @override
  final int typeId = 4;

  @override
  DataKonfirmasiPenelusuran read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataKonfirmasiPenelusuran(
      id: fields[0] as String?,
      kdStatus: fields[1] as String?,
      idTelusur: fields[2] as String?,
      kdWil: fields[3] as String?,
      noPolisi1: fields[63] as String?,
      noPolisi2: fields[64] as String?,
      noPolisi3: fields[65] as String?,
      kdPlat: fields[5] as String?,
      kdJenis: fields[6] as String?,
      noRangka: fields[7] as String?,
      noKtp: fields[8] as String?,
      noHp: fields[9] as String?,
      tglCetak: fields[10] as String?,
      tglTelusur: fields[11] as String?,
      kdTelusur: fields[12] as String?,
      ketAlasan: fields[13] as String?,
      noSurat: fields[14] as String?,
      noSpkp2kb: fields[15] as String?,
      nmPemilik: fields[16] as String?,
      alamatPemilik: fields[17] as String?,
      kdKecamatan: fields[18] as String?,
      kdPos: fields[19] as String?,
      tglAkhirPajak: fields[20] as String?,
      tglAkhirStnk: fields[21] as String?,
      idPenelusur: fields[22] as String?,
      nmPenelusur: fields[23] as String?,
      tglDitugaskan: fields[24] as String?,
      nmMerekKb: fields[25] as String?,
      nmModelKb: fields[26] as String?,
      thBuatan: fields[27] as String?,
      warnaKb: fields[28] as String?,
      nmKecamatan: fields[29] as String?,
      nmKelurahan: fields[30] as String?,
      jmlPkbPok: fields[31] as int?,
      jmlPkbDen: fields[32] as int?,
      radiusLongtitude: fields[33] as String?,
      radiusLatitude: fields[34] as String?,
      pathKtp: fields[35] as String?,
      pathStnk: fields[36] as String?,
      pathSkpd: fields[37] as String?,
      pathKendaraan: fields[38] as String?,
      pathLokasi: fields[39] as String?,
      pathTtd: fields[40] as String?,
      selectedKriteria: fields[41] as String?,
      inputNoHp: fields[42] as String?,
      latitudePicture: fields[43] as String?,
      longitudePicture: fields[44] as String?,
      uraianKriteria: fields[45] as String?,
      uraianKriteriaBoolean: fields[46] as bool?,
      base64DataTandaTangan: fields[47] as String?,
      jsonDataTandaTangan: (fields[48] as Map?)?.cast<dynamic, dynamic>(),
      siapBayar: fields[49] as String?,
      tglPembayaran: fields[50] as String?,
      rangePengambilanPhoto: fields[51] as String?,
      informationKtp: fields[52] as String?,
      informationStnk: fields[53] as String?,
      informationSkpd: fields[54] as String?,
      informationKendaraan: fields[55] as String?,
      informationLokasi: fields[56] as String?,
      isUploadTandaTangan: fields[57] as bool,
      base64Ktp: fields[58] as String?,
      base64Stnk: fields[59] as String?,
      base64Skpd: fields[60] as String?,
      base64Kendaraan: fields[61] as String?,
      base64Lokasi: fields[62] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataKonfirmasiPenelusuran obj) {
    writer
      ..writeByte(65)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.kdStatus)
      ..writeByte(2)
      ..write(obj.idTelusur)
      ..writeByte(3)
      ..write(obj.kdWil)
      ..writeByte(5)
      ..write(obj.kdPlat)
      ..writeByte(6)
      ..write(obj.kdJenis)
      ..writeByte(7)
      ..write(obj.noRangka)
      ..writeByte(8)
      ..write(obj.noKtp)
      ..writeByte(9)
      ..write(obj.noHp)
      ..writeByte(10)
      ..write(obj.tglCetak)
      ..writeByte(11)
      ..write(obj.tglTelusur)
      ..writeByte(12)
      ..write(obj.kdTelusur)
      ..writeByte(13)
      ..write(obj.ketAlasan)
      ..writeByte(14)
      ..write(obj.noSurat)
      ..writeByte(15)
      ..write(obj.noSpkp2kb)
      ..writeByte(16)
      ..write(obj.nmPemilik)
      ..writeByte(17)
      ..write(obj.alamatPemilik)
      ..writeByte(18)
      ..write(obj.kdKecamatan)
      ..writeByte(19)
      ..write(obj.kdPos)
      ..writeByte(20)
      ..write(obj.tglAkhirPajak)
      ..writeByte(21)
      ..write(obj.tglAkhirStnk)
      ..writeByte(22)
      ..write(obj.idPenelusur)
      ..writeByte(23)
      ..write(obj.nmPenelusur)
      ..writeByte(24)
      ..write(obj.tglDitugaskan)
      ..writeByte(25)
      ..write(obj.nmMerekKb)
      ..writeByte(26)
      ..write(obj.nmModelKb)
      ..writeByte(27)
      ..write(obj.thBuatan)
      ..writeByte(28)
      ..write(obj.warnaKb)
      ..writeByte(29)
      ..write(obj.nmKecamatan)
      ..writeByte(30)
      ..write(obj.nmKelurahan)
      ..writeByte(31)
      ..write(obj.jmlPkbPok)
      ..writeByte(32)
      ..write(obj.jmlPkbDen)
      ..writeByte(33)
      ..write(obj.radiusLongtitude)
      ..writeByte(34)
      ..write(obj.radiusLatitude)
      ..writeByte(35)
      ..write(obj.pathKtp)
      ..writeByte(36)
      ..write(obj.pathStnk)
      ..writeByte(37)
      ..write(obj.pathSkpd)
      ..writeByte(38)
      ..write(obj.pathKendaraan)
      ..writeByte(39)
      ..write(obj.pathLokasi)
      ..writeByte(40)
      ..write(obj.pathTtd)
      ..writeByte(41)
      ..write(obj.selectedKriteria)
      ..writeByte(42)
      ..write(obj.inputNoHp)
      ..writeByte(43)
      ..write(obj.latitudePicture)
      ..writeByte(44)
      ..write(obj.longitudePicture)
      ..writeByte(45)
      ..write(obj.uraianKriteria)
      ..writeByte(46)
      ..write(obj.uraianKriteriaBoolean)
      ..writeByte(47)
      ..write(obj.base64DataTandaTangan)
      ..writeByte(48)
      ..write(obj.jsonDataTandaTangan)
      ..writeByte(49)
      ..write(obj.siapBayar)
      ..writeByte(50)
      ..write(obj.tglPembayaran)
      ..writeByte(51)
      ..write(obj.rangePengambilanPhoto)
      ..writeByte(52)
      ..write(obj.informationKtp)
      ..writeByte(53)
      ..write(obj.informationStnk)
      ..writeByte(54)
      ..write(obj.informationSkpd)
      ..writeByte(55)
      ..write(obj.informationKendaraan)
      ..writeByte(56)
      ..write(obj.informationLokasi)
      ..writeByte(57)
      ..write(obj.isUploadTandaTangan)
      ..writeByte(58)
      ..write(obj.base64Ktp)
      ..writeByte(59)
      ..write(obj.base64Stnk)
      ..writeByte(60)
      ..write(obj.base64Skpd)
      ..writeByte(61)
      ..write(obj.base64Kendaraan)
      ..writeByte(62)
      ..write(obj.base64Lokasi)
      ..writeByte(63)
      ..write(obj.noPolisi1)
      ..writeByte(64)
      ..write(obj.noPolisi2)
      ..writeByte(65)
      ..write(obj.noPolisi3);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataKonfirmasiPenelusuranAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
