import 'package:flutter/material.dart';

class FilterSettings {
  final String? eventType;
  final String? participationType;
  final String prizePool;
  final String? format;
  final Set<String> topics;

  FilterSettings({
    this.eventType = 'Hackathon',
    this.participationType = 'Individual',
    this.prizePool = 'All',
    this.format,
    required this.topics,
  });

  FilterSettings copyWith({
    String? Function()? eventType,
    String? Function()? participationType,
    String? prizePool,
    String? Function()? format,
    Set<String>? topics,
  }) {
    return FilterSettings(
      eventType: eventType != null ? eventType() : this.eventType,
      participationType: participationType != null ? participationType() : this.participationType,
      prizePool: prizePool ?? this.prizePool,
      format: format != null ? format() : this.format,
      topics: topics ?? this.topics,
    );
  }
}

class FilterEventsBottomSheet extends StatefulWidget {
  final FilterSettings initialSettings;

  const FilterEventsBottomSheet({
    super.key,
    required this.initialSettings,
  });

  @override
  State<FilterEventsBottomSheet> createState() => _FilterEventsBottomSheetState();
}

class _FilterEventsBottomSheetState extends State<FilterEventsBottomSheet> {
  late String? _selectedEventType;
  late String? _selectedParticipation;
  late String _selectedPrizePool;
  late String? _selectedFormat;
  late Set<String> _selectedTopics;
  bool _showProTip = true;

  @override
  void initState() {
    super.initState();
    _selectedEventType = widget.initialSettings.eventType;
    _selectedParticipation = widget.initialSettings.participationType;
    _selectedPrizePool = widget.initialSettings.prizePool;
    _selectedFormat = widget.initialSettings.format;
    _selectedTopics = Set<String>.from(widget.initialSettings.topics);
  }

  int _calculateActiveFiltersCount() {
    int count = 0;
    if (_selectedEventType != null) count++;
    if (_selectedParticipation != null) count++;
    if (_selectedPrizePool != 'All') count++;
    if (_selectedFormat != null) count++;
    count += _selectedTopics.length;
    return count;
  }

  void _resetAll() {
    setState(() {
      _selectedEventType = null;
      _selectedParticipation = null;
      _selectedPrizePool = 'All';
      _selectedFormat = null;
      _selectedTopics.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF111827);
    const Color textSecondary = Color(0xFF6B7280);
    const Color borderCol = Color(0xFFE5E7EB);
    const Color greenBg = Color(0xFFECFDF5);
    const Color greenBorder = Color(0xFF10B981);
    const Color greenText = Color(0xFF065F46);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: 8,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter Events',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find events that match your interests',
                      style: TextStyle(color: textSecondary, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: textColor, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // SCROLLABLE CONTENT BODY
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. EVENT TYPE
                  _buildSectionHeader('Event Type', onClear: () {
                    setState(() => _selectedEventType = null);
                  }),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildEventTypeOption('Hackathon', Icons.code),
                      _buildEventTypeOption('Workshop', Icons.people_outline),
                      _buildEventTypeOption('Conference', Icons.mic_none_outlined),
                      _buildEventTypeOption('Meetup', Icons.celebration_outlined),
                      _buildEventTypeOption('Other', Icons.grid_view_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. PARTICIPATION TYPE
                  _buildSectionHeader('Participation Type'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildParticipationOption(
                          'Individual',
                          'Solo participation',
                          Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildParticipationOption(
                          'Team',
                          'Group participation',
                          Icons.group_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. PRIZE POOL
                  _buildSectionHeader('Prize Pool', onClear: () {
                    setState(() => _selectedPrizePool = 'All');
                  }),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: ['All', '<\$1K', '\$1K - \$5K', '\$5K - \$10K', '\$10K+'].map((prize) {
                        final bool active = _selectedPrizePool == prize;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedPrizePool = prize),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: active ? greenBg : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? greenBorder : borderCol,
                                width: active ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              prize,
                              style: TextStyle(
                                color: active ? greenText : textColor,
                                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. DATE RANGE SELECTOR
                  _buildSectionHeader('Date'),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, color: textSecondary, size: 18),
                        SizedBox(width: 12),
                        Text(
                          'Select date range',
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          'Anytime',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. LOCATION
                  _buildSectionHeader('Location'),
                  const SizedBox(height: 10),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: textSecondary, size: 18),
                        SizedBox(width: 12),
                        Text(
                          'Location',
                          style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Spacer(),
                        Text(
                          'Any location',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: textSecondary, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. FORMAT
                  _buildSectionHeader('Format'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildFormatChip('Online', Icons.language_outlined),
                      const SizedBox(width: 8),
                      _buildFormatChip('Offline', Icons.business_outlined),
                      const SizedBox(width: 8),
                      _buildFormatChip('Hybrid', Icons.computer_outlined),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 7. TOPICS
                  _buildSectionHeader('Topics', subtitle: 'Select one or more', onClear: () {
                    setState(() => _selectedTopics.clear());
                  }),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'AI / ML',
                      'Web Development',
                      'Blockchain',
                      'IoT',
                      'FinTech',
                      'HealthTech',
                      'EdTech',
                      'Sustainability',
                      'Cybersecurity',
                      '+ More'
                    ].map((topic) {
                      final bool active = _selectedTopics.contains(topic);
                      return GestureDetector(
                        onTap: () {
                          if (topic == '+ More') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Load more technical topics.')),
                            );
                            return;
                          }
                          setState(() {
                            if (active) {
                              _selectedTopics.remove(topic);
                            } else {
                              _selectedTopics.add(topic);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? greenBg : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: active ? greenBorder : Colors.transparent,
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                topic,
                                style: TextStyle(
                                  color: active ? greenText : textColor,
                                  fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 12.5,
                                ),
                              ),
                              if (active) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.check_circle, color: greenBorder, size: 14),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 8. PRO TIP BANNER
                  if (_showProTip) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: greenBorder, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 13, color: textColor),
                                children: [
                                  TextSpan(text: 'Pro Tip  ', style: TextStyle(fontWeight: FontWeight.bold)),
                                  TextSpan(text: 'More filters = better recommendations!', style: TextStyle(color: textSecondary)),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _showProTip = false),
                            child: const Icon(Icons.close, color: textSecondary, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),

          // FOOTER: RESET & APPLY FILTERS ROW
          const Divider(height: 1, color: borderCol),
          const SizedBox(height: 12),
          Row(
            children: [
              // Reset Button
              GestureDetector(
                onTap: _resetAll,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.refresh, color: textColor, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Reset',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply Filters Button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    final settings = FilterSettings(
                      eventType: _selectedEventType,
                      participationType: _selectedParticipation,
                      prizePool: _selectedPrizePool,
                      format: _selectedFormat,
                      topics: _selectedTopics,
                    );
                    Navigator.pop(context, settings);
                  },
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F22),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Apply Filters',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(width: 10),
                        // Dynamic badge showing active filters count
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFF86EFAC),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${_calculateActiveFiltersCount()}',
                            style: const TextStyle(
                              color: Color(0xFF14532D),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget: Section Header with optional Clear button
  Widget _buildSectionHeader(String title, {String? subtitle, VoidCallback? onClear}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(color: Color(0xFF111827), fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (subtitle != null) ...[
          const SizedBox(width: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ],
        const Spacer(),
        if (onClear != null)
          GestureDetector(
            onTap: onClear,
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  // Helper Widget: Event Type card item
  Widget _buildEventTypeOption(String type, IconData icon) {
    final bool active = _selectedEventType == type;
    const Color borderCol = Color(0xFFE5E7EB);
    const Color textSecondary = Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => setState(() => _selectedEventType = type),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF10B981) : borderCol,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: active ? const Color(0xFF065F46) : textSecondary, size: 20),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(
                    color: active ? const Color(0xFF065F46) : textSecondary,
                    fontSize: 9.5,
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (active)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
              ),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Participation option card
  Widget _buildParticipationOption(String title, String subtitle, IconData icon) {
    final bool active = _selectedParticipation == title;
    const Color borderCol = Color(0xFFE5E7EB);
    const Color textSecondary = Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => setState(() => _selectedParticipation = title),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFF10B981) : borderCol,
            width: active ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF065F46) : textSecondary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? const Color(0xFF065F46) : const Color(0xFF111827),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (active)
              const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
          ],
        ),
      ),
    );
  }

  // Helper Widget: Format chip selection
  Widget _buildFormatChip(String format, IconData icon) {
    final bool active = _selectedFormat == format;
    const Color borderCol = Color(0xFFE5E7EB);
    const Color textSecondary = Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = active ? null : format),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF10B981) : borderCol,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: active ? const Color(0xFF065F46) : textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              format,
              style: TextStyle(
                color: active ? const Color(0xFF065F46) : const Color(0xFF111827),
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
