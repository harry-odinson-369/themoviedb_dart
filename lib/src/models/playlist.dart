class TMDbPlaylist {
  String createdBy;
  String description;
  int favoriteCount;
  int id;
  String iso6391;
  int itemCount;
  List<TMDbMovie> items;
  String name;
  int page;
  String posterPath;
  int totalPages;
  int totalResults;

  TMDbPlaylist({
    required this.createdBy,
    required this.description,
    required this.favoriteCount,
    required this.id,
    required this.iso6391,
    required this.itemCount,
    required this.items,
    required this.name,
    required this.page,
    required this.posterPath,
    required this.totalPages,
    required this.totalResults,
  });

  factory TMDbPlaylist.fromJson(Map<String, dynamic> json) => TMDbPlaylist(
    createdBy: json["created_by"] ?? "",
    description: json["description"] ?? "",
    favoriteCount: json["favorite_count"] ?? 0,
    id: json["id"] ?? 0,
    iso6391: json["iso_639_1"] ?? "",
    itemCount: json["item_count"] ?? 0,
    items: List<TMDbMovie>.from((json["items"] ?? []).map((x) => TMDbMovie.fromJson(x))),
    name: json["name"] ?? "",
    page: json["page"] ?? 0,
    posterPath: json["poster_path"] ?? "",
    totalPages: json["total_pages"] ?? 0,
    totalResults: json["total_results"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "created_by": createdBy,
    "description": description,
    "favorite_count": favoriteCount,
    "id": id,
    "iso_639_1": iso6391,
    "item_count": itemCount,
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "name": name,
    "page": page,
    "poster_path": posterPath,
    "total_pages": totalPages,
    "total_results": totalResults,
  };
}

class TMDbMovie {
  String backdropPath;
  int id;
  String title;
  String originalTitle;
  String overview;
  String posterPath;
  String mediaType;
  bool adult;
  String originalLanguage;
  List<int> genreIds;
  double popularity;
  String releaseDate;
  bool video;
  double voteAverage;
  int voteCount;
  String name;
  String originalName;
  String firstAirDate;
  List<String> originCountry;

  TMDbMovie({
    required this.backdropPath,
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.posterPath,
    required this.mediaType,
    required this.adult,
    required this.originalLanguage,
    required this.genreIds,
    required this.popularity,
    required this.releaseDate,
    required this.video,
    required this.voteAverage,
    required this.voteCount,
    required this.name,
    required this.originalName,
    required this.firstAirDate,
    required this.originCountry,
  });

  factory TMDbMovie.fromJson(Map<String, dynamic> json) => TMDbMovie(
    backdropPath: json["backdrop_path"] ?? "",
    id: json["id"] ?? 0,
    title: json["title"] ?? "",
    originalTitle: json["original_title"] ?? "",
    overview: json["overview"] ?? "",
    posterPath: json["poster_path"] ?? "",
    mediaType: json["media_type"] ?? "",
    adult: json["adult"] ?? false,
    originalLanguage: json["original_language"],
    genreIds: List<int>.from((json["genre_ids"] ?? []).map((x) => x)),
    popularity: (json["popularity"] ?? 0.0),
    releaseDate: json["release_date"] ?? "",
    video: json["video"] ?? false,
    voteAverage: (json["vote_average"] ?? 0.0),
    voteCount: json["vote_count"] ?? 0,
    name: json["name"] ?? "",
    originalName: json["original_name"] ?? "",
    firstAirDate: json["first_air_date"] ?? "",
    originCountry: List<String>.from((json["origin_country"] ?? []).map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "backdrop_path": backdropPath,
    "id": id,
    "title": title,
    "original_title": originalTitle,
    "overview": overview,
    "poster_path": posterPath,
    "media_type": mediaType,
    "adult": adult,
    "original_language": originalLanguage,
    "genre_ids": List<dynamic>.from(genreIds.map((x) => x)),
    "popularity": popularity,
    "release_date": releaseDate,
    "video": video,
    "vote_average": voteAverage,
    "vote_count": voteCount,
    "name": name,
    "original_name": originalName,
    "first_air_date": firstAirDate,
    "origin_country": List<dynamic>.from(originCountry.map((x) => x)),
  };
}
