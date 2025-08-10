import 'package:flutter/material.dart';
import 'package:theater/screens/details.dart';

// 영화 목록을 표시하는 커스텀 위젯
class MovieSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> movies;
  final bool isLargePoster;

  const MovieSection({
    super.key,
    required this.title,
    required this.movies,
    this.isLargePoster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: isLargePoster ? 250 : 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                // GestureDetector 위젯으로 감싸서 탭 이벤트 감지
                onTap: () {
                  // DetailsScreen으로 이동하는 라우팅 코드
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsScreen(
                        title: movie['title']!,
                        posterUrl: movie['posterUrl']!,
                        rating: movie['rating']!,
                        durationAndGenre: movie['durationAndGenre']!,
                        storyline: movie['storyline']!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image.network(
                      movie['posterUrl']!,
                      fit: BoxFit.cover,
                      width: isLargePoster ? 300 : 120,
                    ),
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
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            MovieSection(
              title: 'Popular Movies',
              isLargePoster: true,
              movies: [
                {
                  'title': 'Avengers: Age of Ultron',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLj3JcqqN3LHiuO9.jpg',
                  'rating': '4.5',
                  'durationAndGenre': '2h 21min | Action, Sci-Fi',
                  'storyline':
                      'When Tony Stark and Bruce Banner try to jump-start a dormant peacekeeping program called Ultron, things go horribly wrong and it\'s up to Earth\'s Mightiest Heroes to stop the villainous Ultron from enacting his terrible plans.',
                },
              ],
            ),
            const SizedBox(height: 24),
            MovieSection(
              title: 'Now in Cinemas',
              movies: [
                {
                  'title': 'Spider-Man: Into the Spider-Verse',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/aH0fE59c5d1qF5n5z8s6F6e6d1e.jpg',
                  'rating': '4.8',
                  'durationAndGenre': '1h 57min | Animation, Action, Adventure',
                  'storyline':
                      'Bitten by a radioactive spider in the subway, Brooklyn teenager Miles Morales suddenly develops mysterious powers that transform him into the one and only Spider-Man.',
                },
                {
                  'title': 'First Man',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/aQhD4Xh8t2wN0x9J5w7r9V5j9mG.jpg',
                  'rating': '4.2',
                  'durationAndGenre': '2h 21min | Biography, Drama',
                  'storyline':
                      'A look at the life of the astronaut, Neil Armstrong, and the legendary space mission that led him to become the first man to walk on the Moon on July 20, 1969.',
                },
                {
                  'title': 'Bohemian Rhapsody',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/iL8f65Xw8C3GgBvM3l24z6E6e6f.jpg',
                  'rating': '4.7',
                  'durationAndGenre': '2h 14min | Biography, Drama, Music',
                  'storyline':
                      'Bohemian Rhapsody is a foot-stomping celebration of Queen, their music and their extraordinary lead singer Freddie Mercury.',
                },
              ],
            ),
            const SizedBox(height: 24),
            MovieSection(
              title: 'Coming soon',
              movies: [
                {
                  'title': 'The Marvels',
                  'posterUrl':
                      'https://image.tmdb.org/t/p/w500/hE4P3F2l1p1P7b7g0a4b6c6b3e3.jpg',
                  'rating': '0.0',
                  'durationAndGenre': 'TBD',
                  'storyline':
                      'Carol Danvers, Monica Rambeau, and Kamala Khan team up to save the universe.',
                },
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
