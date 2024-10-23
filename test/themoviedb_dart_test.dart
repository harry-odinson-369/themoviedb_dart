import 'dart:developer';

import 'package:themoviedb_dart/themoviedb_dart.dart';

Future<void> main() async {
  TheMovieDb.config(
    TMDbAccessConfig(
      apiKey: "7ec5fa8ca102e3ace8942a5f662bb94b",
      accessToken: "",
    ),
  );

  var response = await TheMovieDb.getRequestToken();

  log(response.toString());
}
