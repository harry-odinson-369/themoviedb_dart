// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themoviedb_dart/src/helper/api.dart';
import 'package:themoviedb_dart/src/helper/request.dart';
import 'package:themoviedb_dart/src/models/access_token_response.dart';
import 'package:themoviedb_dart/src/models/account.dart';
import 'package:themoviedb_dart/src/models/config.dart';
import 'package:themoviedb_dart/src/models/credential.dart';
import 'package:themoviedb_dart/src/models/playlist_detail.dart';
import 'package:themoviedb_dart/src/models/playlists.dart';
import 'package:themoviedb_dart/src/widgets/webview.dart';

TMDbAccessConfig _config = TMDbAccessConfig(
  apiKey: "apiKey",
  accessToken: "accessToken",
);

class TheMovieDb {
  TheMovieDb._singleton();

  static final TheMovieDb _instance = TheMovieDb._singleton();
  static TheMovieDb get instance => _instance;

  static void log(String any) {
    debugPrint("[TheMovieDb Dart] $any");
  }

  static const String _credentialKey = "__cre__";
  static const String _userKey = "__tmdb_user_info__";

  TMDbCredentialModel? _credential;

  final ValueNotifier<TMDbUserAccount?> _userInfo = ValueNotifier(null);
  ValueNotifier<TMDbUserAccount?> get userInfo => _userInfo;

  bool get isSignedIn => _credential != null;

  ///Set a default [apiKey] or [accessToken].
  Future initialize(TMDbAccessConfig config) async {
    _config = config;
    const secure = FlutterSecureStorage();
    final value = await secure.read(key: _credentialKey);
    if (value != null) {
      _credential = TMDbCredentialModel.fromMap(json.decode(value));
      final value1 =
          (await SharedPreferences.getInstance()).getString(_userKey);
      if (value1 != null) {
        _userInfo.value = TMDbUserAccount.fromJson(json.decode(value1));
      }
    }
  }

  Future<bool> signIn(BuildContext context) async {
    assert(_credential == null, "Already signed in! please sign out.");
    try {
      String? tokenV3 = await _getRequestTokenV3();
      if (tokenV3 != null) {
        String redirect =
            "https://www.themoviedb.org/authenticate/$tokenV3?redirect_to=https://www.themoviedb.org/settings/account";
        String? tokenV4 = await _getRequestTokenV4(redirect: redirect);
        if (tokenV4 != null) {
          String url =
              "https://www.themoviedb.org/auth/access?request_token=$tokenV4";
          bool? logged = await requestLoginSheet(context, url);
          if (logged == true) {
            var sessionId = await _getSessionId(tokenV3);
            var tokenResp = await _getAccessToken(tokenV4);
            if (sessionId != null && tokenResp != null) {
              _credential = TMDbCredentialModel(
                  accessToken: tokenResp.accessToken,
                  sessionId: sessionId,
                  accountId: tokenResp.accountId);
              const secure = FlutterSecureStorage();
              await secure
                  .write(
                      key: _credentialKey,
                      value: json.encode(_credential?.toJson()))
                  .catchError((err) {});
              final info = await getUserAccount;
              if (info != null) {
                _userInfo.value = info;
                await (await SharedPreferences.getInstance())
                    .setString(_userKey, json.encode(info.toJson()));
              }
              return true;
            }
          }
        }
      }
      return false;
    } catch (err) {
      log(err.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      var db = await SharedPreferences.getInstance();
      const secure = FlutterSecureStorage();
      await secure.delete(key: _credentialKey).catchError((err) {});
      await db.remove(_userKey).catchError((err) {
        return false;
      });
      _credential = null;
      _userInfo.value = null;
    } catch (err) {
      log(err.toString());
    }
  }

  String _requestUrl(String url) {
    if (_config.apiKey.isNotEmpty) {
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
      newConfig.headers![HttpHeaders.contentTypeHeader] = "application/json";
    }
    return newConfig;
  }

  ///Get a [request_token] from [themoviedb.org] api. once you've got the [request_token], use it to authorize the permission from user by open this page [https://themoviedb.org/auth/access?request_token={request_token}].
  Future<String?> _getRequestTokenV4({String? redirect}) async {
    String requestUrl = _requestUrl("${TMDbApi.base}/auth/request_token");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
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
  Future<String?> _getRequestTokenV3() async {
    String requestUrl = _requestUrl(
        "${TMDbApi.base.replaceAll("4", "3")}/authentication/token/new");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions,
    );
    if (response != null) {
      var map = json.decode(response.data);
      if (map["success"]) return map["request_token"];
    }
    return null;
  }

  Future<String?> _getSessionId(String requestTokenV3) async {
    var requestUrl = _requestUrl(
        "${TMDbApi.base.replaceAll("4", "3")}/authentication/session/new");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
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
  Future<AccessTokenResponse?> _getAccessToken(String requestTokenV4) async {
    var requestUrl = _requestUrl("${TMDbApi.base}/auth/access_token");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
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
  Future<TMDbUserAccount?> get getUserAccount async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var db = await SharedPreferences.getInstance();
    String? data = db.getString(_userKey);
    if (data != null) {
      return TMDbUserAccount.fromJson(json.decode(data));
    } else {
      var requestUrl = _requestUrl(
          "${TMDbApi.base.replaceAll("4", "3")}/account?session_id=${_credential?.sessionId}");
      var response = await Request.send(requestUrl);
      if (response != null) {
        var map = json.decode(response.data);
        var userInfo = TMDbUserAccount.fromJson(map);
        _userInfo.value = userInfo;
        await db
            .setString(_userKey, json.encode(userInfo.toJson()))
            .catchError((err) {
          return false;
        });
        return userInfo;
      }
    }
    return null;
  }

  ///Create a new playlist and return [id] of the list;
  Future<int?> createPlaylist(
      {required String name,
      required String description,
      String? iso6391}) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        successStatusCode: 201,
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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
  Future<bool> deletePlaylist(int listId) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.delete,
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
        },
      ),
    );
    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future<TMDbPlaylistsModel?> getAllPlaylist({int page = 1}) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl(
        "${TMDbApi.base}/account/${_credential?.accountId}/lists?page=$page");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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
    int listId, {
    int page = 1,
  }) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId?page=$page");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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

  Future<bool> isAdded(int mediaId, int listId, String mediaType) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl(
        "${TMDbApi.base}/list/$listId/item_status?media_id=$mediaId&media_type=$mediaType");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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

  Future<bool> addToPlaylist(int listId, List<TMDbMovieModel> items) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId/items");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.post,
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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

  Future<bool> removeItems(int listId, List<TMDbMovieModel> items) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId/items");
    var response = await Request.send(
      requestUrl,
      options: _requestOptions.copy(
        method: RequestMethod.delete,
        overrideHeaders: (headers) {
          headers[HttpHeaders.authorizationHeader] =
              "Bearer ${_credential?.accessToken}";
          return headers;
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
    int listId,
  ) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId/clear");
    var response = await Request.send(requestUrl, options: _requestOptions.copy(
      overrideHeaders: (headers) {
        headers[HttpHeaders.authorizationHeader] =
            "Bearer ${_credential?.accessToken}";
        return headers;
      },
    ));
    return response != null &&
        response.statusCode == _requestOptions.successStatusCode;
  }

  Future updatePlaylist(int listId, Map<String, dynamic> data) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl("${TMDbApi.base}/list/$listId");
    var response = await Request.send(requestUrl,
        options: _requestOptions.copy(
          method: RequestMethod.put,
          successStatusCode: 201,
          overrideHeaders: (headers) {
            headers[HttpHeaders.authorizationHeader] =
                "Bearer ${_credential?.accessToken}";
            return headers;
          },
          body: jsonEncode(data),
        ));
    return response != null && response.statusCode == 201;
  }

  Future<List<TMDbMovieModel>> getRecommendations(
    String mediaType,
  ) async {
    assert(_credential != null, "Require login to themoviedb.org!");
    var requestUrl = _requestUrl(
      "${TMDbApi.base}/account/${_credential?.accountId}/$mediaType/recommendations",
    );
    var response = await Request.send(requestUrl, options: _requestOptions.copy(
      overrideHeaders: (headers) {
        headers[HttpHeaders.authorizationHeader] =
            "Bearer ${_credential?.accessToken}";
        return headers;
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
