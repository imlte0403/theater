import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

const Map<int, String> genreIdToName = {
  28: 'Action',
  12: 'Adventure',
  16: 'Animation',
  35: 'Comedy',
  80: 'Crime',
  99: 'Documentary',
  18: 'Drama',
  10751: 'Family',
  14: 'Fantasy',
  36: 'History',
  27: 'Horror',
  10402: 'Music',
  9648: 'Mystery',
  10749: 'Romance',
  878: 'Science Fiction',
  10770: 'TV Movie',
  53: 'Thriller',
  10752: 'War',
  37: 'Western',
};

// 영화 정보를 저장하는 모델 클래스
class Movie {
  final int? id;
  final String title;
  final String posterUrl;
  final String backdropUrl;
  final double voteAverage;
  final String overview;
  final String releaseDate;
  final List<int> genreIds;

  Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    required this.backdropUrl,
    required this.voteAverage,
    required this.overview,
    required this.releaseDate,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String,
      posterUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      backdropUrl: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w1280${json['backdrop_path']}'
          : 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      voteAverage: (json['vote_average'] as num).toDouble(),
      overview: json['overview'] as String,
      releaseDate: json['release_date'] as String? ?? '',
      genreIds: List<int>.from(json['genre_ids'] as List? ?? []),
    );
  }
}

// ✨ 새로 추가: 커스텀 페이지 라우트 트랜지션
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

// ✨ 새로 추가: 영화 카드 위젯
class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 160,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Hero 위젯으로 포스터 이미지
              Hero(
                tag: 'movie_poster_${movie.id}',
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
              // 평점 배지
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.7).round()),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 2),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
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
    // 현재 포스터의 위치 정보를 가져옴
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
        child: EnhancedDetailsScreen(movie: movie),
        startRect: startRect,
        heroTag: 'movie_poster_${movie.id}',
      ),
    );
  }
}

// 히어로 배너 위젯 (기존 코드 유지)
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

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final bannerMovies = widget.movies.take(5).toList();

    return SizedBox(
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
                    // 배경 이미지
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
                    // 그라데이션 오버레이
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
                    // 영화 정보
                    Positioned(
                      bottom: 60,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.voteAverage.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
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
                          const SizedBox(height: 16),
                          // ✨ 글래스모피즘 Watch Now 버튼
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withOpacity(0.08),
                                      Colors.white.withOpacity(0.02),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                    width: 1.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _navigateToDetails(movie),
                                    borderRadius: BorderRadius.circular(25),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.play_arrow,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Watch Now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // 페이지 인디케이터
          Positioned(
            bottom: 20,
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
                        : Colors.white.withAlpha((255 * 0.4).round()),
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

  void _navigateToDetails(Movie movie) {
    // 현재 포스터의 위치 정보를 가져옴
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
        child: EnhancedDetailsScreen(movie: movie),
        startRect: startRect,
        heroTag: 'movie_poster_${movie.id}',
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// ✨ 수정된 영화 섹션 위젯 (MovieCard 사용)
class EnhancedMovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final String? subtitle;

  const EnhancedMovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    // ✨ MovieCard 사용 (포스터 확장 애니메이션 적용)
                    MovieCard(movie: movie),
                    const SizedBox(height: 10),

                    // 영화 제목과 연도
                    SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (movie.releaseDate.isNotEmpty)
                            Text(
                              movie.releaseDate.split('-')[0],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                              ),
                            ),
                        ],
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

// 개선된 홈 스크린 (기존 코드 유지)
class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      // 인기 영화 가져오기
      final popularResponse = await http.get(
        Uri.parse('https://movies-api.nomadcoders.workers.dev/popular'),
      );

      if (popularResponse.statusCode == 200) {
        final popularData = json.decode(popularResponse.body);
        popularMovies = (popularData['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      }

      // 높은 평점 영화는 인기 영화를 평점순으로 정렬해서 사용
      topRatedMovies = [...popularMovies]
        ..sort((a, b) => b.voteAverage.compareTo(a.voteAverage));

      setState(() {
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'CinemaHub',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // 검색 기능 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
              ),
            ),
          ),
        ],
      ),
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
                    // 히어로 배너
                    HeroBanner(movies: popularMovies),
                    const SizedBox(height: 32),

                    // 인기 영화 섹션
                    EnhancedMovieSection(
                      title: '인기 영화',
                      subtitle: '8월 둘째주 가장 인기 있는 영화',
                      movies: popularMovies.take(10).toList(),
                    ),
                    const SizedBox(height: 32),

                    // 높은 평점 영화 섹션
                    EnhancedMovieSection(
                      title: '높은 평점 영화',
                      subtitle: '관객들에게 가장 사랑받는 영화',
                      movies: topRatedMovies.take(10).toList(),
                    ),
                    const SizedBox(height: 32),

                    // 추천 영화 섹션 (인기 영화 순서를 섞어서 표시)
                    EnhancedMovieSection(
                      title: '추천 영화',
                      subtitle: '시청 기록을 기반으로 추천',
                      movies: (popularMovies.toList()..shuffle())
                          .take(10)
                          .toList(),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

      // 하단 네비게이션 바
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// ✨ 완전히 새로운 상세 화면 (포스터 확장 애니메이션 적용)
class EnhancedDetailsScreen extends StatefulWidget {
  final Movie movie;

  const EnhancedDetailsScreen({super.key, required this.movie});

  @override
  State<EnhancedDetailsScreen> createState() => _EnhancedDetailsScreenState();
}

class _EnhancedDetailsScreenState extends State<EnhancedDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // 페이드 인 애니메이션
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 슬라이드 애니메이션
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    // 애니메이션 시작 (약간의 지연 후)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 메인 콘텐츠
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 포스터와 배경 이미지 섹션
                _buildPosterSection(),

                // 영화 정보 섹션
                _buildMovieInfoSection(),
              ],
            ),
          ),

          // 뒤로가기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.5).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
        ],
      ),

      // 하단 버튼
      bottomNavigationBar: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 버튼 클릭 애니메이션
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('티켓 구매 기능 준비중입니다!'),
                      backgroundColor: Colors.amber,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: const Text(
                  '티켓 예매하기',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPosterSection() {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          // 배경 이미지 (블러 처리)
          Positioned.fill(
            child: Hero(
              tag: 'movie_backdrop_${widget.movie.id}',
              child: Image.network(widget.movie.backdropUrl, fit: BoxFit.cover),
            ),
          ),

          // 그라데이션 오버레이
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha((255 * 0.3).round()),
                    Colors.black.withAlpha((255 * 0.8).round()),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // 포스터 이미지 (확장 애니메이션)
          Positioned(
            bottom: 60,
            left: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 포스터
                Hero(
                  tag: 'movie_poster_${widget.movie.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: 120,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((255 * 0.5).round()),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.movie.posterUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 영화 기본 정보
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 180,
                          child: Text(
                            widget.movie.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        if (widget.movie.releaseDate.isNotEmpty)
                          Text(
                            widget.movie.releaseDate,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                      ],
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

  Widget _buildMovieInfoSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '줄거리',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              Text(
                widget.movie.overview,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 24),

              // 추가 정보들
              if (widget.movie.genreIds.isNotEmpty) ...[
                const Text(
                  '장르',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.movie.genreIds
                      .map((id) => genreIdToName[id])
                      .where((name) => name != null)
                      .map(
                        (name) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withAlpha((255 * 0.2).round()),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            name!,
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const SizedBox(height: 100), // 하단 버튼 공간 확보
            ],
          ),
        ),
      ),
    );
  }
}
