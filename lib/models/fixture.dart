class Fixture {
  final String categoryName;
  final int ringNo;
  final String poolNo;
  final String matchDate;
  final String reportingTime;
  final int roundNo;
  final String matchName;
  final int matchId;
  final String matchStatus;

  Fixture({
    required this.categoryName,
    required this.ringNo,
    required this.poolNo,
    required this.matchDate,
    required this.reportingTime,
    required this.roundNo,
    required this.matchName,
    required this.matchId,
    required this.matchStatus,
  });

  factory Fixture.fromJson(Map<String, dynamic> json) {
    return Fixture(
      categoryName: json['category_name'] ?? '',
      ringNo: json['ring_no'] ?? 0,
      poolNo: json['pool_no']?.toString() ?? '-',
      matchDate: json['match_date'] ?? '',
      reportingTime: json['reporting_time'] ?? '',
      roundNo: json['round_no'] ?? 0,
      matchName: json['match_name'] ?? '',
      matchId: json['match_id'] ?? 0,
      matchStatus: json['match_status'] ?? '',
    );
  }
}
