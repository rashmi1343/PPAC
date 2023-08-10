

import 'dart:convert';

LoginResponse loginResponseFromJson(String str) =>
    LoginResponse.fromJson(json.decode(str));

String loginResponseToJson(LoginResponse data) => json.encode(data.toJson());

class LoginResponse {
  LoginResponse({
    this.message,
    this.token,
  });

  String? message;
  String? token;

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json["message"] ?? "",
        token: json["token"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "token": token,
      };
}
