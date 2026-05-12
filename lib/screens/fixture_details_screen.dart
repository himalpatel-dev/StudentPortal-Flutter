import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:stradia_ace/models/fixture.dart';
import 'package:stradia_ace/models/student.dart';
import 'package:stradia_ace/models/tournament.dart';
import 'package:stradia_ace/providers/tournament_provider.dart';
import 'package:stradia_ace/utils/app_colors.dart';
import 'package:stradia_ace/utils/app_fonts.dart';

class FixtureDetailsScreen extends StatefulWidget {
  final Tournament tournament;
  final Student student;

  const FixtureDetailsScreen({
    super.key,
    required this.tournament,
    required this.student,
  });

  @override
  State<FixtureDetailsScreen> createState() => _FixtureDetailsScreenState();
}

class _FixtureDetailsScreenState extends State<FixtureDetailsScreen> {
  final Set<int> _expandedMatchIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TournamentProvider>(
        context,
        listen: false,
      );
      if (provider.lastFetchedFixtureTournamentId !=
          widget.tournament.tournamentId) {
        provider.fetchFixtureDetails(widget.tournament.tournamentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<TournamentProvider>(
                builder: (context, provider, child) {
                  if (provider.isFixtureLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.fixtureDetails.isEmpty) {
                    return _buildEmptyState();
                  }

                  final sortedFixtures = List.from(provider.fixtureDetails);
                  sortedFixtures.sort((a, b) {
                    // Sort by round number descending (Latest round first)
                    return b.roundNo.compareTo(a.roundNo);
                  });

                  final scheduled = sortedFixtures
                      .where((f) => f.matchStatus.toLowerCase() == 'scheduled')
                      .toList();
                  final completed = sortedFixtures
                      .where((f) => f.matchStatus.toLowerCase() != 'scheduled')
                      .toList();

                  int itemCount = 1 + scheduled.length;
                  if (completed.isNotEmpty) {
                    itemCount += 1 + completed.length;
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: _buildInstructionCard(),
                        );
                      }

                      // Scheduled Matches
                      if (index <= scheduled.length) {
                        return _buildFixtureCard(
                          scheduled[index - 1],
                          isExpanded: true,
                          onToggle: () {},
                        );
                      }

                      // Completed Section Header
                      int completedHeaderIndex = scheduled.length + 1;
                      if (index == completedHeaderIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 10,
                            bottom: 20,
                            left: 4,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryAccent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'COMPLETED MATCHES',
                                style: AppFonts.main(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textDark,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Completed Matches
                      int completedMatchIndex =
                          index - completedHeaderIndex - 1;
                      final fixture = completed[completedMatchIndex];
                      return _buildFixtureCard(
                        fixture,
                        isExpanded: _expandedMatchIds.contains(fixture.matchId),
                        onToggle: () {
                          setState(() {
                            if (_expandedMatchIds.contains(fixture.matchId)) {
                              _expandedMatchIds.remove(fixture.matchId);
                            } else {
                              _expandedMatchIds.add(fixture.matchId);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBg, AppColors.deepAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  Consumer<TournamentProvider>(
                    builder: (context, provider, child) {
                      if (provider.participantSlipUrl == null ||
                          provider.participantSlipUrl!.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () async {
                          final Uri url = Uri.parse(
                            provider.participantSlipUrl!,
                          );
                          if (!await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          )) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not open participant slip',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SLIP',
                                style: AppFonts.main(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    'FIXTURE',
                    style: AppFonts.main(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryAccent,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.tournament.tournamentName,
                style: AppFonts.heading(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFixtureCard(
    Fixture fixture, {
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final bool isCompleted = fixture.matchStatus.toLowerCase() == 'completed';

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isCompleted ? Colors.black12 : Colors.black26,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildCardDateBlock(fixture.matchDate),
                  const SizedBox(width: 20),
                  Container(
                    width: 1,
                    height: 80,
                    color: isCompleted ? Colors.black12 : Colors.black26,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ROUND ${fixture.roundNo}',
                              style: AppFonts.main(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black38,
                                letterSpacing: 1,
                              ),
                            ),
                            _buildStatusBadge(fixture.matchStatus),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fixture.matchName,
                          style: AppFonts.heading(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '#',
                                  style: AppFonts.main(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.secondaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'MATCH ID ${fixture.matchId}',
                                  style: AppFonts.main(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textGrey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            if (isCompleted)
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                                color: Colors.black26,
                                size: 20,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              Divider(
                height: 1,
                color: isCompleted ? Colors.black12 : Colors.black26,
              ),
              // Category
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.track_changes_rounded,
                        color: AppColors.secondaryAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CATEGORY',
                            style: AppFonts.main(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondaryAccent,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            fixture.categoryName,
                            style: AppFonts.heading(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isCompleted ? Colors.black12 : Colors.black26,
              ),
              // Ring, Pool, Report Grid
              IntrinsicHeight(
                child: Row(
                  children: [
                    _buildGridItem(
                      Icons.flag_rounded,
                      'RING',
                      '#${fixture.ringNo}',
                    ),
                    VerticalDivider(
                      width: 1,
                      color: isCompleted ? Colors.black12 : Colors.black26,
                    ),
                    _buildGridItem(
                      Icons.layers_rounded,
                      'POOL',
                      fixture.poolNo,
                    ),
                    VerticalDivider(
                      width: 1,
                      color: isCompleted ? Colors.black12 : Colors.black26,
                    ),
                    _buildGridItem(
                      Icons.access_time_rounded,
                      'REPORT',
                      fixture.reportingTime,
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: isCompleted ? Colors.black12 : Colors.black26,
              ),
              // Reporting Window
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.whatshot_rounded,
                        color: Colors.red.withOpacity(0.6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REPORTING WINDOW',
                            style: AppFonts.main(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondaryAccent,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${fixture.matchDate} · ${fixture.reportingTime}',
                            style: AppFonts.heading(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardDateBlock(String dateStr) {
    try {
      final date = DateFormat('dd/MM/yyyy').parse(dateStr);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            DateFormat('MMM').format(date).toUpperCase(),
            style: AppFonts.main(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.secondaryAccent,
              letterSpacing: 1,
            ),
          ),
          Text(
            DateFormat('dd').format(date),
            style: AppFonts.heading(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.1,
            ),
          ),
          Text(
            DateFormat('EEEE').format(date).toUpperCase(),
            style: AppFonts.main(
              fontSize: 8,
              fontWeight: FontWeight.w800,
              color: AppColors.secondaryAccent,
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox(width: 50);
    }
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: AppFonts.main(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.red,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(IconData icon, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: AppColors.secondaryAccent),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppFonts.main(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.secondaryAccent,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppFonts.heading(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.red.withOpacity(0.7),
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IMPORTANT NOTICE',
                  style: AppFonts.main(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.red.withOpacity(0.8),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Arrive 10m early with ID & fixture copy. Late entry may lead to disqualification.',
                  style: AppFonts.main(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No fixtures found',
        style: AppFonts.main(color: AppColors.textSecondary),
      ),
    );
  }
}
