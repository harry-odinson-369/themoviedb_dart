import 'package:themoviedb_dart/src/models/account.dart';

class TMDbCredentialModel {
  String sessionId;
  TMDbUserAccount user;

  TMDbCredentialModel({
    required this.sessionId,
    required this.user,
  });

  factory TMDbCredentialModel.fromMap(Map<String, dynamic> map) =>
      TMDbCredentialModel(
        sessionId: map["session_id"],
        user: TMDbUserAccount.fromJson(map["user_info"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "session_id": sessionId,
        "user_info": user.toJson(),
      };
}
