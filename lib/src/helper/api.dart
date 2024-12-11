import 'package:themoviedb_dart/src/helper/url.dart';

class TMDbApi {
  static String get base => "https://api.themoviedb.org/3";
  static String get baseV4 => "https://api.themoviedb.org/4";

  static String createEndpoint(List<String> path) => UrlHelper.join([base, ...path]);

}