import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:theater/screens/details.dart';

// 영화 정보를 저장하는 모델 클래스
class Movie {
  final String title;
  final String posterUrl;
  final double voteAverage;
  final String overview;

  Movie({
    required this.title,
    required this.posterUrl,
    required this.voteAverage,
    required this.overview,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] as String,
      posterUrl: 'https://image.tmdb.org/t/p/w500${json['poster_path']}',
      voteAverage: (json['vote_average'] as num).toDouble(),
      overview: json['overview'] as String,
    );
  }
}

// 영화 목록을 표시하는 커스텀 위젯
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
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length * 3, // 3번 반복하여 무한 스크롤 효과
            itemBuilder: (context, index) {
              final movieIndex = index % movies.length; // 실제 영화 인덱스
              final movie = movies[movieIndex];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        title: movie.title,
                        posterUrl: movie.posterUrl,
                        rating: movie.voteAverage.toStringAsFixed(
                          1,
                        ), // 평점 소수점 첫째 자리까지
                        durationAndGenre:
                            '영화 장르와 상영 시간 정보', // API에 포함되지 않아 임시로 추가
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

// 홈 스크린 위젯
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Movie> popularMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPopularMovies();
  }

  // API를 호출하여 인기 영화 데이터를 가져오는 함수
  Future<void> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('https://movies-api.nomadcoders.workers.dev/popular'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        popularMovies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load popular movies');
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
              backgroundImage: NetworkImage(
                'https://example.com/your_profile_image.jpg',
              ),
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
                  MovieSection(title: 'Popular Movies', movies: popularMovies),
                  const SizedBox(height: 24),
                  // 다른 섹션들은 원하는 데이터를 추가하여 구현 가능
                ],
              ),
            ),
    );
  }
}
