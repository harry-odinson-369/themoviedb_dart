class TMDbPlaylistsModel {
  int page;
  List<TMDbPlaylistModel> results;
  int totalPages;
  int totalResults;

  TMDbPlaylistsModel({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDbPlaylistsModel.fromMap(Map<String, dynamic> json) => TMDbPlaylistsModel(
    page: json["page"] ?? 0,
    results: List<TMDbPlaylistModel>.from((json["results"] ?? []).map((x) => TMDbPlaylistModel.fromMap(x))),
    totalPages: json["total_pages"] ?? 0,
    totalResults: json["total_results"] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "page": page,
    "results": List<dynamic>.from(results.map((x) => x.toMap())),
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class TMDbPlaylistModel {
  String accountObjectId;
  int adult;
  double averageRating;
  String backdropPath;
  String createdAt;
  String description;
  int featured;
  int id;
  String iso31661;
  String iso6391;
  String name;
  int numberOfItems;
  String posterPath;
  int public;
  int revenue;
  String runtime;
  int sortBy;
  String updatedAt;

  TMDbPlaylistModel({
    required this.accountObjectId,
    required this.adult,
    required this.averageRating,
    required this.backdropPath,
    required this.createdAt,
    required this.description,
    required this.featured,
    required this.id,
    required this.iso31661,
    required this.iso6391,
    required this.name,
    required this.numberOfItems,
    required this.posterPath,
    required this.public,
    required this.revenue,
    required this.runtime,
    required this.sortBy,
    required this.updatedAt,
  });

  factory TMDbPlaylistModel.fromMap(Map<String, dynamic> json) => TMDbPlaylistModel(
    accountObjectId: json["account_object_id"] ?? "",
    adult: json["adult"] ?? 0,
    averageRating: (json["average_rating"] ?? 0.0).toDouble(),
    backdropPath: json["backdrop_path"] ?? "",
    createdAt: json["created_at"] ?? "",
    description: json["description"] ?? "",
    featured: json["featured"] ?? 0,
    id: json["id"] ?? 0,
    iso31661: json["iso_3166_1"] ?? "",
    iso6391: json["iso_639_1"] ?? "",
    name: json["name"] ?? "",
    numberOfItems: json["number_of_items"] ?? 0,
    posterPath: json["poster_path"] ?? "",
    public: json["public"] ?? 0,
    revenue: json["revenue"] ?? 0,
    runtime: json["runtime"] ?? "",
    sortBy: json["sort_by"] ?? 0,
    updatedAt: json["updated_at"] ?? "",
  );

  Map<String, dynamic> toMap() => {
    "account_object_id": accountObjectId,
    "adult": adult,
    "average_rating": averageRating,
    "backdrop_path": backdropPath,
    "created_at": createdAt,
    "description": description,
    "featured": featured,
    "id": id,
    "iso_3166_1": iso31661,
    "iso_639_1": iso6391,
    "name": name,
    "number_of_items": numberOfItems,
    "poster_path": posterPath,
    "public": public,
    "revenue": revenue,
    "runtime": runtime,
    "sort_by": sortBy,
    "updated_at": updatedAt,
  };
}