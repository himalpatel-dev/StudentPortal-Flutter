import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stradia_ace/models/student.dart';
import 'package:stradia_ace/providers/student_provider.dart';
import 'package:stradia_ace/providers/auth_provider.dart';
import 'package:stradia_ace/screens/login_screen.dart';
import 'package:stradia_ace/screens/registration_screen.dart';
import 'package:stradia_ace/utils/app_colors.dart';
import 'package:stradia_ace/utils/app_fonts.dart';

class ProfileTab extends StatelessWidget {
  final Student student;

  const ProfileTab({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double scaleFactor = (screenWidth / 375.0).clamp(0.8, 1.2);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<StudentProvider>(
            context,
            listen: false,
          ).fetchStudentDetails();
        },
        color: AppColors.deepAccent,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildPremiumHeader(context, scaleFactor),

              // Main Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * scaleFactor),
                child: Column(
                  children: [
                    SizedBox(height: 48 * scaleFactor),

                    // 01 / IDENTITY
                    _buildContentSection('PERSONAL DETAILS', [
                      _buildDetailRow(
                        Icons.person_outline_rounded,
                        'FULL NAME',
                        student.fullName,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.wc_rounded,
                        'GENDER',
                        student.gender,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.cake_outlined,
                        'DATE OF BIRTH',
                        _formatDate(student.dob),
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'AGE',
                        student.age > 0 ? '${student.age} Years' : '',
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.fingerprint_rounded,
                        'AADHAR NUMBER',
                        student.aadharNumber,
                        scaleFactor,
                      ),
                    ], scaleFactor),

                    // 02 / REACH
                    _buildContentSection('CONTACT INFORMATION', [
                      _buildDetailRow(
                        Icons.email_outlined,
                        'EMAIL ADDRESS',
                        student.email.toLowerCase(),
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.phone_iphone_rounded,
                        'MOBILE NUMBER',
                        student.contactNumber,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.emergency_outlined,
                        'EMERGENCY CONTACT',
                        student.emergencyContact,
                        scaleFactor,
                      ),
                    ], scaleFactor),

                    // 03 / FAMILY
                    _buildContentSection('PARENT & GUARDIAN', [
                      _buildDetailRow(
                        Icons.man_rounded,
                        "FATHER'S NAME",
                        student.fatherName,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.woman_rounded,
                        "MOTHER'S NAME",
                        student.motherName,
                        scaleFactor,
                      ),
                    ], scaleFactor),

                    // 04 / LOCATION
                    _buildContentSection('ADDRESS DETAILS', [
                      _buildDetailRow(
                        Icons.home_rounded,
                        'ADDRESS',
                        student.address,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.location_city_rounded,
                        'CITY',
                        student.city,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.map_rounded,
                        'DISTRICT',
                        student.district,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.explore_rounded,
                        'STATE',
                        student.state,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.public_rounded,
                        'COUNTRY',
                        student.country,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.pin_drop_rounded,
                        'PINCODE',
                        student.pincode,
                        scaleFactor,
                      ),
                    ], scaleFactor),

                    // 05 / AFFILIATION
                    _buildContentSection('OTHER DETAILS', [
                      _buildDetailRow(
                        Icons.groups_rounded,
                        'CLUB AFFILIATION',
                        student.clubAffiliation,
                        scaleFactor,
                      ),
                      _buildDetailRow(
                        Icons.verified_user_rounded,
                        'MEMBER SINCE',
                        _formatDate(student.sopApprovalDate),
                        scaleFactor,
                      ),
                    ], scaleFactor),

                    SizedBox(height: 48 * scaleFactor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(
    String label,
    List<Widget?> rows,
    double scaleFactor,
  ) {
    final validRows = rows.whereType<Widget>().toList();
    if (validRows.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        _buildSectionTitle(label, scaleFactor),
        _buildInfoCard(validRows, scaleFactor),
        SizedBox(height: 24 * scaleFactor),
      ],
    );
  }

  Widget _buildPremiumHeader(BuildContext context, double scaleFactor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dark Gradient Background
        Container(
          width: double.infinity,
          height: 380 * scaleFactor,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.darkBg, AppColors.deepAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20 * scaleFactor,
                10,
                20 * scaleFactor,
                0,
              ),
              child: Column(
                children: [
                  // App Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors
                                  .primaryAccent, // Fixed: use primary color
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ATHLETE PROFILE',
                            style: AppFonts.main(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrationScreen(student: student),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.edit_note_rounded,
                                color: AppColors.textPrimary.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          InkWell(
                            onTap: () {
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).logout();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.textPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: AppColors.textPrimary.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scaleFactor),
                  // Profile Image
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryAccent.withOpacity(0.3),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryAccent.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: student.studentProfileImage.isNotEmpty
                              ? Image.network(
                                  student.studentProfileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppColors.textPrimary
                                            .withOpacity(0.24),
                                      ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppColors.textPrimary.withOpacity(
                                    0.24,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scaleFactor),
                  // Name
                  Text(
                    student.fullName.toUpperCase(),
                    style: AppFonts.main(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 12 * scaleFactor),
                  // Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID - ${student.uuid}',
                          style: AppFonts.main(
                            color: AppColors.textPrimary.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusBadge(student.applicationStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Overlapping Stat Bar
        Positioned(
          bottom: -25 * scaleFactor,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                Icons.straighten_rounded,
                'HEIGHT',
                student.height,
                'CM',
                scaleFactor,
              ),
              _buildStatCard(
                Icons.monitor_weight_outlined,
                'WEIGHT',
                student.weight,
                'KG',
                scaleFactor,
              ),
              _buildStatCard(
                Icons.analytics_outlined,
                'INDEX',
                student.physicalIndex,
                '',
                scaleFactor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    String unit,
    double scaleFactor,
  ) {
    if (value.isEmpty ||
        value.toLowerCase() == 'n/a' ||
        value.toLowerCase() == 'null' ||
        value.toLowerCase() == 'undefined') {
      return const SizedBox.shrink();
    }

    return Container(
      width: 105 * scaleFactor,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBg.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.deepAccent),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppFonts.main(
                  color: AppColors.deepAccent,
                  fontSize: 9 * scaleFactor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppFonts.main(
                color: AppColors.darkBg,
                fontSize: 20 * scaleFactor,
                fontWeight: FontWeight.w900,
              ),
              children: [
                TextSpan(text: value),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: 10 * scaleFactor,
                      color: AppColors.deepAccent,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String label, double scaleFactor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppFonts.main(
                color: AppColors.deepAccent.withOpacity(0.75),
                fontSize: 12 * scaleFactor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            Expanded(
              child: Container(
                height: 1,
                color: AppColors.darkBg.withOpacity(0.35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget?> children, double scaleFactor) {
    // Filter out null widgets (from empty values)
    final validChildren = children.whereType<Widget>().toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.textPrimary,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.darkBg.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBg.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: validChildren.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx < validChildren.length - 1)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60 * scaleFactor),
                  child: Divider(
                    color: AppColors.darkBg.withOpacity(0.05),
                    height: 1,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget? _buildDetailRow(
    IconData icon,
    String label,
    String value,
    double scaleFactor,
  ) {
    // Hide if value is empty or null-like
    if (value.isEmpty ||
        value.toLowerCase() == 'n/a' ||
        value.toLowerCase() == 'null' ||
        value.toLowerCase() == 'undefined') {
      return null;
    }

    return Padding(
      padding: EdgeInsets.all(16 * scaleFactor),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.darkBg.withOpacity(0.03)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkBg.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, size: 20, color: AppColors.secondaryAccent),
          ),
          SizedBox(width: 16 * scaleFactor),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.main(
                    color: AppColors.textGrey.withOpacity(0.8),
                    fontSize: 10 * scaleFactor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppFonts.main(
                    color: AppColors.textDark,
                    fontSize: 15 * scaleFactor,
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

  String _formatDate(String dateString) {
    if (dateString.isEmpty ||
        dateString.toLowerCase() == 'n/a' ||
        dateString.toLowerCase() == 'null' ||
        dateString.toLowerCase() == 'undefined') {
      return '';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    final normalizedStatus = status.toUpperCase();

    if (normalizedStatus == 'APPROVED') {
      statusColor = AppColors.success;
    } else if (normalizedStatus == 'REJECTED') {
      statusColor = AppColors.error;
    } else {
      statusColor = const Color(0xFFF59E0B); // Amber/Yellow
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            normalizedStatus == 'APPROVED'
                ? Icons.verified_rounded
                : normalizedStatus == 'REJECTED'
                ? Icons.cancel_rounded
                : Icons.pending_rounded,
            color: statusColor,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: AppFonts.main(
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
