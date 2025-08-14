// =============================================================================
// 데이터 모델
// =============================================================================

// 장르 ID
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

// 영화 정보 모델 클래스
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
