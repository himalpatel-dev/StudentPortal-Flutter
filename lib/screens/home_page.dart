// ignore_for_file: deprecated_member_use, use_build_context_synchronously, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:stradia_ace/providers/student_provider.dart';
import 'package:stradia_ace/providers/tournament_provider.dart';
import 'package:stradia_ace/models/tournament.dart';
import 'package:stradia_ace/models/student_stats.dart';
import 'package:stradia_ace/screens/profile_tab.dart';
import 'package:stradia_ace/screens/fixture_details_screen.dart';
import 'package:stradia_ace/utils/app_colors.dart';
import 'package:stradia_ace/utils/app_fonts.dart';
import 'package:stradia_ace/models/student.dart';
import 'package:stradia_ace/widgets/athlete_id_card.dart';
import 'package:stradia_ace/screens/career_archive_screen.dart';
import 'package:stradia_ace/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );
      studentProvider.fetchStudentDetails();
      studentProvider.fetchStudentStats();
      Provider.of<TournamentProvider>(
        context,
        listen: false,
      ).fetchTournaments();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine status bar style based on selected tab
    // Tab 0 (Home), 1 (Tournament), 3 (Profile) have dark headers -> Light icons
    // Tab 2 (ID Card) has a light background -> Dark icons
    final SystemUiOverlayStyle statusBarStyle =
        (_selectedNavIndex == 0 ||
            _selectedNavIndex == 1 ||
            _selectedNavIndex == 3)
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Consumer2<StudentProvider, TournamentProvider>(
          builder: (context, studentProvider, tournamentProvider, child) {
            if (studentProvider.isLoading && studentProvider.student == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final student = studentProvider.student;
            if (student == null) {
              return const Center(child: Text('Failed to load profile'));
            }

            return Stack(
              children: [
                IndexedStack(
                  index: _selectedNavIndex,
                  children: [
                    _buildHomeContent(studentProvider),
                    const CareerArchiveScreen(),
                    AthleteIdCard(student: student),
                    ProfileTab(student: student),
                  ],
                ),
                if (tournamentProvider.isApplying ||
                    tournamentProvider.isFixtureLoading)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
            _buildNavItem(
              1,
              Icons.emoji_events_outlined,
              Icons.emoji_events_rounded,
              'Tournament',
            ),
            _buildNavItem(
              2,
              Icons.badge_outlined,
              Icons.badge_rounded,
              'ID Card',
            ),
            _buildNavItem(
              3,
              Icons.person_outline_rounded,
              Icons.person_rounded,
              'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = _selectedNavIndex == index;
    final Color activeColor = AppColors.deepAccent;
    final Color inactiveColor = AppColors.textGrey.withOpacity(0.5);

    return GestureDetector(
      onTap: () => setState(() => _selectedNavIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width / 4.5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: activeColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? Colors.white : inactiveColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppFonts.main(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: isSelected ? activeColor : inactiveColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(StudentProvider studentProvider) {
    final student = studentProvider.student!;
    final stats = studentProvider.stats ?? StudentStats.empty();

    return RefreshIndicator(
      onRefresh: () async {
        await studentProvider.fetchStudentDetails();
        await studentProvider.fetchStudentStats();
        await Provider.of<TournamentProvider>(
          context,
          listen: false,
        ).fetchTournaments();
      },
      color: AppColors.deepAccent,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(student, stats),
            Transform.translate(
              offset: const Offset(0, 30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildStatsRow(stats),
                    const SizedBox(height: 24),
                    _buildTournamentSection(student),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic student, StudentStats stats) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBg, AppColors.deepAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 75, 24, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryAccent.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: student.studentProfileImage.isNotEmpty
                            ? Image.network(
                                student.studentProfileImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Text(
                                        student.firstName.isNotEmpty
                                            ? student.firstName[0].toUpperCase()
                                            : 'A',
                                        style: AppFonts.heading(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                              )
                            : Center(
                                child: Text(
                                  student.firstName.isNotEmpty
                                      ? student.firstName[0].toUpperCase()
                                      : 'H',
                                  style: AppFonts.heading(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WELCOME BACK',
                            style: AppFonts.main(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withOpacity(0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            '${student.firstName} ${student.lastName}',
                            style: AppFonts.heading(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              _buildSmallBadge(
                                '${student.uuid.split('-').first.toUpperCase()}',
                                AppColors.primaryAccent.withOpacity(0.1),
                                AppColors.textPrimary,
                                Icons.numbers,
                                fontSize: 11,
                              ),
                              if (student.clubAffiliation.isNotEmpty) ...[
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  height: 4,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.0),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Flexible(
                                  child: _buildSmallBadge(
                                    student.clubAffiliation,
                                    AppColors.primaryAccent.withOpacity(0.1),
                                    AppColors.textPrimary,
                                    Icons.school,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(StudentStats stats) {
    const primaryStatColor = AppColors.deepAccent;

    return Row(
      children: [
        _buildStatCard(
          'Tournaments',
          stats.totalTournamentsPlayed.toString(),
          Icons.sports_martial_arts_outlined,
          primaryStatColor,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Matches',
          stats.totalMatchesPlayed.toString(),
          Icons.sports_mma_rounded,
          primaryStatColor,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Wins',
          stats.totalWins.toString(),
          Icons.emoji_events_rounded,
          primaryStatColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        height: 105,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: iconColor.withOpacity(0.08), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Large Icon
            Positioned(
              right: -12,
              bottom: -12,
              child: Icon(icon, size: 80, color: iconColor.withOpacity(0.10)),
            ),
            // Top Accent Dot
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Text Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: AppFonts.heading(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.toUpperCase(),
                    style: AppFonts.main(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentSection(Student student) {
    return Consumer<TournamentProvider>(
      builder: (context, tournamentProvider, child) {
        if (tournamentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final myTournaments = tournamentProvider.myTournaments;
        final upcomingTournaments = tournamentProvider.upcomingTournaments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (myTournaments.isNotEmpty) ...[
              _buildSectionTitle('MY TOURNAMENTS'),
              const SizedBox(height: 16),
              ...myTournaments.map(
                (t) => _buildTournamentCard(t, student, isMyTournament: true),
              ),
              const SizedBox(height: 24),
            ],
            if (upcomingTournaments.isNotEmpty) ...[
              _buildSectionTitle('UPCOMING TOURNAMENTS'),
              const SizedBox(height: 16),
              ...upcomingTournaments.map(
                (t) => _buildTournamentCard(t, student, isMyTournament: false),
              ),
            ],
            if (myTournaments.isEmpty && upcomingTournaments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No tournaments found',
                    style: AppFonts.main(color: AppColors.textSecondary),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.secondaryAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppFonts.heading(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textGrey.withOpacity(0.8),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTournamentCard(
    Tournament tournament,
    Student student, {
    required bool isMyTournament,
  }) {
    final startDate = DateTime.tryParse(tournament.startDate);
    final daysLeft = startDate != null
        ? startDate.difference(DateTime.now()).inDays
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Part: Tournament Identity
          Container(
            height: 160,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [AppColors.darkBg, AppColors.deepAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date Block
                          _buildDateBlock(startDate),
                          const SizedBox(width: 16),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildSmallBadge(
                                      tournament.tournamentTypeName
                                          .toUpperCase(),
                                      AppColors.secondaryAccent.withOpacity(
                                        0.2,
                                      ),
                                      AppColors.textPrimary,
                                      Icons.track_changes_rounded,
                                      borderColor: Colors.white.withOpacity(
                                        0.15,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  tournament.tournamentName,
                                  style: AppFonts.heading(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    height: 1.1,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppColors.primaryAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        tournament.completeAddress.isNotEmpty
                                            ? tournament.completeAddress
                                            : 'Not Provided',
                                        style: AppFonts.main(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: AppColors.primaryAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_formatShortDate(tournament.startDate)} — ${_formatShortDate(tournament.endDate)}',
                                style: AppFonts.main(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          if (daysLeft > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Text(
                                '$daysLeft DAYS',
                                style: AppFonts.main(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Top Right Status Badge
                if (tournament.tournamentStatus.isNotEmpty)
                  Positioned(
                    top: 18,
                    right: 18,
                    child: _buildStatusChip(tournament.tournamentStatus),
                  ),
              ],
            ),
          ),
          // Bottom Part: Category & Action
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              border: Border.all(color: AppColors.darkBg.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkBg.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.darkBg.withOpacity(0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.track_changes_rounded,
                          color: AppColors.textGrey,
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isMyTournament
                                    ? 'CATEGORY'
                                    : 'SUGGESTED CATEGORY',
                                style: AppFonts.main(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textGrey,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  final String categoryName = isMyTournament
                                      ? (tournament
                                                .categoryDivisionName
                                                .isNotEmpty
                                            ? tournament.categoryDivisionName
                                            : 'N/A')
                                      : (tournament.suggestedCategory.isNotEmpty
                                            ? tournament.suggestedCategory
                                            : 'Not Calculated');
                                  return Tooltip(
                                    message: categoryName.toUpperCase(),
                                    triggerMode: TooltipTriggerMode.tap,
                                    preferBelow: false,
                                    decoration: BoxDecoration(
                                      color: AppColors.deepAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: AppFonts.main(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    child: Text(
                                      categoryName.toUpperCase(),
                                      style: AppFonts.heading(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textDark,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 38,
                  width: 100,
                  child: _buildPrimaryActionButton(
                    isMyTournament ? 'FIXTURE' : 'APPLY',
                    Icons.layers_rounded,
                    onTap: isMyTournament
                        ? () async {
                            final provider = Provider.of<TournamentProvider>(
                              context,
                              listen: false,
                            );
                            final result = await provider.fetchFixtureDetails(
                              tournament.tournamentId,
                            );

                            if (context.mounted) {
                              if (result != null &&
                                  result['approval_status']
                                          ?.toString()
                                          .toUpperCase() ==
                                      'PENDING') {
                                scaffoldMessengerKey.currentState
                                    ?.hideCurrentSnackBar();
                                scaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Your Approval is still pending for this Tournament.',
                                      style: AppFonts.main(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: AppColors.error,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FixtureDetailsScreen(
                                    tournament: tournament,
                                    student: student,
                                  ),
                                ),
                              );
                            }
                          }
                        : () async {
                            if (student.applicationStatus.toUpperCase() !=
                                'APPROVED') {
                              scaffoldMessengerKey.currentState
                                  ?.hideCurrentSnackBar();
                              scaffoldMessengerKey.currentState?.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You cannot apply. Your approval is ${student.applicationStatus.toLowerCase()}.',
                                    style: AppFonts.main(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              return;
                            }

                            final provider = Provider.of<TournamentProvider>(
                              context,
                              listen: false,
                            );
                            final matchResult = await provider
                                .findMatchingCategory(
                                  tournament.tournamentId,
                                  student,
                                  tournament,
                                );

                            if (context.mounted) {
                              if (matchResult != null) {
                                final matchedCategory = matchResult['match'];
                                final allCategories =
                                    matchResult['categories']
                                        as List<dynamic>? ??
                                    [];
                                _showApplyBottomSheet(
                                  context,
                                  tournament,
                                  student,
                                  matchedCategory,
                                  allCategories,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Failed to load categories.'),
                                  ),
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplyBottomSheet(
    BuildContext context,
    Tournament tournament,
    Student student,
    Map<String, dynamic>? matchedCategory,
    List<dynamic> allCategories,
  ) {
    int? selectedCategoryId = int.tryParse(
      matchedCategory?['category_division_id']?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Dark Section
                  Container(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 12,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(25),
                      ),
                      gradient: LinearGradient(
                        colors: [AppColors.darkBg, AppColors.deepAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle and Close Button Row
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        // Tournament Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.sports_gymnastics_rounded,
                                  color: AppColors.textPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tournament.tournamentName.toUpperCase(),
                                      style: AppFonts.heading(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom White Section
                  Padding(
                    padding: EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 24,
                      bottom:
                          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stats Row
                        Row(
                          children: [
                            _buildBottomSheetStatBox(
                              'HEIGHT',
                              student.height,
                              'CM',
                              Icons.straighten,
                            ),
                            const SizedBox(width: 12),
                            _buildBottomSheetStatBox(
                              'WEIGHT',
                              student.weight,
                              'KG',
                              Icons.monitor_weight_outlined,
                            ),
                            const SizedBox(width: 12),
                            _buildBottomSheetStatBox(
                              'PI INDEX',
                              student.physicalIndex,
                              '',
                              Icons.tag,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Category Dropdown
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location_rounded,
                              color: AppColors.deepAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'SELECT CATEGORY',
                              style: AppFonts.main(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: AppColors.deepAccent,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBg.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.darkBg.withOpacity(0.08),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              isExpanded: true,
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              elevation: 8,
                              value: selectedCategoryId,
                              hint: Text(
                                'Choose Category',
                                style: AppFonts.main(
                                  color: AppColors.textGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryAccent.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.secondaryAccent,
                                  size: 15,
                                ),
                              ),
                              items: allCategories.map<DropdownMenuItem<int>>((
                                cat,
                              ) {
                                final int catId =
                                    int.tryParse(
                                      cat['category_division_id']?.toString() ??
                                          '',
                                    ) ??
                                    0;
                                final bool isSelected =
                                    catId == selectedCategoryId;
                                return DropdownMenuItem<int>(
                                  value: catId,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),

                                    child: Row(
                                      children: [
                                        if (isSelected)
                                          Container(
                                            width: 4,
                                            height: 16,
                                            margin: const EdgeInsets.only(
                                              right: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.secondaryAccent,
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                          ),
                                        Expanded(
                                          child: Text(
                                            cat['category_division_name']
                                                    ?.toString() ??
                                                '',
                                            style: AppFonts.heading(
                                              fontSize: 12,
                                              fontWeight: isSelected
                                                  ? FontWeight.w900
                                                  : FontWeight.w700,
                                              color: isSelected
                                                  ? AppColors.secondaryAccent
                                                  : AppColors.textDark,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.secondaryAccent,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                setSheetState(() {
                                  selectedCategoryId = newValue;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Apply Button
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppColors.darkBg, AppColors.deepAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: selectedCategoryId == null
                                ? null
                                : () async {
                                    // Close bottom sheet using its own context
                                    Navigator.pop(sheetContext);

                                    final provider =
                                        Provider.of<TournamentProvider>(
                                          context,
                                          listen: false,
                                        );

                                    final success = await provider
                                        .applyToTournament(
                                          tournamentId:
                                              int.tryParse(
                                                tournament.tournamentId,
                                              ) ??
                                              0,
                                          studentId: student.id,
                                          categoryId: selectedCategoryId!,
                                        );

                                    scaffoldMessengerKey.currentState
                                        ?.hideCurrentSnackBar();
                                    scaffoldMessengerKey.currentState?.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          success
                                              ? 'Applied for tournament successfully!'
                                              : (provider.errorMessage ??
                                                    'Failed to submit application'),
                                          style: AppFonts.main(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        backgroundColor: success
                                            ? Colors.green
                                            : Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(20),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CONFIRM APPLICATION',
                                  style: AppFonts.main(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Disclaimer text
                        Center(
                          child: Text(
                            'BY CONFIRMING YOU AGREE TO TOURNAMENT RULES',
                            style: AppFonts.main(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey[500],
                              letterSpacing: 1.5,
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
        );
      },
    );
  }

  Widget _buildBottomSheetStatBox(
    String label,
    String value,
    String unit,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.fieldBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Subtle blue glow in bottom right
              Positioned(
                right: -12,
                bottom: -12,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryAccent.withOpacity(0.28),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: AppColors.deepAccent, size: 10),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: AppFonts.main(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          value.isEmpty || value == '0' || value == '0.0'
                              ? 'N/A'
                              : value,
                          style: AppFonts.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepAccent,
                          ),
                        ),
                        if (unit.isNotEmpty &&
                            value.isNotEmpty &&
                            value != '0' &&
                            value != '0.0') ...[
                          const SizedBox(width: 2),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              unit,
                              style: AppFonts.main(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateBlock(DateTime? date) {
    if (date == null) return const SizedBox.shrink();
    final months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return Container(
      width: 65,
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            months[date.month - 1],
            style: AppFonts.main(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryAccent,
              letterSpacing: 1,
            ),
          ),
          Text(
            date.day.toString().padLeft(2, '0'),
            style: AppFonts.heading(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            DateFormat('EEE').format(date).toUpperCase(),
            style: AppFonts.main(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(
    String text,
    Color bgColor,
    Color textColor,
    IconData icon, {
    double fontSize = 8,
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize,
        vertical: fontSize * 0.4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(fontSize),
        border: Border.all(color: borderColor ?? textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: textColor),
          SizedBox(width: fontSize * 0.5),
          Flexible(
            child: Text(
              text,
              style: AppFonts.main(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionButton(
    String text,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.darkBg, AppColors.deepAccent],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                text,
                style: AppFonts.main(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatShortDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '---';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'JAN',
        'FEB',
        'MAR',
        'APR',
        'MAY',
        'JUN',
        'JUL',
        'AUG',
        'SEP',
        'OCT',
        'NOV',
        'DEC',
      ];
      return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildStatusChip(String status) {
    Color baseColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'upcoming':
        baseColor = AppColors.secondaryAccent; // Mauve Grey from image
        icon = Icons.calendar_today_rounded;
        break;
      case 'in_progress':
      case 'live':
      case 'ongoing':
        baseColor = AppColors.secondaryAccent; // Mauve Grey from image
        icon = Icons.play_circle_fill_rounded;
        break;
      case 'cancelled':
        baseColor = AppColors.deepAccent;
        icon = Icons.cancel_rounded;
        break;
      case 'completed':
      case 'closed':
      case 'open':
      case 'active':
        baseColor = AppColors.primaryAccent;
        icon = Icons.check_circle_rounded;
        break;
      default:
        baseColor = AppColors.textSecondary;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: AppFonts.main(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class CardLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 12.0;

    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 12.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
