class StudentStats {
  final int totalTournamentsPlayed;
  final int totalMatchesPlayed;
  final int totalWins;

  StudentStats({
    required this.totalTournamentsPlayed,
    required this.totalMatchesPlayed,
    required this.totalWins,
  });

  factory StudentStats.fromJson(Map<String, dynamic> json) {
    return StudentStats(
      totalTournamentsPlayed: json['totalTournamentsPlayed'] ?? 0,
      totalMatchesPlayed: json['totalMatchesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
    );
  }

  factory StudentStats.empty() {
    return StudentStats(
      totalTournamentsPlayed: 0,
      totalMatchesPlayed: 0,
      totalWins: 0,
    );
  }
}
