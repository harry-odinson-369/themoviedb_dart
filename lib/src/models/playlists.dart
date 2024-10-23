class TMDbPlaylists {
  int page;
  List<Result> results;
  int totalPages;
  int totalResults;

  TMDbPlaylists({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDbPlaylists.fromJson(Map<String, dynamic> json) => TMDbPlaylists(
    page: json["page"] ?? 1,
    results: List<Result>.from((json["results"] ?? []).map((x) => Result.fromJson(x))),
    totalPages: json["total_pages"] ?? 0,
    totalResults: json["total_results"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class Result {
  String description;
  int favoriteCount;
  int id;
  int itemCount;
  String iso6391;
  String listType;
  String name;
  String posterPath;

  Result({
    required this.description,
    required this.favoriteCount,
    required this.id,
    required this.itemCount,
    required this.iso6391,
    required this.listType,
    required this.name,
    required this.posterPath,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    description: json["description"] ?? "",
    favoriteCount: json["favorite_count"] ?? 0,
    id: json["id"] ?? 0,
    itemCount: json["item_count"] ?? 0,
    iso6391: json["iso_639_1"] ?? "",
    listType: json["list_type"] ?? "",
    name: json["name"] ?? "",
    posterPath: json["poster_path"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "description": description,
    "favorite_count": favoriteCount,
    "id": id,
    "item_count": itemCount,
    "iso_639_1": iso6391,
    "list_type": listType,
    "name": name,
    "poster_path": posterPath,
  };
}
