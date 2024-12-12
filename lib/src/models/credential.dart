import 'package:themoviedb_dart/src/models/account.dart';

class TMDbCredentialModel {
  String accessToken, sessionId, accountId;
  TMDbUserAccount user;

  TMDbCredentialModel({
    required this.accessToken,
    required this.sessionId,
    required this.accountId,
    required this.user,
  });

  factory TMDbCredentialModel.fromMap(Map<String, dynamic> map) =>
      TMDbCredentialModel(
        accessToken: map["access_token"] ?? "",
        sessionId: map["session_id"] ?? "",
        accountId: map["account_id"] ?? "",
        user: TMDbUserAccount.fromJson(map["user_info"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "session_id": sessionId,
        "account_id": accountId,
        "user_info": user.toJson(),
      };
}
