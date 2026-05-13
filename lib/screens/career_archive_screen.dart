// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:stradia_ace/utils/app_colors.dart';
import 'package:stradia_ace/utils/app_fonts.dart';
import 'package:stradia_ace/screens/event_recap_screen.dart';
import 'package:provider/provider.dart';
import 'package:stradia_ace/providers/tournament_provider.dart';
import 'package:stradia_ace/models/tournament.dart';
import 'package:intl/intl.dart';

class CareerArchiveScreen extends StatefulWidget {
  final bool showBackButton;
  const CareerArchiveScreen({super.key, this.showBackButton = false});

  @override
  State<CareerArchiveScreen> createState() => _CareerArchiveScreenState();
}

class _CareerArchiveScreenState extends State<CareerArchiveScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<TournamentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.completedTournaments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchTournaments();
            },
            color: AppColors.deepAccent,
            backgroundColor: Colors.white,
            child: Column(
              children: [
                _buildHeader(context, provider),
                Expanded(child: _buildTournamentList(context, provider)),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildHeader(BuildContext context, TournamentProvider provider) {
    final completed = provider.completedTournaments;
    final total = completed.length;
    final gold = completed
        .where((t) => t.medal?.toUpperCase() == 'GOLD')
        .length;
    final silver = completed
        .where((t) => t.medal?.toUpperCase() == 'SILVER')
        .length;
    final bronze = completed
        .where((t) => t.medal?.toUpperCase() == 'BRONZE')
        .length;

    int totalBouts = 0;
    int totalWins = 0;
    for (var t in completed) {
      totalBouts += t.bouts;
      totalWins += t.wins;
    }
    final winRate = totalBouts > 0 ? (totalWins / totalBouts * 100).toInt() : 0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBg, AppColors.deepAccent],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [const Spacer()],
              ),
            ),

            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'EVERY FIGHT. ',
                          style: AppFonts.heading(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'EVERY RESULT.',
                          style: AppFonts.heading(
                            color: AppColors.secondaryAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Grid
                  Row(
                    children: [
                      _buildStatCard(
                        total.toString(),
                        'TOTAL',
                        Colors.white.withOpacity(0.1),
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        gold.toString(),
                        'GOLD',
                        const Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        silver.toString(),
                        'SILVER',
                        const Color(0xFFCFD8DC),
                      ),
                      const SizedBox(width: 8),
                      _buildStatCard(
                        bronze.toString(),
                        'BRONZE',
                        const Color(0xFFCD7F32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Career Win Rate
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CAREER WIN RATE',
                                  style: AppFonts.main(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$winRate%',
                                      style: AppFonts.heading(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '$totalWins/$totalBouts bouts',
                                        style: AppFonts.main(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(
                              Icons.emoji_events,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: totalBouts > 0
                                ? (totalWins / totalBouts)
                                : 0,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            color: Colors.redAccent,
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppFonts.heading(
                color: color == Colors.white.withOpacity(0.1)
                    ? Colors.white
                    : Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: AppFonts.main(
                color: color == Colors.white.withOpacity(0.1)
                    ? Colors.white.withOpacity(0.5)
                    : Colors.black.withOpacity(0.6),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentList(
    BuildContext context,
    TournamentProvider provider,
  ) {
    final tournaments = provider.completedTournaments;

    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: AppColors.textGrey.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              'No completed tournaments yet',
              style: AppFonts.main(color: AppColors.textGrey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        Color medalColor;
        switch (tournament.medal?.toUpperCase()) {
          case 'GOLD':
            medalColor = const Color(0xFFFFC107);
            break;
          case 'SILVER':
            medalColor = const Color.fromARGB(255, 172, 172, 172);
            break;
          case 'BRONZE':
            medalColor = const Color(0xFFCD7F32);
            break;
          default:
            medalColor = Colors.grey.shade400;
        }

        return _buildTournamentCard(context, tournament, medalColor);
      },
    );
  }

  Widget _buildTournamentCard(
    BuildContext context,
    Tournament tournament,
    Color medalColor,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventRecapScreen(tournament: tournament),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: medalColor),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Medal Section
                    Container(
                      width: 70,
                      color: medalColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            (tournament.medal == null ||
                                    tournament.medal == 'NONE')
                                ? Icons.sports_martial_arts
                                : Icons.military_tech,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          if (tournament.medal != null &&
                              tournament.medal != 'NONE')
                            Text(
                              tournament.medal!,
                              style: AppFonts.main(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Content Section
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryAccent
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tournament.tournamentTypeName,
                                    style: AppFonts.main(
                                      color: AppColors.secondaryAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tournament.categoryDivisionName,
                                  style: AppFonts.main(
                                    color: AppColors.textGrey.withOpacity(0.5),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tournament.tournamentName,
                              style: AppFonts.heading(
                                color: AppColors.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: AppColors.textGrey.withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(tournament.startDate),
                                  style: TextStyle(
                                    color: AppColors.textGrey.withOpacity(0.5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Icon(
                          Icons.chevron_right,
                          color: AppColors.fieldBorder,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats Row
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.fieldBorder)),
                ),
                child: Row(
                  children: [
                    _buildMiniStat(tournament.bouts.toString(), 'BOUTS'),
                    _buildMiniStat(
                      tournament.wins.toString(),
                      'WINS',
                      color: Colors.redAccent,
                    ),
                    _buildMiniStat(tournament.losses.toString(), 'LOSSES'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, {Color? color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: AppColors.fieldBorder)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppFonts.heading(
                color: color ?? AppColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: AppFonts.main(
                color: AppColors.textGrey.withOpacity(0.4),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
