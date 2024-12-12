class AccessTokenResponse {
  String accessToken;
  String accountId;

  AccessTokenResponse({
    required this.accessToken,
    required this.accountId,
  });

  factory AccessTokenResponse.fromMap(Map<String, dynamic> map) =>
      AccessTokenResponse(
        accessToken: map["access_token"] ?? "",
        accountId: map["account_id"] ?? "",
      );

  Map<String, dynamic> toMap() => {
        "access_token": accessToken,
        "account_id": accountId,
      };
}
