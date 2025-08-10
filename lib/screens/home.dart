import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:theater/screens/details.dart';

class Movie {
  final String title;
  final String posterUrl;
  final double voteAverage;
  final String overview;
  final int id; // 영화 고유 ID 추가

  Movie({
    required this.title,
    required this.posterUrl,
    required this.voteAverage,
    required this.overview,
    required this.id,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] as String,
      posterUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      voteAverage: (json['vote_average'] as num).toDouble(),
      overview: json['overview'] as String,
      id: json['id'] as int,
    );
  }
}

class MovieSection extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const MovieSection({super.key, required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        title: movie.title,
                        posterUrl: movie.posterUrl,
                        rating: movie.voteAverage.toStringAsFixed(1),
                        durationAndGenre: '영화 장르와 상영 시간 정보',
                        storyline: movie.overview,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(
                          movie.posterUrl,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 200,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 150,
                        child: Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> popularMovies = [];
  List<Movie> nowInCinemasMovies = [];
  List<Movie> comingSoonMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      // 각 API를 순차적으로 호출하여 안정성 향상
      await fetchPopularMovies();
      await fetchNowInCinemasMovies();
      await fetchComingSoonMovies();
    } catch (e) {
      print('Error fetching movies: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchPopularMovies() async {
    try {
      final uri = Uri.parse(
        'https://movies-api.nomadcoders.workers.dev/popular?_=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

        // 디버깅용 로그 - API 응답 상세 확인
        print('=== POPULAR API RESPONSE ===');
        print('URL: ${uri.toString()}');
        print('Status: ${response.statusCode}');
        print('Movies count: ${movies.length}');
        if (movies.isNotEmpty) {
          print('First movie: ${movies.first.title} (ID: ${movies.first.id})');
          print('Last movie: ${movies.last.title} (ID: ${movies.last.id})');
        }
        print('==========================');

        if (mounted) {
          setState(() {
            popularMovies = movies;
          });
        }
      } else {
        throw Exception(
          'Failed to load popular movies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in fetchPopularMovies: $e');
      if (mounted) {
        setState(() {
          popularMovies = [];
        });
      }
    }
  }

  Future<void> fetchNowInCinemasMovies() async {
    try {
      final uri = Uri.parse(
        'https://movies-api.nomadcoders.workers.dev/now-playing?_=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

        // 디버깅용 로그 - API 응답 상세 확인
        print('=== NOW PLAYING API RESPONSE ===');
        print('URL: ${uri.toString()}');
        print('Status: ${response.statusCode}');
        print('Movies count: ${movies.length}');
        if (movies.isNotEmpty) {
          print('First movie: ${movies.first.title} (ID: ${movies.first.id})');
          print('Last movie: ${movies.last.title} (ID: ${movies.last.id})');
        }
        print('================================');

        if (mounted) {
          setState(() {
            nowInCinemasMovies = movies;
          });
        }
      } else {
        throw Exception(
          'Failed to load now in cinemas movies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in fetchNowInCinemasMovies: $e');
      if (mounted) {
        setState(() {
          nowInCinemasMovies = [];
        });
      }
    }
  }

  Future<void> fetchComingSoonMovies() async {
    try {
      final uri = Uri.parse(
        'https://movies-api.nomadcoders.workers.dev/coming-soon?_=${DateTime.now().millisecondsSinceEpoch}',
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<Movie> movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

        // 디버깅용 로그
        print('Coming Soon: ${movies.length} movies loaded');
        print(
          'First coming soon movie: ${movies.isNotEmpty ? movies.first.title : 'None'}',
        );

        if (mounted) {
          setState(() {
            comingSoonMovies = movies;
          });
        }
      } else {
        throw Exception(
          'Failed to load coming soon movies: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in fetchComingSoonMovies: $e');
      if (mounted) {
        setState(() {
          comingSoonMovies = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  if (popularMovies.isNotEmpty)
                    MovieSection(
                      title: 'Popular Movies',
                      movies: popularMovies,
                    ),
                  const SizedBox(height: 16),
                  if (nowInCinemasMovies.isNotEmpty)
                    MovieSection(
                      title: 'Now in Cinemas',
                      movies: nowInCinemasMovies,
                    ),
                  const SizedBox(height: 16),
                  if (comingSoonMovies.isNotEmpty)
                    MovieSection(
                      title: 'Coming Soon',
                      movies: comingSoonMovies,
                    ),
                ],
              ),
            ),
    );
  }
}
