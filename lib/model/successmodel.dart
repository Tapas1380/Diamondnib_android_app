// To parse this JSON data, do
//
//     final successModel = successModelFromJson(jsonString);

import 'dart:convert';

SuccessModel successModelFromJson(String str) =>
    SuccessModel.fromJson(json.decode(str));

String successModelToJson(SuccessModel data) => json.encode(data.toJson());

class SuccessModel {
  int? status;
  String? message;
  String? success;
  String? errors;
  List<dynamic>? result;

  SuccessModel({
    this.status,
    this.message,
    this.result,
    this.success,
    this.errors,
  });

  factory SuccessModel.fromJson(Map<String, dynamic> json) => SuccessModel(
        status: (json["status"] is int)
            ? json["status"]
            : int.tryParse((json["status"] ?? "").toString()),
        message: (json["message"] ?? json["success"] ?? json["errors"])?.toString(),
        success: json["success"]?.toString(),
        errors: json["errors"]?.toString(),
        result: json["result"] == null
            ? null
            : List<dynamic>.from(json["result"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "success": success,
        "errors": errors,
        "result": List<dynamic>.from(result?.map((x) => x) ?? []),
      };
}
