import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:themoviedb_dart/src/helper/api.dart';
import 'package:themoviedb_dart/src/helper/request.dart';
import 'package:themoviedb_dart/src/models/access_token_response.dart';
import 'package:themoviedb_dart/src/models/account.dart';
import 'package:themoviedb_dart/src/models/config.dart';
import 'package:themoviedb_dart/src/models/credential.dart';
import 'package:themoviedb_dart/src/models/playlist_detail.dart';
import 'package:themoviedb_dart/src/models/playlists.dart';

TMDbAccessConfig _config = TMDbAccessConfig(
  apiKey: "apiKey",
  accessToken: "accessToken",
);

class TheMovieDb {
  static TheMovieDb? _v4;
  static TheMovieDb get v4 {
    _v4 ??= TheMovieDb();
    return _v4!;
  }

  static void log(String any) {
    debugPrint("[TheMovieDb Dart] $any");
  }

  ///Set a default [apiKey] or [accessToken].
  void config(TMDbAccessConfig config) {
    _config = config;
  }

  String _requestUrl(String url, [String? apiKey]) {
    if (apiKey == "") {
      return url;
    } else if (apiKey != null) {
      return "$url${url.contains("?") ? "&" : "?"}api_key=$apiKey";
    } else if (_config.apiKey.isNotEmpty) {
      return "$url${url.contains("?") ? "&" : "?"}api_key=${_config.apiKey}";
    } else {
      return url;
    }
  }

  RequestConfig get _requestOptions {
    RequestConfig newConfig = RequestConfig();
    if (_config.accessToken.isNotEmpty) {
      newConfig.headers = <String, String>{};
      newConfig.headers![HttpHeaders.authorizationHeader] =
          "Bearer ${_config.accessToken}";
    }
    return newConfig;
  }

  ///Get a [request_token] from [themoviedb.org] api. once you've got the [request_token], use it to authorize the permission from user by open this page [https://themoviedb.org/auth/access?request_token={request_token}].
  Future<String?> getRequestTokenV4({String? apiKey, String? redirect}) async {
    String requestUrl = _requestUrl(
      "${TMDbApi.base}/auth/request_token",
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
        body: redirect != null
            ? jsonEncode({
                "redirect_to": redirect,
              })
            : null,
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["request_token"];
    }

    return null;
  }

  ///Get a [request_token] from [themoviedb.org] api. once you've got the [request_token], use it to authorize the permission from user by open this page [https://themoviedb.org/authenticate/{request_token}].
  Future<String?> getRequestTokenV3({String? apiKey}) async {
    String requestUrl = _requestUrl(
      "${TMDbApi.base.replaceAll("4", "3")}/authentication/token/new",
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

  Future<String?> getSessionId(
    String requestTokenV3, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base.replaceAll("4", "3")}/authentication/session/new",
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
          "request_token": requestTokenV3,
        }),
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["session_id"];
    }

    return null;
  }

  ///Get an [accessToken] from themoviedb.org api with provided [requestToken].
  Future<AccessTokenResponse?> getAccessToken(
    String requestTokenV4, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/auth/access_token",
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
          "request_token": requestTokenV4,
        }),
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return AccessTokenResponse.fromMap(map);
    }

    return null;
  }

  ///Get [User Account] information with [session_id] get from [getSessionId] method.
  Future<TMDbCredentialModel?> getUserAccount(
    String sessionId,
    String accessToken,
    String accountId, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base.replaceAll("4", "3")}/account?session_id=$sessionId",
      apiKey,
    );
    var response = await Request.send(requestUrl);

    if (response != null) {
      var map = json.decode(response.data);
      var userInfo = TMDbUserAccount.fromJson(map);
      return TMDbCredentialModel(
        sessionId: sessionId,
        accessToken: accessToken,
        accountId: accountId,
        user: userInfo,
      );
    }

    return null;
  }

  ///Create a new playlist and return [id] of the list;
  Future<int?> createPlaylist({
    required String accessToken,
    required String name,
    required String description,
    String? iso6391,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        successStatusCode: 201,
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
        body: jsonEncode(
          {
            "name": name,
            "description": description,
            "iso_639_1": iso6391 ?? "en",
          },
        ),
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["id"];
    }

    return null;
  }

  ///Return [true] if the playlist has been deleted successfully.
  Future<bool> deletePlaylist(
    int id,
    String accessToken, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.delete,
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
      ),
    );

    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future<TMDbPlaylistsModel?> getAllPlaylist(
    String accountId,
    String accessToken, {
    int page = 1,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/account/$accountId/lists?page=$page",
      apiKey,
    );
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
      ),
    );

    if (response != null) {
      return await compute(
        (msg) => TMDbPlaylistsModel.fromMap(json.decode(msg)),
        response.data,
      );
    }

    return null;
  }

  Future<TMDbPlaylistDetailModel?> getPlaylist(
    int id,
    String accessToken, {
    int page = 1,
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id?page=$page",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
      ),
    );

    if (response != null) {
      return await compute(
        (msg) => TMDbPlaylistDetailModel.fromMap(json.decode(msg)),
        response.data,
      );
    }

    return null;
  }

  Future<bool> isAdded(
    int mediaId,
    int id,
    String mediaType,
    String accessToken, [
    String? apiKey,
  ]) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id/item_status?media_id=$mediaId&media_type=$mediaType",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
      ),
    );

    if (response != null) {
      var map = json.decode(response.data);
      var isSuccess = map["success"] ?? false;
      var id = map["media_id"] ?? 0;
      var type = map["media_type"] ?? "";
      return isSuccess == true &&
          id == mediaId &&
          type == mediaType &&
          response.statusCode == 200;
    } else {
      return false;
    }
  }

  Future<bool> addToPlaylist(
    int id,
    List<TMDbMovieModel> items,
    String accessToken, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id/items",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
        body: jsonEncode({
          "items": items
              .map((e) => {
                    "media_type": e.type,
                    "media_id": e.id,
                  })
              .toList(),
        }),
      ),
    );

    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future<bool> removeItems(
    int id,
    List<TMDbMovieModel> items,
    String accessToken, {
    String? apiKey,
  }) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id/items",
      apiKey,
    );

    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.delete,
        overrideHeaders: (headers) {
          var cloned = {...headers};
          cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
          return {
            ...cloned,
            HttpHeaders.contentTypeHeader: "application/json",
          };
        },
        body: jsonEncode({
          "items": items
              .map((e) => {
                    "media_type": e.type,
                    "media_id": e.id,
                  })
              .toList(),
        }),
      ),
    );

    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future clearItems(
    int id,
    String accessToken, [
    String? apiKey,
  ]) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id/clear",
      apiKey,
    );

    var response = await Request.send(requestUrl, options: _requestOptions.copy(
      overrideHeaders: (headers) {
        var cloned = {...headers};
        cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
        return {
          ...cloned,
          HttpHeaders.contentTypeHeader: "application/json",
        };
      },
    ));

    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future updatePlaylist(
    int id,
    Map<String, dynamic> data,
    String accessToken, [
    String? apiKey,
  ]) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/list/$id",
      apiKey,
    );

    var response = await Request.send(requestUrl,
        options: _requestOptions.copy(
          method: RequestMethod.put,
          successStatusCode: 201,
          overrideHeaders: (headers) {
            var cloned = {...headers};
            cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
            return {
              ...cloned,
              HttpHeaders.contentTypeHeader: "application/json",
            };
          },
          body: jsonEncode(data),
        ));

    return response != null && response.statusCode == 201;
  }

  Future<List<TMDbMovieModel>> getRecommendations(
    String accountObjectId,
    String accessToken,
    String mediaType,
  ) async {
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/account/$accountObjectId/$mediaType/recommendations",
    );

    var response = await Request.send(requestUrl, options: _requestOptions.copy(
      overrideHeaders: (headers) {
        var cloned = {...headers};
        cloned[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
        return {
          ...cloned,
          HttpHeaders.contentTypeHeader: "application/json",
        };
      },
    ));

    if (response != null &&
        response.statusCode == _requestOptions.successStatusCode) {
      return await compute(
          (msg) => List<TMDbMovieModel>.from(
                json.decode(msg)["results"].map(
                      (e) => TMDbMovieModel.fromJson(e),
                    ),
              ),
          response.data);
    } else {
      return [];
    }
  }
}
