import 'package:flutter/material.dart';

class AppColors {
  static const primaryBackground = Color(0xFF0D0D0D);
  static const secondaryBackground = Color(0xFF1A1A1A);
  static const accentColor = Colors.amber;
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xB3FFFFFF);
  static const textTertiary = Color(0x80FFFFFF);
  static const overlayDark = Color(0x80000000);
  static const overlayMedium = Color(0x40000000);
  static const overlayLight = Color(0x20000000);
  static const defaultPosterColor = Color(0xFF424242);
  static const defaultIconColor = Color(0x80FFFFFF);
}

class AppSizes {
  static const spacing4 = 4.0;
  static const spacing8 = 8.0;
  static const spacing12 = 12.0;
  static const spacing16 = 16.0;
  static const spacing20 = 20.0;
  static const spacing24 = 24.0;
  static const spacing32 = 32.0;
  static const spacing40 = 40.0;

  static const movieCardWidth = 160.0;
  static const movieCardHeight = 220.0;
  static const movieSectionHeight = 280.0;
  static const heroBannerHeight = 500.0;
  static const detailsAppBarHeight = 400.0;

  static const radiusSmall = 12.0;
  static const radiusMedium = 16.0;
  static const radiusLarge = 20.0;
  static const radiusExtraLarge = 25.0;

  static const shadowBlur = 8.0;
  static const shadowOffset = 4.0;
  static const shadowOpacity = 0.3;
}

class AppTextStyles {
  static const titleLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const titleMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const titleSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const bodyLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
}

class AppAnimations {
  static const pageTransitionDuration = Duration(milliseconds: 600);
  static const pageReverseTransitionDuration = Duration(milliseconds: 400);
  static const homeAnimationDuration = Duration(milliseconds: 1500);
  static const scaleAnimationBegin = 0.8;
  static const scaleAnimationEnd = 1.0;
}

class ApiConstants {
  static const baseUrl = 'https://movies-api.nomadcoders.workers.dev';
  static const popularEndpoint = 'popular';
  static const nowPlayingEndpoint = 'now-playing';
  static const comingSoonEndpoint = 'coming-soon';
  static const topRatedEndpoint = 'top_rated';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/';
  static const posterSize = 'w500';
  static const backdropSize = 'w1280';
}

class UIConstants {
  static const appTitle = 'CinemaHub';
  static const loadingText = 'Loading amazing movies...';
  static const watchNowText = 'Watch Now';
  static const overviewTitle = '줄거리';
  static const genresTitle = '장르';
  static const unknownGenre = 'Unknown';

  static const popularMoviesTitle = '인기 영화';
  static const popularMoviesSubtitle = '8월 둘째주 가장 인기 있는 영화';
  static const nowPlayingMoviesTitle = '현재 상영';
  static const nowPlayingMoviesSubtitle = '지금 상영 중인 영화들';
  static const comingSoonMoviesTitle = '개봉 예정';
  static const comingSoonMoviesSubtitle = '곧 개봉할 영화들';
}

class ImageConstants {
  static const defaultAvatarUrl =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face';
  static const defaultPosterColor = Color(0xFF424242);
  static const defaultIconColor = Color(0x80FFFFFF);
  static const defaultIconSize = 40.0;
}
