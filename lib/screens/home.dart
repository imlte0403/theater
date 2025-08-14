import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:theater/data/movie.dart';
import 'package:theater/components/components.dart';
import 'package:theater/constants/app_constants.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  List<Movie> popularMovies = [];
  List<Movie> nowPlayingMovies = [];
  List<Movie> comingSoonMovies = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.homeAnimationDuration,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      final futures = await Future.wait([
        _fetchMoviesFromEndpoint(ApiConstants.popularEndpoint),
        _fetchMoviesFromEndpoint(ApiConstants.nowPlayingEndpoint),
        _fetchMoviesFromEndpoint(ApiConstants.comingSoonEndpoint),
      ]);

      if (mounted) {
        setState(() {
          popularMovies = futures[0];
          nowPlayingMovies = futures[1];
          comingSoonMovies = futures[2];
          isLoading = false;
        });

        if (popularMovies.isEmpty &&
            nowPlayingMovies.isEmpty &&
            comingSoonMovies.isEmpty) {
          _loadFallbackData();
        } else {
          _ensureAllSectionsHaveData();
        }

        _animationController.forward();
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _loadFallbackData();
      }
    }
  }

  Future<List<Movie>> _fetchMoviesFromEndpoint(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movies;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  void _ensureAllSectionsHaveData() {
    if (popularMovies.isNotEmpty) {
      setState(() {
        if (nowPlayingMovies.isEmpty) {
          nowPlayingMovies = List.from(popularMovies.take(8));
        }
        if (comingSoonMovies.isEmpty) {
          comingSoonMovies = List.from(popularMovies.take(8));
        }
      });
    }
  }

  void _loadFallbackData() {
    if (popularMovies.isNotEmpty) {
      setState(() {
        if (nowPlayingMovies.isEmpty) {
          nowPlayingMovies = List.from(popularMovies.take(8));
        }
        if (comingSoonMovies.isEmpty) {
          comingSoonMovies = List.from(popularMovies.take(8));
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.amber,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading amazing movies...',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _animationController,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroBanner(movies: popularMovies),
                    const SizedBox(height: AppSizes.spacing32),

                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.2,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: EnhancedMovieSection(
                          title: UIConstants.popularMoviesTitle,
                          subtitle: UIConstants.popularMoviesSubtitle,
                          movies: popularMovies.take(10).toList(),
                          sectionType: 'popular',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing32),

                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.6,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: EnhancedMovieSection(
                          title: UIConstants.nowPlayingMoviesTitle,
                          subtitle: UIConstants.nowPlayingMoviesSubtitle,
                          movies: nowPlayingMovies.take(10).toList(),
                          sectionType: 'nowplaying',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing32),

                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(
                                0.8,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: EnhancedMovieSection(
                          title: UIConstants.comingSoonMoviesTitle,
                          subtitle: UIConstants.comingSoonMoviesSubtitle,
                          movies: comingSoonMovies.take(10).toList(),
                          sectionType: 'comingsoon',
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSizes.spacing32),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.search, 'Search', false),
            _buildNavItem(Icons.favorite_outline, 'Favorites', false),
            _buildNavItem(Icons.person_outline, 'Profile', false),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: FadeTransition(
        opacity: _fadeController,
        child: Text(
          UIConstants.appTitle,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      FadeTransition(
        opacity: _fadeController,
        child: IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ),
      FadeTransition(
        opacity: _fadeController,
        child: IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textPrimary,
          ),
          onPressed: () {},
        ),
      ),
      FadeTransition(
        opacity: _fadeController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.spacing8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(ImageConstants.defaultAvatarUrl),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildBody() {
    if (isLoading) {
      return _buildLoadingIndicator();
    }

    return FadeTransition(
      opacity: _fadeController,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (popularMovies.isNotEmpty)
              SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _animationController,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: FadeTransition(
                  opacity: _animationController,
                  child: HeroBanner(movies: popularMovies),
                ),
              ),

            const SizedBox(height: AppSizes.spacing32),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(-0.3, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.2,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: _animationController,
                child: EnhancedMovieSection(
                  title: UIConstants.popularMoviesTitle,
                  subtitle: UIConstants.popularMoviesSubtitle,
                  movies: popularMovies.take(10).toList(),
                  sectionType: 'popular',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing32),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.6,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: _animationController,
                child: EnhancedMovieSection(
                  title: UIConstants.nowPlayingMoviesTitle,
                  subtitle: UIConstants.nowPlayingMoviesSubtitle,
                  movies: nowPlayingMovies.take(10).toList(),
                  sectionType: 'nowplaying',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing32),

            SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(
                        0.8,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
              child: FadeTransition(
                opacity: _animationController,
                child: EnhancedMovieSection(
                  title: UIConstants.comingSoonMoviesTitle,
                  subtitle: UIConstants.comingSoonMoviesSubtitle,
                  movies: comingSoonMovies.take(10).toList(),
                  sectionType: 'comingsoon',
                ),
              ),
            ),

            const SizedBox(height: AppSizes.spacing32),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accentColor.withOpacity(0.3),
                        AppColors.accentColor,
                        AppColors.accentColor.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white, size: 40),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSizes.spacing24),
          FadeTransition(
            opacity: _fadeController,
            child: Text(
              UIConstants.loadingText,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? Colors.amber : Colors.white54, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.amber : Colors.white54,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
