class FighterDetail {
  final String id;
  final String firstName;
  final String fullName;
  final String studentProfileImage;
  final String clubAffiliation;
  final int score;
  final bool isYou;

  FighterDetail({
    required this.id,
    required this.firstName,
    required this.fullName,
    required this.studentProfileImage,
    required this.clubAffiliation,
    required this.score,
    required this.isYou,
  });

  factory FighterDetail.fromJson(Map<String, dynamic> json) {
    return FighterDetail(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      studentProfileImage: json['student_profile_image']?.toString() ?? '',
      clubAffiliation: json['club_affiliation']?.toString() ?? '',
      score: int.tryParse(json['score']?.toString() ?? '0') ?? 0,
      isYou: json['is_you'] ?? false,
    );
  }
}

class MatchDetail {
  final String matchId;
  final String matchName;
  final int roundNo;
  final String matchStatus;
  final String matchResult;
  final int redPoints;
  final int whitePoints;
  final FighterDetail? redFighter;
  final FighterDetail? whiteFighter;

  MatchDetail({
    required this.matchId,
    required this.matchName,
    required this.roundNo,
    required this.matchStatus,
    required this.matchResult,
    required this.redPoints,
    required this.whitePoints,
    this.redFighter,
    this.whiteFighter,
  });

  factory MatchDetail.fromJson(Map<String, dynamic> json) {
    return MatchDetail(
      matchId: json['match_id']?.toString() ?? '',
      matchName: json['match_name']?.toString() ?? '',
      roundNo: int.tryParse(json['round_no']?.toString() ?? '0') ?? 0,
      matchStatus: json['match_status']?.toString() ?? '',
      matchResult: json['match_result']?.toString() ?? '',
      redPoints: int.tryParse(json['red_points']?.toString() ?? '0') ?? 0,
      whitePoints: int.tryParse(json['white_points']?.toString() ?? '0') ?? 0,
      redFighter: json['red_fighter'] != null ? FighterDetail.fromJson(json['red_fighter']) : null,
      whiteFighter: json['white_fighter'] != null ? FighterDetail.fromJson(json['white_fighter']) : null,
    );
  }
}

class Tournament {
  final String tournamentId;
  final String tournamentName;
  final String tournamentCode;
  final String tournamentStatus;
  final String startDate;
  final String endDate;
  final String registrationStartDate;
  final String lastEnrollmentDate;
  final String tournamentTypeName;
  final String completeAddress;
  final String categoryDivisionName;
  final String suggestedCategory;
  final String ageCutoffDate;
  final String? medal;
  final int bouts;
  final int wins;
  final int losses;
  final List<MatchDetail> matchesDetails;
  final String? certificateUrl;

  Tournament({
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentCode,
    required this.tournamentStatus,
    required this.startDate,
    required this.endDate,
    required this.registrationStartDate,
    required this.lastEnrollmentDate,
    required this.tournamentTypeName,
    required this.completeAddress,
    required this.categoryDivisionName,
    this.suggestedCategory = '',
    this.ageCutoffDate = '',
    this.medal,
    this.bouts = 0,
    this.wins = 0,
    this.losses = 0,
    this.matchesDetails = const [],
    this.certificateUrl,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      tournamentId: json['tournament_id']?.toString() ?? '',
      tournamentName: json['tournament_name']?.toString() ?? '',
      tournamentCode: json['tournament_code']?.toString() ?? '',
      tournamentStatus: json['tournament_status']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      registrationStartDate: json['registration_start_date']?.toString() ?? '',
      lastEnrollmentDate: json['last_enrollment_date']?.toString() ?? '',
      tournamentTypeName: json['tournament_type_name']?.toString() ?? '',
      completeAddress: json['complete_address']?.toString() ?? '',
      categoryDivisionName: (json['category_division_name'] ?? json['suggested_category'])?.toString() ?? '',
      suggestedCategory: json['suggested_category']?.toString() ?? '',
      ageCutoffDate: json['age_cutoff_date']?.toString() ?? '',
      medal: json['medal']?.toString(),
      bouts: int.tryParse(json['bouts']?.toString() ?? '0') ?? 0,
      wins: int.tryParse(json['wins']?.toString() ?? '0') ?? 0,
      losses: int.tryParse(json['losses']?.toString() ?? '0') ?? 0,
      matchesDetails: (json['matches_details'] as List?)
              ?.map((m) => MatchDetail.fromJson(m))
              .toList() ??
          [],
      certificateUrl: json['certificate_url']?.toString(),
    );
  }
}
