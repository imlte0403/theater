import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:theater/data/movie.dart';
import 'package:theater/screens/details.dart';
import 'package:theater/constants/app_constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;
  final String sectionType;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = AppSizes.movieCardWidth,
    this.height = AppSizes.movieCardHeight,
    required this.sectionType,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(
                (255 * AppSizes.shadowOpacity).round(),
              ),
              blurRadius: AppSizes.shadowBlur,
              offset: const Offset(0, AppSizes.shadowOffset),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Stack(
            children: [
              Hero(
                tag: '${sectionType}_poster_${movie.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.amber,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.movie,
                          color: Colors.white54,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: AppSizes.spacing8,
                right: AppSizes.spacing8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spacing8,
                    vertical: AppSizes.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.overlayDark,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.accentColor,
                        size: 14,
                      ),
                      const SizedBox(width: AppSizes.spacing4),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final startRect = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width,
      size.height,
    );

    Navigator.push(
      context,
      PosterExpansionRoute(
        child: EnhancedDetailsScreen(movie: movie, sectionType: sectionType),
        startRect: startRect,
        heroTag: '${sectionType}_poster_${movie.id}',
      ),
    );
  }
}

class HeroBanner extends StatefulWidget {
  final List<Movie> movies;

  const HeroBanner({super.key, required this.movies});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    final bannerMovies = widget.movies.take(5).toList();

    return Container(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: bannerMovies.length,
            itemBuilder: (context, index) {
              final movie = bannerMovies[index];
              return GestureDetector(
                onTap: () => _navigateToDetails(movie),
                child: Stack(
                  children: [
                    Hero(
                      tag: 'movie_backdrop_${movie.title}_${movie.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(movie.backdropUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Color(0x80000000),
                            Color(0xCC000000),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSizes.spacing40,
                      left: 30,
                      right: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: AppTextStyles.titleLarge,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSizes.spacing8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppSizes.spacing4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: AppTextStyles.bodyLarge,
                              ),
                              const SizedBox(width: AppSizes.spacing16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.spacing8,
                                  vertical: AppSizes.spacing4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'NEW',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSizes.spacing20),
                          _buildEnhancedButton(movie),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: AppSizes.spacing20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                bannerMovies.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && widget.movies.isNotEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.movies.take(5).length;
        });
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  Widget _buildEnhancedButton(Movie movie) {
    return ElevatedButton.icon(
      onPressed: () => _navigateToDetails(movie),
      icon: const Icon(Icons.play_arrow, color: Colors.black),
      label: Text(
        UIConstants.watchNowText,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacing24,
          vertical: AppSizes.spacing12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
    );
  }

  void _navigateToDetails(Movie movie) {
    Navigator.push(
      context,
      PosterExpansionRoute(
        child: EnhancedDetailsScreen(movie: movie, sectionType: 'hero'),
        startRect: Rect.zero,
        heroTag: 'movie_backdrop_${movie.title}_${movie.id}',
      ),
    );
  }
}

class EnhancedMovieSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Movie> movies;
  final String sectionType;

  const EnhancedMovieSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.movies,
    required this.sectionType,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleSmall),
            const SizedBox(height: AppSizes.spacing4),
            Text(subtitle, style: AppTextStyles.subtitle),
            const SizedBox(height: AppSizes.spacing16),
            Container(
              padding: const EdgeInsets.all(AppSizes.spacing16),
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.spacing12),
                  Expanded(
                    child: Text(
                      '영화 데이터를 불러오는 중입니다...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSmall),
              const SizedBox(height: AppSizes.spacing4),
              Text(subtitle, style: AppTextStyles.subtitle),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.spacing20),
        SizedBox(
          height: AppSizes.movieSectionHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppSizes.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MovieCard(movie: movie, sectionType: sectionType),
                    const SizedBox(height: AppSizes.spacing12),
                    SizedBox(
                      width: AppSizes.movieCardWidth,
                      child: Text(
                        movie.title,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PosterExpansionRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final Rect startRect;
  final String heroTag;

  PosterExpansionRoute({
    required this.child,
    required this.startRect,
    required this.heroTag,
    super.settings,
  }) : super(
         transitionDuration: const Duration(milliseconds: 600),
         reverseTransitionDuration: const Duration(milliseconds: 400),
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final curvedAnimation = CurvedAnimation(
             parent: animation,
             curve: Curves.easeOutCubic,
             reverseCurve: Curves.easeInCubic,
           );

           return FadeTransition(
             opacity: curvedAnimation,
             child: ScaleTransition(
               scale: Tween<double>(
                 begin: 0.8,
                 end: 1.0,
               ).animate(curvedAnimation),
               child: child,
             ),
           );
         },
       );
}
