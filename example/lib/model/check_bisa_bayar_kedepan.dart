import 'dart:convert';

class ResultCheckBisaBayar {
    final String? code;
    final DataCheckBisaBayar? data;
    final String? message;
    final ParamCheckBisaBayar? param;
    final bool? success;

    ResultCheckBisaBayar({
        this.code,
        this.data,
        this.message,
        this.param,
        this.success,
    });

    factory ResultCheckBisaBayar.fromRawJson(String str) => ResultCheckBisaBayar.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ResultCheckBisaBayar.fromJson(Map<String, dynamic> json) => ResultCheckBisaBayar(
        code: json["code"],
        data: json["data"] == null ? null : DataCheckBisaBayar.fromJson(json["data"]),
        message: json["message"],
        param: json["param"] == null ? null : ParamCheckBisaBayar.fromJson(json["param"]),
        success: json["success"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "data": data?.toJson(),
        "message": message,
        "param": param?.toJson(),
        "success": success,
    };
}

class DataCheckBisaBayar {
    final bool? isBisaBayarKedepan;
    final DateTime? tgAkhirPajakBaru;

    DataCheckBisaBayar({
        this.isBisaBayarKedepan,
        this.tgAkhirPajakBaru,
    });

    factory DataCheckBisaBayar.fromRawJson(String str) => DataCheckBisaBayar.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory DataCheckBisaBayar.fromJson(Map<String, dynamic> json) => DataCheckBisaBayar(
        isBisaBayarKedepan: json["is_bisa_bayar_kedepan"],
        tgAkhirPajakBaru: json["tg_akhir_pajak_baru"] == null ? null : DateTime.parse(json["tg_akhir_pajak_baru"]),
    );

    Map<String, dynamic> toJson() => {
        "is_bisa_bayar_kedepan": isBisaBayarKedepan,
        "tg_akhir_pajak_baru": "${tgAkhirPajakBaru!.year.toString().padLeft(4, '0')}-${tgAkhirPajakBaru!.month.toString().padLeft(2, '0')}-${tgAkhirPajakBaru!.day.toString().padLeft(2, '0')}",
    };
}

class ParamCheckBisaBayar {
    final DateTime? tgAkhirPajak;
    final DateTime? tgProsesTetap;

    ParamCheckBisaBayar({
        this.tgAkhirPajak,
        this.tgProsesTetap,
    });

    factory ParamCheckBisaBayar.fromRawJson(String str) => ParamCheckBisaBayar.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ParamCheckBisaBayar.fromJson(Map<String, dynamic> json) => ParamCheckBisaBayar(
        tgAkhirPajak: json["tg_akhir_pajak"] == null ? null : DateTime.parse(json["tg_akhir_pajak"]),
        tgProsesTetap: json["tg_proses_tetap"] == null ? null : DateTime.parse(json["tg_proses_tetap"]),
    );

    Map<String, dynamic> toJson() => {
        "tg_akhir_pajak": "${tgAkhirPajak!.year.toString().padLeft(4, '0')}-${tgAkhirPajak!.month.toString().padLeft(2, '0')}-${tgAkhirPajak!.day.toString().padLeft(2, '0')}",
        "tg_proses_tetap": "${tgProsesTetap!.year.toString().padLeft(4, '0')}-${tgProsesTetap!.month.toString().padLeft(2, '0')}-${tgProsesTetap!.day.toString().padLeft(2, '0')}",
    };
}
