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
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      tournamentId: json['tournament_id']?.toString() ?? '',
      tournamentName: json['tournament_name'] ?? '',
      tournamentCode: json['tournament_code'] ?? '',
      tournamentStatus: json['tournament_status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      registrationStartDate: json['registration_start_date'] ?? '',
      lastEnrollmentDate: json['last_enrollment_date'] ?? '',
      tournamentTypeName: json['tournament_type_name'] ?? '',
      completeAddress: json['complete_address'] ?? '',
      categoryDivisionName: json['category_division_name'] ?? '',
      suggestedCategory: json['suggested_category'] ?? '',
      ageCutoffDate: json['age_cutoff_date'] ?? '',
    );
  }
}
