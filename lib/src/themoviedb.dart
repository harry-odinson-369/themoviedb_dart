import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:themoviedb_dart/src/helper/api.dart';
import 'package:themoviedb_dart/src/helper/request.dart';
import 'package:themoviedb_dart/src/models/account.dart';
import 'package:themoviedb_dart/src/models/config.dart';
import 'package:themoviedb_dart/src/models/credential.dart';
import 'package:themoviedb_dart/src/models/playlists.dart';
import 'package:themoviedb_dart/src/models/playlist.dart';

TMDbAccessConfig _config = TMDbAccessConfig(
  apiKey: "apiKey",
  accessToken: "accessToken",
);

class TheMovieDb {
  static TheMovieDb? _v3;
  static TheMovieDb get v3 {
    _v3 ??= TheMovieDb();
    return _v3!;
  }

  static void log(String any) {
    debugPrint("[TheMovieDb Dart] $any");
  }

  ///Set a default [apiKey] or [accessToken].
  void config(TMDbAccessConfig config) {
    _config = config;
  }

  String _requestUrl(String url, [String? apiKey]) =>
      "$url${apiKey != null ? "${url.contains("?") ? "&" : "?"}api_key=$apiKey" : ""}";

  RequestConfig get _requestOptions {
    RequestConfig newConfig = RequestConfig();
    if (_config.accessToken.isNotEmpty) {
      newConfig.headers = <String, String>{};
      newConfig.headers![HttpHeaders.authorizationHeader] =
          "Bearer ${_config.accessToken}";
    }
    return newConfig;
  }

  ///Get a [request_token] from [themoviedb.org] api. once you've got the [request_token], use it to authorize the permission from user by open this page [https://themoviedb.org/authenticate/{request_token}].
  Future<String?> getRequestToken({String? apiKey}) async {
    String requestUrl = _requestUrl(
      "${TMDbApi.base}/authentication/token/new",
      apiKey,
    );
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) => {
          ...headers,
          HttpHeaders.contentTypeHeader: "application/json",
        },
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["request_token"];
    }

    return null;
  }

  ///Get a [session_id] from themoviedb.org api with provided [requestToken].
  Future<String?> getSessionId(
    String requestToken, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/authentication/session/new",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        overrideHeaders: (headers) => {
          ...headers,
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode({
          "request_token": requestToken,
        }),
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["session_id"];
    }

    return null;
  }

  ///Get [User Account] information with [session_id] get from [getSessionId] method.
  Future<TMDbCredentialModel?> getUserAccount(
    String sessionId, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/account?session_id=$sessionId",
      apiKey,
    );
    var response = await Request.send(requestUrl);

    if (response != null) {
      var map = json.decode(response.data);
      var userInfo = TMDbUserAccount.fromJson(map);
      return TMDbCredentialModel(
        sessionId: sessionId,
        user: userInfo,
      );
    }

    return null;
  }

  ///Create a new playlist and return [list_id];
  Future<int?> createPlaylist(
    String sessionId, {
    required String name,
    required String description,
    String? language,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list?session_id=$sessionId",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        successStatusCode: HttpStatus.created,
        overrideHeaders: (headers) => {
          ...headers,
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(
          {
            "name": name,
            "description": description,
            "language": language ?? "en",
          },
        ),
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["list_id"];
    }

    return null;
  }

  ///Return [true] if the playlist has deleted successfully.
  Future<bool> deletePlaylist(
    int listId,
    String sessionId, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$listId?session_id=$sessionId",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.delete,
      ),
    );

    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future<TMDbPlaylists?> getAllPlaylist(
    int accountId,
    String sessionId, {
    int page = 1,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/account/$accountId/lists?page=$page&session_id=$sessionId",
      apiKey,
    );
    var response = await Request.send(requestUrl);

    if (response != null) {
      return await compute(
        (msg) => TMDbPlaylists.fromJson(json.decode(msg)),
        response.data,
      );
    }

    return null;
  }

  Future<TMDbPlaylist?> getPlaylist(
    int listId, {
    int page = 1,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$listId?page=$page",
      apiKey,
    );

    var response = await Request.send(requestUrl);

    if (response != null) {
      return await compute(
        (msg) => TMDbPlaylist.fromJson(json.decode(msg)),
        response.data,
      );
    }

    return null;
  }

  Future<bool> addToPlaylist(
    int mediaId,
    int listId,
    String sessionId, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$listId/add_item?session_id=$sessionId",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        successStatusCode: HttpStatus.created,
        overrideHeaders: (headers) => {
          ...headers,
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode({
          "media_id": mediaId,
        }),
      ),
    );

    return response != null && response.statusCode == HttpStatus.created;
  }
}
