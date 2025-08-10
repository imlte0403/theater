class AppConstants {
  // API 관련
  static const String apiBaseUrl = 'https://movies-api.nomadcoders.workers.dev';
  static const Duration apiTimeout = Duration(seconds: 10);
  static const int maxRetryAttempts = 3;

  // UI 관련
  static const double posterWidth = 150.0;
  static const double posterHeight = 200.0;
  static const double sectionHeight = 280.0;
  static const double sectionSpacing = 16.0;
  static const double posterPadding = 4.0;

  // 이미지 관련
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String defaultPosterUrl = 'assets/images/default_poster.png';

  // 텍스트 관련
  static const double movieTitleFontSize = 16.0;
  static const int movieTitleMaxLines = 2;
}



