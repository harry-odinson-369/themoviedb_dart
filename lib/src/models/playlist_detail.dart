import 'package:themoviedb_dart/src/extensions/extensions.dart';

class TMDbPlaylistDetailModel {
  double averageRating;
  String backdropPath;
  List<TMDbMovieModel> results;
  CreatedBy createdBy;
  String description;
  int id;
  String iso31661;
  String iso6391;
  int itemCount;
  String name;
  int page;
  String posterPath;
  bool public;
  int revenue;
  int runtime;
  String sortBy;
  int totalPages;
  int totalResults;

  TMDbPlaylistDetailModel({
    required this.averageRating,
    required this.backdropPath,
    required this.results,
    required this.createdBy,
    required this.description,
    required this.id,
    required this.iso31661,
    required this.iso6391,
    required this.itemCount,
    required this.name,
    required this.page,
    required this.posterPath,
    required this.public,
    required this.revenue,
    required this.runtime,
    required this.sortBy,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDbPlaylistDetailModel.fromMap(Map<String, dynamic> json) => TMDbPlaylistDetailModel(
    averageRating: (json["average_rating"] ?? 0.0).toDouble(),
    backdropPath: json["backdrop_path"] ?? "",
    results: List<TMDbMovieModel>.from((json["results"] ?? []).map((x) => TMDbMovieModel.fromJson(x))),
    createdBy: CreatedBy.fromMap(json["created_by"] ?? {}),
    description: json["description"] ?? "",
    id: json["id"] ?? 0,
    iso31661: json["iso_3166_1"] ?? "",
    iso6391: json["iso_639_1"] ?? "",
    itemCount: json["item_count"] ?? 0,
    name: json["name"] ?? "",
    page: json["page"] ?? 1,
    posterPath: json["poster_path"] ?? "",
    public: json["public"] ?? true,
    revenue: json["revenue"] ?? 0,
    runtime: json["runtime"] ?? 0,
    sortBy: json["sort_by"] ?? "",
    totalPages: json["total_pages"] ?? 0,
    totalResults: json["total_results"] ?? 0,
  );

  Map<String, dynamic> toMap() => {
    "average_rating": averageRating,
    "backdrop_path": backdropPath,
    "results": List<dynamic>.from(results.map((x) => x.toJson())),
    "created_by": createdBy.toMap(),
    "description": description,
    "id": id,
    "iso_3166_1": iso31661,
    "iso_639_1": iso6391,
    "item_count": itemCount,
    "name": name,
    "page": page,
    "poster_path": posterPath,
    "public": public,
    "revenue": revenue,
    "runtime": runtime,
    "sort_by": sortBy,
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class CreatedBy {
  String avatarPath;
  String gravatarHash;
  String id;
  String name;
  String username;

  CreatedBy({
    required this.avatarPath,
    required this.gravatarHash,
    required this.id,
    required this.name,
    required this.username,
  });

  factory CreatedBy.fromMap(Map<String, dynamic> json) => CreatedBy(
    avatarPath: json["avatar_path"] ?? "",
    gravatarHash: json["gravatar_hash"] ?? "",
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    username: json["username"] ?? "",
  );

  Map<String, dynamic> toMap() => {
    "avatar_path": avatarPath,
    "gravatar_hash": gravatarHash,
    "id": id,
    "name": name,
    "username": username,
  };
}

class TMDbMovieModel {
  String backdropPath;
  int id;
  String originalName;
  String overview;
  String posterPath;
  String mediaType;
  bool adult;
  String name;
  String title;
  String originalLanguage;
  List<int> genreIds;
  double popularity;
  String firstAirDate;
  String releasedDate;
  double voteAverage;
  int voteCount;
  List<String> originCountry;
  String imdbId;
  int runtime;

  TMDbMovieModel({
    required this.backdropPath,
    required this.id,
    required this.originalName,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.adult,
    required this.name,
    required this.title,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    required this.firstAirDate,
    required this.releasedDate,
    required this.voteAverage,
    required this.voteCount,
    required this.originCountry,
    required this.imdbId,
    required this.runtime,
  });

  String get markedKey => "$type-$id";

  String get type => name.isNotEmpty ? "tv" : "movie";

  String get actualName => type == "tv" ? name : title;

  String get actualYear => firstAirDate.isNotEmpty ? firstAirDate.split("-").firstWhereOrNull((e) => e.length == 4) ?? "" : releasedDate.split("-").firstWhereOrNull((e) => e.length == 4) ?? "";

  String get openingId => "$type-$id";

  factory TMDbMovieModel.fromJson(Map<String, dynamic> json) => TMDbMovieModel(
    backdropPath: json["backdrop_path"] ?? "",
    id: json["id"] ?? 0,
    originalName: json["original_name"] ?? "",
    overview: json["overview"] ?? "",
    posterPath: json["poster_path"] ?? "",
    mediaType: json["media_type"] ?? "",
    adult: json["adult"] ?? false,
    name: json["name"] ?? "",
    title: json["title"] ?? "",
    originalLanguage: json["original_language"] ?? "",
    genreIds: List<int>.from((json["genre_ids"] ?? []).map((x) => x)),
    popularity: double.parse("${json["popularity"] ?? 0}"),
    firstAirDate: json["first_air_date"] ?? "",
    releasedDate: json["release_date"] ?? "",
    voteAverage: double.parse("${json["vote_average"] ?? 0}"),
    voteCount: json["vote_count"] ?? 0,
    originCountry: List<String>.from((json["origin_country"] ?? []).map((x) => x)),
    imdbId: json["imdb_id"] ?? "",
    runtime: json["runtime"] ?? 0,
  );

  Map<String, dynamic> toJson({String? imdb, int? run}) => {
    "backdrop_path": backdropPath,
    "id": id,
    "original_name": originalName,
    "overview": overview,
    "poster_path": posterPath,
    "media_type": mediaType,
    "adult": adult,
    "name": name,
    "title": title,
    "original_language": originalLanguage,
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "popularity": popularity,
    "first_air_date": firstAirDate,
    "release_date": releasedDate,
    "vote_average": voteAverage,
    "vote_count": voteCount,
    "origin_country": List<dynamic>.from(originCountry.map((x) => x)),
    "imdb_id": imdb ?? imdbId,
    "runtime": run ?? runtime,
  };
}