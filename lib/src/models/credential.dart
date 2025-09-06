class TMDbCredentialModel {
  String accessToken, sessionId, accountId;

  TMDbCredentialModel({
    required this.accessToken,
    required this.sessionId,
    required this.accountId,
  });

  factory TMDbCredentialModel.fromMap(Map<String, dynamic> map) =>
      TMDbCredentialModel(
        accessToken: map["access_token"] ?? "",
        sessionId: map["session_id"] ?? "",
        accountId: map["account_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "session_id": sessionId,
        "account_id": accountId,
      };
}
