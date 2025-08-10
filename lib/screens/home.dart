import 'package:flutter/material.dart';

// 영화 목록을 표시하는 커스텀 위젯
class MovieSection extends StatelessWidget {
  final String title;
  final List<String> posterUrls;
  final bool isLargePoster;

  const MovieSection({
    super.key,
    required this.title,
    required this.posterUrls,
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
            itemCount: posterUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    posterUrls[index],
                    fit: BoxFit.cover,
                    width: isLargePoster ? 300 : 120,
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
          children: const [
            SizedBox(height: 16),
            MovieSection(
              title: 'Popular Movies',
              posterUrls: [
                'https://image.tmdb.org/t/p/w500/rCzpDGLbOoPwLj3JcqqN3LHiuO9.jpg',
                'https://image.tmdb.org/t/p/w500/yJ0w6lY4H4gNfW1Q22G5vj5C1rL.jpg',
                'https://image.tmdb.org/t/p/w500/a2uNtyy54sYhV9s1E9n0o1rQ9D4.jpg',
              ],
              isLargePoster: true,
            ),
            SizedBox(height: 24),
            MovieSection(
              title: 'Now in Cinemas',
              posterUrls: [
                'https://image.tmdb.org/t/p/w500/aH0fE59c5d1qF5n5z8s6F6e6d1e.jpg',
                'https://image.tmdb.org/t/p/w500/aQhD4Xh8t2wN0x9J5w7r9V5j9mG.jpg',
                'https://image.tmdb.org/t/p/w500/iL8f65Xw8C3GgBvM3l24z6E6e6f.jpg',
                'https://image.tmdb.org/t/p/w500/gW9e3d8eD6H3gV5h6G5j7l7a8b3.jpg',
              ],
              isLargePoster: false,
            ),
            SizedBox(height: 24),
            MovieSection(
              title: 'Coming soon',
              posterUrls: [
                'https://image.tmdb.org/t/p/w500/hE4P3F2l1p1P7b7g0a4b6c6b3e3.jpg',
                'https://image.tmdb.org/t/p/w500/bJ836e5x7j2u4g6d5p1n2m9k3o4.jpg',
                'https://image.tmdb.org/t/p/w500/bL9y2y6c9d8e7h2f5g3t1y7r8q0.jpg',
              ],
              isLargePoster: false,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
