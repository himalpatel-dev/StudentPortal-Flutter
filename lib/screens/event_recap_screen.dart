import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_portal/providers/tournament_provider.dart';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/utils/app_fonts.dart';
import 'package:student_portal/models/tournament.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class EventRecapScreen extends StatefulWidget {
  final Tournament tournament;

  const EventRecapScreen({super.key, required this.tournament});

  @override
  State<EventRecapScreen> createState() => _EventRecapScreenState();
}

class _EventRecapScreenState extends State<EventRecapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TournamentProvider>().fetchTournamentRecap(
        widget.tournament.tournamentId,
      );
    });
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getShortLocation(String address) {
    if (address.isEmpty) return 'N/A';
    final parts = address.split(',');
    if (parts.length > 1) {
      return parts.sublist(parts.length - 2).join(',').trim();
    }
    return address;
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<TournamentProvider>(
        builder: (context, provider, child) {
          final tournament = provider.tournamentRecap ?? widget.tournament;
          final isLoading = provider.isRecapLoading;

          return SafeArea(
            top: false,
            bottom: true,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, tournament),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.deepAccent,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildStatsGrid(tournament),
                          const SizedBox(height: 32),
                          _buildSectionHeader('FIGHT CARD / BOUT BREAKDOWN'),
                          const SizedBox(height: 16),
                          _buildFightTimeline(tournament),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Tournament tournament) {
    final displayDate = _formatDate(tournament.startDate);
    final shortLocation = _getShortLocation(tournament.completeAddress);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (tournament.certificateUrl != null &&
                      tournament.certificateUrl!.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _launchURL(tournament.certificateUrl!),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.description_outlined,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CERTIFICATE',
                                style: AppFonts.main(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${tournament.tournamentTypeName} • $displayDate'
                          .toUpperCase(),
                      style: AppFonts.main(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tournament.tournamentName.toUpperCase(),
                    style: AppFonts.heading(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white54,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shortLocation,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.main(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildHeaderInfoChip(
                        Icons.stars_outlined,
                        tournament.categoryDivisionName,
                      ),
                      const SizedBox(width: 8),
                      _buildHeaderInfoChip(
                        Icons.category_outlined,
                        tournament.tournamentCode,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (tournament.medal != null && tournament.medal!.isNotEmpty)
                    Builder(
                      builder: (context) {
                        Color medalColor;
                        switch (tournament.medal?.toUpperCase()) {
                          case 'GOLD':
                            medalColor = const Color(0xFFFFC107);
                            break;
                          case 'SILVER':
                            medalColor = const Color.fromARGB(
                              255,
                              172,
                              172,
                              172,
                            );
                            break;
                          case 'BRONZE':
                            medalColor = const Color(0xFFCD7F32);
                            break;
                          default:
                            medalColor = const Color(0xFFFFC107);
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: medalColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: medalColor.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.military_tech,
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FINAL STANDING',
                                      style: AppFonts.main(
                                        color: Colors.black.withOpacity(0.6),
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      tournament.medal!.toUpperCase(),
                                      style: AppFonts.heading(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildStatsGrid(Tournament tournament) {
    return Row(
      children: [
        _buildStatBox(
          tournament.bouts.toString(),
          'BOUTS',
          Icons.sports_martial_arts,
          AppColors.deepAccent,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          tournament.wins.toString(),
          'WINS',
          Icons.emoji_events_rounded,
          AppColors.success,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          tournament.losses.toString(),
          'LOSSES',
          Icons.cancel_sharp,
          AppColors.error,
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 90,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -8,
              child: Icon(icon, size: 70, color: color.withOpacity(0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: AppFonts.heading(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: AppFonts.main(
                      color: AppColors.textGrey.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.deepAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppFonts.main(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFightTimeline(Tournament tournament) {
    if (tournament.matchesDetails.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 16),
          Icon(
            Icons.query_stats_rounded,
            size: 48,
            color: AppColors.textGrey.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'Detailed bout information is currently unavailable.',
            textAlign: TextAlign.center,
            style: AppFonts.main(
              color: AppColors.textGrey.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tournament.matchesDetails.length,
      itemBuilder: (context, index) {
        final match = tournament.matchesDetails[index];
        final isLast = index == tournament.matchesDetails.length - 1;
        return _buildFightCard(match, isLast);
      },
    );
  }

  Widget _buildFightCard(MatchDetail match, bool isLast) {
    final String originalResult = match.matchResult.toUpperCase();
    final bool whiteIsYou = match.whiteFighter?.isYou ?? false;

    // The API match_result is already relative to the player
    final bool youWon = originalResult == 'WIN' || originalResult == 'BYE';
    final bool isBye = originalResult == 'BYE';

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (youWon) {
      statusColor = isBye ? const Color(0xFFFFC107) : AppColors.success;
      statusIcon = isBye ? Icons.fast_forward_rounded : Icons.stars_rounded;
      statusText = isBye ? 'BYE' : 'WIN';
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel_outlined;
      statusText = 'LOSS';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: Timeline Dot & Line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withOpacity(0.5),
                        isLast
                            ? Colors.transparent
                            : AppColors.fieldBorder.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Right: Card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.fieldBorder.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  children: [
                    // Header Area
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      color: statusColor.withOpacity(0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Round ${match.roundNo} - ${match.matchName}'
                                .toUpperCase(),
                            style: AppFonts.main(
                              color: AppColors.textGrey.withOpacity(0.5),
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  statusIcon,
                                  color: statusText == 'BYE'
                                      ? Colors.black
                                      : Colors.white,
                                  size: 10,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusText,
                                  style: AppFonts.main(
                                    color: statusText == 'BYE'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Match Details Area
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                      child: Builder(
                        builder: (context) {
                          final fighterLeft = whiteIsYou
                              ? match.whiteFighter
                              : match.redFighter;
                          final fighterRight = whiteIsYou
                              ? match.redFighter
                              : match.whiteFighter;
                          final pointsLeft = whiteIsYou
                              ? match.whitePoints
                              : match.redPoints;
                          final pointsRight = whiteIsYou
                              ? match.redPoints
                              : match.whitePoints;

                          final bool isLeftWinner = youWon;
                          final bool isRightWinner = !youWon && !isBye;

                          return Row(
                            children: [
                              Expanded(
                                child: _buildFighterInfo(
                                  fighterLeft?.fullName ?? 'N/A',
                                  fighterLeft?.clubAffiliation ?? 'N/A',
                                  fighterLeft?.studentProfileImage ?? '',
                                  statusColor,
                                  isWinner: isLeftWinner,
                                  isYou: fighterLeft?.isYou ?? false,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isBye)
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      Text(
                                        'ADVANCED',
                                        style: AppFonts.main(
                                          color: AppColors.textGrey.withOpacity(
                                            0.4,
                                          ),
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      pointsLeft.toString(),
                                      style: AppFonts.heading(
                                        color: isLeftWinner
                                            ? statusColor
                                            : Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '-',
                                      style: AppFonts.main(
                                        color: AppColors.textGrey.withOpacity(
                                          0.3,
                                        ),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      pointsRight.toString(),
                                      style: AppFonts.heading(
                                        color: isRightWinner
                                            ? statusColor
                                            : Colors.black,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildFighterInfo(
                                  fighterRight?.fullName ?? 'N/A',
                                  fighterRight?.clubAffiliation ?? 'N/A',
                                  fighterRight?.studentProfileImage ?? '',
                                  isRightWinner
                                      ? statusColor
                                      : AppColors.fieldBg,
                                  isWinner: isRightWinner,
                                  isOpponent: !(fighterRight?.isYou ?? false),
                                  isYou: fighterRight?.isYou ?? false,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFighterInfo(
    String name,
    String club,
    String imageUrl,
    Color color, {
    bool isWinner = false,
    bool isOpponent = false,
    bool isYou = false,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.fieldBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isWinner ? color : AppColors.fieldBorder,
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildInitialsAvatar(name, isWinner, color),
                      )
                    : _buildInitialsAvatar(name, isWinner, color),
              ),
            ),
            if (isWinner)
              Positioned(
                right: -2,
                bottom: -2,
                child: Icon(Icons.check_circle, color: color, size: 14),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          isYou ? 'YOU' : name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.main(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isYou ? AppColors.deepAccent : Colors.black,
          ),
        ),
        Text(
          club,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.main(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: AppColors.textGrey.withOpacity(0.5),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar(String name, bool isWinner, Color color) {
    if (name == 'N/A')
      return Icon(
        Icons.person_off_rounded,
        color: AppColors.textDisabled,
        size: 16,
      );

    final initials = name
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: AppFonts.heading(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isWinner ? color : Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeaderInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 12),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.main(
                color: Colors.white.withOpacity(0.9),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
