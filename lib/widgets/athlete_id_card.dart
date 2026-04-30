import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:student_portal/models/student.dart';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/utils/app_fonts.dart';

class AthleteIdCard extends StatefulWidget {
  final Student student;

  const AthleteIdCard({super.key, required this.student});

  @override
  State<AthleteIdCard> createState() => _AthleteIdCardState();
}

class _AthleteIdCardState extends State<AthleteIdCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: constraints.maxHeight,
          padding: const EdgeInsets.fromLTRB(10, 60, 10, 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ATHLETE  ·  IDENTITY',
                style: AppFonts.main(
                  fontSize: 11,
                  color: AppColors.deepAccent,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight * 0.85,
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 360,
                        height: 670,
                        child: GestureDetector(
                          onTap: _toggleCard,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              final angle = _animation.value * math.pi;
                              return Transform(
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle),
                                alignment: Alignment.center,
                                child: angle < math.pi / 2
                                    ? _buildFront()
                                    : Transform(
                                        transform: Matrix4.identity()
                                          ..rotateY(math.pi),
                                        alignment: Alignment.center,
                                        child: _buildBack(),
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return Container(
      width: double.infinity,
      height: 620,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppColors.darkBg, AppColors.deepAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBg.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Removed pattern for a cleaner solid look
          const SizedBox.shrink(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'IDENTITY CARD',
                      style: AppFonts.heading(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Athlete Image
                Center(
                  child: Container(
                    width: 190,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.primaryAccent.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: -5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          widget.student.studentProfileImage.isNotEmpty
                              ? Image.network(
                                  widget.student.studentProfileImage,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                              : Text(
                                  widget.student.firstName[0].toUpperCase(),
                                  style: AppFonts.heading(
                                    fontSize: 80,
                                    color: AppColors.textPrimary.withOpacity(
                                      0.1,
                                    ),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Name
                Text(
                  widget.student.fullName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppFonts.heading(
                    fontSize: 28,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 30),
                // Info Grid
                Row(
                  children: [
                    _buildInfoBox(
                      'ATHLETE ID',
                      'GJ${widget.student.id.toString().padLeft(3, '0')}',
                    ),
                    const SizedBox(width: 10),
                    _buildInfoBox(
                      'GENDER',
                      widget.student.gender.toUpperCase(),
                    ),
                    const SizedBox(width: 10),
                    _buildInfoBox('DOB', widget.student.dob.split('-').first),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoBox('WEIGHT', '${widget.student.weight} KG'),
                    const SizedBox(width: 10),
                    _buildInfoBox('HEIGHT', '${widget.student.height} CM'),
                    const SizedBox(width: 10),
                    _buildInfoBox(
                      'Physical Index',
                      widget.student.physicalIndex.toString(),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ), // Spacing before the footer accent line
              ],
            ),
          ),
          // Bottom Accent Strip
          Positioned(
            bottom: 54,
            left: 0,
            right: 0,
            child: Container(height: 3, color: AppColors.primaryAccent),
          ),
          // Bottom Footer Strip
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '',
                    style: AppFonts.main(
                      fontSize: 10,
                      color: AppColors.textPrimary.withOpacity(0.4),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  _buildActiveBadge(widget.student.applicationStatus),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      width: double.infinity,
      height: 670,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.darkBg, AppColors.deepAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ATHLETE PROFILE',
                      style: AppFonts.main(
                        fontSize: 10,
                        color: AppColors.secondaryAccent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'GJ${widget.student.id.toString().padLeft(3, '0')}',
                        style: AppFonts.main(
                          fontSize: 10,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.student.fullName.toUpperCase(),
                  style: AppFonts.heading(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 01 / IDENTITY
                    _buildDataSection('PERSONAL DETAILS', [
                      _buildDataItem(
                        Icons.person_outline_rounded,
                        'FULL NAME',
                        widget.student.fullName,
                      ),
                      _buildDataItem(
                        Icons.wc_rounded,
                        'GENDER',
                        widget.student.gender,
                      ),
                      _buildDataItem(
                        Icons.cake_outlined,
                        'DATE OF BIRTH',
                        _formatDate(widget.student.dob),
                      ),
                      _buildDataItem(
                        Icons.calendar_today_rounded,
                        'AGE',
                        widget.student.age > 0
                            ? '${widget.student.age} Years'
                            : '',
                      ),
                      _buildDataItem(
                        Icons.fingerprint_rounded,
                        'AADHAR NUMBER',
                        widget.student.aadharNumber,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // 02 / REACH
                    _buildDataSection('CONTACT INFORMATION', [
                      _buildDataItem(
                        Icons.email_outlined,
                        'EMAIL ADDRESS',
                        widget.student.email.toLowerCase(),
                      ),
                      _buildDataItem(
                        Icons.phone_iphone_rounded,
                        'MOBILE NUMBER',
                        widget.student.contactNumber,
                      ),
                      _buildDataItem(
                        Icons.emergency_outlined,
                        'EMERGENCY CONTACT',
                        widget.student.emergencyContact,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // 03 / FAMILY
                    _buildDataSection('PARENT & GUARDIAN', [
                      _buildDataItem(
                        Icons.man_rounded,
                        "FATHER'S NAME",
                        widget.student.fatherName,
                      ),
                      _buildDataItem(
                        Icons.woman_rounded,
                        "MOTHER'S NAME",
                        widget.student.motherName,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // 04 / LOCATION
                    _buildDataSection('ADDRESS DETAILS', [
                      _buildDataItem(
                        Icons.home_rounded,
                        'ADDRESS',
                        widget.student.address,
                      ),
                      _buildDataItem(
                        Icons.location_city_rounded,
                        'CITY',
                        widget.student.city,
                      ),
                      _buildDataItem(
                        Icons.map_rounded,
                        'DISTRICT',
                        widget.student.district,
                      ),
                      _buildDataItem(
                        Icons.explore_rounded,
                        'STATE',
                        widget.student.state,
                      ),
                      _buildDataItem(
                        Icons.public_rounded,
                        'COUNTRY',
                        widget.student.country,
                      ),
                      _buildDataItem(
                        Icons.pin_drop_rounded,
                        'PINCODE',
                        widget.student.pincode,
                      ),
                    ]),
                    const SizedBox(height: 24),
                    // 05 / AFFILIATION
                    _buildDataSection('OTHER DETAILS', [
                      _buildDataItem(
                        Icons.groups_rounded,
                        'CLUB AFFILIATION',
                        widget.student.clubAffiliation,
                      ),
                      _buildDataItem(
                        Icons.verified_user_rounded,
                        'MEMBER SINCE',
                        _formatDate(widget.student.sopApprovalDate),
                      ),
                    ]),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Center(
              child: Text(
                'TAP TO FLIP BACK',
                style: AppFonts.main(
                  fontSize: 10,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      if (dateStr.contains(' ')) {
        return dateStr.split(' ').first;
      }
      if (dateStr.contains('T')) {
        return dateStr.split('T').first;
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildActiveBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: AppFonts.main(
              fontSize: 10,
              color: AppColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textPrimary.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.main(
                fontSize: 8,
                color: AppColors.textSecondary.withOpacity(0.6),
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppFonts.heading(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSection(String title, List<Widget> items) {
    final validItems = items.where((item) => item is! SizedBox).toList();
    if (validItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 14, color: AppColors.primaryAccent),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppFonts.main(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Divider(thickness: 1)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.surfaceDark),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: validItems),
        ),
      ],
    );
  }

  Widget _buildDataItem(IconData icon, String label, String value) {
    if (value.trim().isEmpty || value.trim().toLowerCase() == 'null') {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryAccent.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.deepAccent.withOpacity(0.8),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.main(
                    fontSize: 10,
                    color: AppColors.textGrey.withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.heading(
                    fontSize: 16,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 15.0;
    for (double i = 0; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
