import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:student_portal/models/fixture.dart';
import 'package:student_portal/models/student.dart';
import 'package:student_portal/models/tournament.dart';
import 'package:student_portal/providers/tournament_provider.dart';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/utils/app_fonts.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TournamentProvider>(
        context,
        listen: false,
      ).fetchFixtureDetails(widget.tournament.tournamentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
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

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.fixtureDetails.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.fixtureDetails.length) {
                      return _buildInstructionCard();
                    }
                    return _buildFixtureCard(provider.fixtureDetails[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black,
            AppColors.darkBlueGradient,
            AppColors.deepAccent,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.topCenter,
        ),
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
              const SizedBox(height: 24),
              // Player Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryAccent,
                      backgroundImage:
                          widget.student.studentProfileImage.isNotEmpty
                          ? NetworkImage(widget.student.studentProfileImage)
                          : null,
                      child: widget.student.studentProfileImage.isEmpty
                          ? Text(
                              widget.student.firstName[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.fullName,
                            style: AppFonts.heading(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.shield_outlined,
                                size: 12,
                                color: const Color.fromARGB(213, 255, 255, 255),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.student.clubAffiliation,
                                style: AppFonts.main(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color.fromARGB(
                                    213,
                                    255,
                                    255,
                                    255,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                      child: Text(
                        widget.student.uuid,
                        style: AppFonts.main(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
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

  Widget _buildHeaderIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildFixtureCard(Fixture fixture) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black26, width: 1),
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
                Container(width: 1, height: 80, color: Colors.black26),
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
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '#',
                            style: AppFonts.main(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MATCH ID ${fixture.matchId}',
                            style: AppFonts.main(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black26),
          // Category
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: AppColors.primaryAccent,
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
                          color: Colors.black26,
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
          Divider(height: 1, color: Colors.black26),
          // Ring, Pool, Report Grid
          IntrinsicHeight(
            child: Row(
              children: [
                _buildGridItem(
                  Icons.flag_rounded,
                  'RING',
                  '#${fixture.ringNo}',
                ),
                VerticalDivider(width: 1, color: Colors.black26),
                _buildGridItem(Icons.layers_rounded, 'POOL', fixture.poolNo),
                VerticalDivider(width: 1, color: Colors.black26),
                _buildGridItem(
                  Icons.access_time_rounded,
                  'REPORT',
                  fixture.reportingTime,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.black26),
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
                          color: Colors.black26,
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
              color: AppColors.primaryAccent,
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
              color: Colors.black26,
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
                Icon(icon, size: 12, color: Colors.black26),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppFonts.main(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Colors.black26,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.red.withOpacity(0.6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Be at the ring 10 min before reporting time',
                  style: AppFonts.heading(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 46),
            child: Text(
              'Carry your ID card and a copy of the fixture. Late reporting may result in disqualification per tournament rules.',
              style: AppFonts.main(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black45,
                height: 1.5,
              ),
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
        style: AppFonts.main(color: Colors.grey),
      ),
    );
  }
}
