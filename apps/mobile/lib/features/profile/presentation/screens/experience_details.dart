import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/profile_pins_manager.dart';

class ExperienceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? experienceData;
  final ProfilePinItem? pinItem;

  const ExperienceDetailsScreen({
    super.key,
    this.experienceData,
    this.pinItem,
  });

  @override
  State<ExperienceDetailsScreen> createState() => _ExperienceDetailsScreenState();
}

class _ExperienceDetailsScreenState extends State<ExperienceDetailsScreen> {
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _isPinned = widget.pinItem?.isPinned ?? (widget.experienceData?['isPinned'] == true);
    ProfilePinsManager.pinsChangeNotifier.addListener(_onPinsChanged);
  }

  @override
  void dispose() {
    ProfilePinsManager.pinsChangeNotifier.removeListener(_onPinsChanged);
    super.dispose();
  }

  void _onPinsChanged() {
    final id = widget.pinItem?.id ?? widget.experienceData?['id']?.toString();
    if (id != null) {
      final updatedPinned = ProfilePinsManager.isPinned(id);
      if (mounted && updatedPinned != _isPinned) {
        setState(() {
          _isPinned = updatedPinned;
        });
      }
    }
  }

  void _togglePin() {
    final id = widget.pinItem?.id ?? widget.experienceData?['id']?.toString();
    if (id == null) return;

    final targetVal = !_isPinned;
    if (targetVal && ProfilePinsManager.pinnedCount >= ProfilePinsManager.maxPinsAllowed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 pinned items allowed. Unpin an item first.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    final success = ProfilePinsManager.setPin(id, targetVal);
    if (success) {
      setState(() {
        _isPinned = targetVal;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(targetVal ? 'Pinned to your profile!' : 'Unpinned from profile.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFFBFBFA);
    const textColor = Color(0xFF1E1E1E);
    const secondaryTextColor = Color(0xFF475569);

    final data = widget.experienceData ?? {};
    final item = widget.pinItem;

    final title = item?.title ?? data['title']?.toString() ?? 'Software Engineer Intern';
    final company = item?.organization ?? data['company']?.toString() ?? data['organization']?.toString() ?? 'Quantaforze Corp';
    final duration = item?.duration ?? data['duration']?.toString() ?? 'Jan 2024 – Present';
    final location = item?.location ?? data['location']?.toString() ?? 'Bengaluru, Karnataka (Remote)';
    final description = item?.description ?? data['description']?.toString() ??
        'Developing enterprise cloud APIs, microservice integrations, and user-facing mobile interfaces with Flutter and Kotlin.';
    final highlight = item?.highlight ?? data['highlight']?.toString();
    final tags = item?.tags ??
        (data['tags'] is List ? List<String>.from(data['tags']) : ['Spring Boot', 'Flutter', 'Docker', 'PostgreSQL']);
    final statusLabel = item?.statusLabel ?? data['statusLabel']?.toString() ?? 'Active Work';
    final logoAsset = item?.imageAsset ?? data['logo']?.toString() ?? data['logoAsset']?.toString() ?? data['imageAsset']?.toString();

    final isCurrent = duration.toLowerCase().contains('present');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: bgColor,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                // 1. Header Card (Logo, Role, Company, Badges)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company Logo Container
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: logoAsset != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                logoAsset,
                                width: 44,
                                height: 44,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.business_center_rounded,
                                  size: 28,
                                  color: Color(0xFF0F4C81),
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.business_center_rounded,
                              size: 28,
                              color: Color(0xFF0F4C81),
                            ),
                    ),
                    const SizedBox(width: 14),

                    // Title, Company, Status Badges
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -0.4,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            company,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F4C81),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Badges Row
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildStatusBadge(statusLabel, isCurrent),
                              _buildPillBadge(location.toLowerCase().contains('remote') ? 'REMOTE' : 'ON-SITE'),
                              if (isCurrent) _buildPillBadge('PRESENT'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Timeline & Location Metadata Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          duration,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Highlight / Key Impact Card (if present)
                if (highlight != null && highlight.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.diamond_rounded, size: 20, color: Color(0xFF0284C7)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Key Achievement & Impact',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0369A1),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                highlight,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // 4. Role Overview & Description
                const Text(
                  'Role Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14.5,
                    height: 1.55,
                    color: secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Technologies & Core Competencies
                if (tags.isNotEmpty) ...[
                  const Text(
                    'Technologies & Core Competencies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.01),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('#', style: TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.bold)),
                            const SizedBox(width: 2),
                            Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                ],

                // 6. Organization Snapshot Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.corporate_fare_rounded, size: 20, color: Color(0xFF0F4C81)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              company,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'VERIFIED',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildSummaryRow('Employment Type:', isCurrent ? 'Active Internship / Employment' : 'Completed Term'),
                      const Divider(color: Color(0xFFF1F5F9), height: 20),
                      _buildSummaryRow('Location:', location),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, bool isActive) {
    final bgColor = isActive ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final fgColor = isActive ? const Color(0xFF15803D) : const Color(0xFF475569);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              color: fgColor,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
        ),
      ],
    );
  }
}
