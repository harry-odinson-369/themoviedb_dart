import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:base32/base32.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RequestMethod {
  get,
  post,
  put,
  delete,
  patch,
}

class RequestConfig {
  RequestMethod method = RequestMethod.get;
  Map<String, String>? headers;
  Object? body;
  Encoding? encoding;
  int successStatusCode;

  RequestConfig({
    this.method = RequestMethod.get,
    this.headers,
    this.body,
    this.encoding,
    this.successStatusCode = 200,
  });

  RequestConfig copy({
    RequestMethod? method,
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    int? successStatusCode,
    Map<String, String> Function(Map<String, String> headers)? overrideHeaders,
  }) =>
      RequestConfig(
        method: method ?? this.method,
        headers: overrideHeaders?.call({...(this.headers ?? {})}) ??
            (headers ?? this.headers),
        body: body ?? this.body,
        encoding: encoding ?? this.encoding,
        successStatusCode: successStatusCode ?? this.successStatusCode,
      );
}

class RequestResponse {
  DateTime? expire;
  String data;
  int statusCode;

  RequestResponse({
    required this.data,
    this.expire,
    required this.statusCode,
  });

  factory RequestResponse.fromMap(Map<String, dynamic> map) => RequestResponse(
        data: map["data"] ?? "",
        expire: map["expire"] != null ? DateTime.parse(map["expire"]) : null,
        statusCode: map["status_code"] ?? 0,
      );

  Map<String, dynamic> toMap() => {
        "data": data,
        "expire": expire?.toString(),
        "status_code": statusCode,
      };
}

class Request {
  static bool isExpired(DateTime date) => DateTime.now().isAfter(date);

  static Future<bool> setCache(String url, RequestResponse resp) async {
    String key = base32.encodeString(url);
    var pref = await SharedPreferences.getInstance();
    return pref.setString(key, json.encode(resp.toMap()));
  }

  static Future<bool> clearCache(String url) async {
    String key = base32.encodeString(url);
    var pref = await SharedPreferences.getInstance();
    return pref.remove(key);
  }

  static Future<RequestResponse?> send(
    String target, {
    RequestConfig? options,
  }) async {
    try {
      RequestConfig config = options ?? RequestConfig();

      String key = base32.encodeString(target);
      var pref = await SharedPreferences.getInstance();
      var resp = pref.getString(key);

      if (resp != null) {
        var data = RequestResponse.fromMap(json.decode(resp));
        if (data.expire != null && !isExpired(data.expire!)) {
          return data;
        }
      }

      Uri uri = Uri.parse(target);

      late Future<http.Response> future;

      switch (config.method) {
        case RequestMethod.get:
          future = http.get(
            uri,
            headers: config.headers,
          );
        case RequestMethod.post:
          future = http.post(
            uri,
            headers: config.headers,
            body: config.body,
            encoding: config.encoding,
          );
        case RequestMethod.delete:
          future = http.delete(
            uri,
            headers: config.headers,
            body: config.body,
            encoding: config.encoding,
          );
        case RequestMethod.put:
          future = http.put(
            uri,
            headers: config.headers,
            body: config.body,
            encoding: config.encoding,
          );
        case RequestMethod.patch:
          future = http.patch(
            uri,
            headers: config.headers,
            body: config.body,
            encoding: config.encoding,
          );
      }

      var response = await future;

      var httpResponse = RequestResponse(
        data: response.body,
        expire: null,
        statusCode: response.statusCode,
      );

      if (response.statusCode != config.successStatusCode) {
        log("[TMDb] Failed to request ${uri.toString()}\nstatus: ${response.statusCode}\nheaders: ${response.request?.headers}\nencoding: ${config.encoding}\nbody: ${config.body.toString()}\nresponse_body: ${response.body}");
      }
      return httpResponse;
    } catch (err) {
      rethrow;
    }
  }
}
