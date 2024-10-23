class TMDbUserAccount {
  Avatar avatar;
  int id;
  String iso6391;
  String iso31661;
  String name;
  bool includeAdult;
  String username;

  TMDbUserAccount({
    required this.avatar,
    required this.id,
    required this.iso6391,
    required this.iso31661,
    required this.name,
    required this.includeAdult,
    required this.username,
  });

  factory TMDbUserAccount.fromJson(Map<String, dynamic> json) => TMDbUserAccount(
    avatar: Avatar.fromJson(json["avatar"] ?? {}),
    id: json["id"] ?? 0,
    iso6391: json["iso_639_1"] ?? "",
    iso31661: json["iso_3166_1"] ?? "",
    name: json["name"] ?? "",
    includeAdult: json["include_adult"] ?? false,
    username: json["username"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "avatar": avatar.toJson(),
    "id": id,
    "iso_639_1": iso6391,
    "iso_3166_1": iso31661,
    "name": name,
    "include_adult": includeAdult,
    "username": username,
  };
}

class Avatar {
  Gravatar gravatar;
  TMDb tmdb;

  Avatar({
    required this.gravatar,
    required this.tmdb,
  });

  factory Avatar.fromJson(Map<String, dynamic> json) => Avatar(
    gravatar: Gravatar.fromJson(json["gravatar"] ?? {}),
    tmdb: TMDb.fromJson(json["tmdb"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "gravatar": gravatar.toJson(),
    "tmdb": tmdb.toJson(),
  };
}

class Gravatar {
  String hash;

  Gravatar({
    required this.hash,
  });

  factory Gravatar.fromJson(Map<String, dynamic> json) => Gravatar(
    hash: json["hash"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "hash": hash,
  };
}

class TMDb {
  String avatarPath;

  TMDb({
    required this.avatarPath,
  });

  factory TMDb.fromJson(Map<String, dynamic> json) => TMDb(
    avatarPath: json["avatar_path"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "avatar_path": avatarPath,
  };
}
