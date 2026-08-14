import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'event_detail_screen.dart';
import 'filter_events_bottom_sheet.dart';
import '../services/opportunities_manager.dart';
import 'home_feed_screen.dart';

class DiscoverOpportunitiesScreen extends StatefulWidget {
  const DiscoverOpportunitiesScreen({super.key});

  @override
  State<DiscoverOpportunitiesScreen> createState() => _DiscoverOpportunitiesScreenState();
}

class _DiscoverOpportunitiesScreenState extends State<DiscoverOpportunitiesScreen> {
  // Opportunities now resolved dynamically from OpportunitiesManager
  FilterSettings _filterSettings = FilterSettings(
    eventType: 'Hackathon',
    participationType: 'Individual',
    topics: {'AI / ML', 'Sustainability'},
  );

  bool _isFilterApplied = false; // Show all by default until user applies filter

  final Set<int> _savedIndices = {};
  final Set<int> _likedIndices = {};

  @override
  void initState() {
    super.initState();
    OpportunitiesManager.loadFromBackend();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final textColor = theme.colorScheme.onSurface;

    return Container(
      color: scaffoldBg,
      child: Column(
        children: [
          // Screen Title / Search Header
          Container(
            color: cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                const Text(
                  'Discover Opportunities',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final result = await showModalBottomSheet<FilterSettings>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FilterEventsBottomSheet(initialSettings: _filterSettings),
                    );
                    if (result != null) {
                      setState(() {
                        _filterSettings = result;
                        _isFilterApplied = true; // Set to true since filters were explicitly applied
                      });
                    }
                  },
                  child: const Icon(Icons.tune_outlined, color: Color(0xFF4B5563), size: 24),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // List of Opportunities
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: OpportunitiesManager.opportunitiesNotifier,
              builder: (context, currentOps, child) {
                // Apply filters in real time only if the user explicitly clicked Apply Filters
                final filteredOps = !_isFilterApplied ? currentOps : currentOps.where((op) {
                  // 1. Event Type filter
                  if (_filterSettings.eventType != null) {
                    final filterType = _filterSettings.eventType!.toLowerCase();
                    final title = op['title'].toString().toLowerCase();
                    final tags = (op['tags'] as List).map((t) => t.toString().toLowerCase()).toList();
                    
                    if (filterType == 'hackathon') {
                      if (!title.contains('hackathon') && !tags.contains('hackathon') && !title.contains('sprint') && !title.contains('challenge')) {
                        return false;
                      }
                    } else if (filterType == 'workshop') {
                      if (!title.contains('workshop') && !tags.contains('workshop') && !title.contains('bootcamp') && !tags.contains('workshop')) {
                        return false;
                      }
                    } else if (filterType == 'conference') {
                      if (!title.contains('conference') && !tags.contains('conference') && !title.contains('summit') && !tags.contains('conference')) {
                        return false;
                      }
                    } else if (filterType == 'meetup') {
                      if (!title.contains('meetup') && !tags.contains('meetup') && !title.contains('session')) {
                        return false;
                      }
                    } else {
                      // Other
                      if (title.contains('hackathon') || title.contains('workshop') || title.contains('conference') || title.contains('summit')) {
                        return false;
                      }
                    }
                  }

                  // 2. Participation Type filter
                  if (_filterSettings.participationType != null) {
                    final pType = _filterSettings.participationType!.toLowerCase();
                    final teamText = op['teamSizeText'].toString().toLowerCase();
                    if (pType == 'individual') {
                      if (!teamText.contains('individual') && !teamText.contains('solo') && !teamText.contains('1 member')) {
                        return false;
                      }
                    } else if (pType == 'team') {
                      if (!teamText.contains('member') && !teamText.contains('team') && !teamText.contains('members')) {
                        return false;
                      }
                    }
                  }

                  // 3. Prize Pool filter
                  if (_filterSettings.prizePool != 'All') {
                    final pool = op['prizePool'].toString().toLowerCase();
                    if (_filterSettings.prizePool == '<\$1K') {
                      if (pool.contains('₹') || pool.contains('25,000') || pool.contains('50,000')) {
                        return false;
                      }
                    } else if (_filterSettings.prizePool == '\$1K - \$5K') {
                      if (!pool.contains('25,000') && !pool.contains('3,25,000')) {
                        return false;
                      }
                    } else if (_filterSettings.prizePool == '\$5K - \$10K') {
                      if (!pool.contains('10,000')) {
                        return false;
                      }
                    } else if (_filterSettings.prizePool == '\$10K+') {
                      if (!pool.contains('25,000') && !pool.contains('50,000')) {
                        return false;
                      }
                    }
                  }

                  // 4. Format filter
                  if (_filterSettings.format != null) {
                    final format = _filterSettings.format!.toLowerCase();
                    final location = op['location'].toString().toLowerCase();
                    final tags = (op['tags'] as List).map((t) => t.toString().toLowerCase()).toList();
                    if (!location.contains(format) && !tags.contains(format)) {
                      return false;
                    }
                  }

                  // 5. Topics filter
                  if (_filterSettings.topics.isNotEmpty) {
                    bool matchesTopic = false;
                    final title = op['title'].toString().toLowerCase();
                    final tagline = op['tagline'].toString().toLowerCase();
                    final tags = (op['tags'] as List).map((t) => t.toString().toLowerCase()).toList();
                    
                    for (var topic in _filterSettings.topics) {
                      final t = topic.toLowerCase();
                      if (t == 'ai / ml' && (title.contains('ai') || title.contains('ml') || title.contains('artificial') || tagline.contains('generative') || tags.contains('generative') || tags.contains('ai'))) {
                        matchesTopic = true;
                        break;
                      }
                      if (t == 'sustainability' && (title.contains('green') || title.contains('eco') || title.contains('sustain') || tagline.contains('climate') || tags.contains('sustainability') || tags.contains('green'))) {
                        matchesTopic = true;
                        break;
                      }
                      if (t == 'web development' && (title.contains('web') || tagline.contains('web') || tagline.contains('dapp') || tags.contains('web3') || tags.contains('web'))) {
                        matchesTopic = true;
                        break;
                      }
                      if (t == 'blockchain' && (title.contains('block') || tagline.contains('block') || tagline.contains('web3') || tags.contains('blockchain') || tags.contains('web3'))) {
                        matchesTopic = true;
                        break;
                      }
                      if (title.contains(t) || tagline.contains(t) || tags.contains(t)) {
                        matchesTopic = true;
                        break;
                      }
                    }
                    if (!matchesTopic) {
                      return false;
                    }
                  }

                  return true;
                }).toList();

                if (filteredOps.isEmpty) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(32),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off, color: Colors.grey.shade400, size: 64),
                        const SizedBox(height: 16),
                        const Text(
                          'No matching opportunities found',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try resetting or adjusting your filter criteria to get better recommendations.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _filterSettings = FilterSettings(topics: {});
                              _isFilterApplied = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F4C81),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('Reset Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: filteredOps.length,
                  itemBuilder: (context, index) {
                    final op = filteredOps[index];
                    return _buildOpportunityCard(op, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(Map<String, dynamic> op, int index) {
    final bool isLiked = _likedIndices.contains(index);
    final bool isSaved = _savedIndices.contains(index);

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header: Avatar + Title + Badge + More Vert
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF3B82F6),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: ClipOval(
                  child: Image.network(
                    op['logoUrl'] ?? '',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF3B82F6),
                        alignment: Alignment.center,
                        child: Text(
                          (op['organizer'] ?? op['title'] ?? 'D')[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            op['title']!,
                            style: const TextStyle(
                              color: Color(0xFF111827),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, color: Colors.blue, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${op['timeAgo']} • Event',
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Color(0xFF4B5563)),
                onPressed: () {
                  _showOpportunityOptionsBottomSheet(context, op['title']!, op['organizer']!);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. Tagline / Description text
          Text(
            op['tagline']!,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 14.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // 3. Card Banner Image + Translucent Overlay Box
          GestureDetector(
            onDoubleTap: () {
              setState(() {
                if (isLiked) {
                  _likedIndices.remove(index);
                } else {
                  _likedIndices.add(index);
                }
              });
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    op['bannerUrl']!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, err, stack) {
                      return Container(
                        height: 180,
                        color: Colors.grey.shade100,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      );
                    },
                  ),
                ),
                // Glass/translucent Overlay at the bottom
                Positioned(
                  bottom: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Date Info
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.calendar, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  op['dates']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Location Info
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.location, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  op['location']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Team Info
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(CupertinoIcons.group, color: Colors.white, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  op['teamSizeText']!,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 4. Tags Flow Box
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (op['tags'] as List<String>).map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.w500),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 5. Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // 6. Prizes Row + Register Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.emoji_events, color: Colors.green, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prize Pool',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      ),
                      Text(
                        op['prizePool']!,
                        style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(eventData: op['event']),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1F22),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 6),
                    Icon(Icons.north_east, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7. Social Reaction details bottom bar
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      _likedIndices.remove(index);
                    } else {
                      _likedIndices.add(index);
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                      color: isLiked ? Colors.red : const Color(0xFF4B5563),
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isLiked ? op['likes'] + 1 : op['likes']}',
                      style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  const Icon(CupertinoIcons.chat_bubble, color: Color(0xFF4B5563), size: 24),
                  const SizedBox(width: 6),
                  Text(
                    '${op['comments']}',
                    style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSaved) {
                      _savedIndices.remove(index);
                    } else {
                      _savedIndices.add(index);
                    }
                  });
                },
                child: Icon(
                  isSaved ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
                  color: isSaved ? Colors.blue : const Color(0xFF4B5563),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showOpportunityOptionsBottomSheet(BuildContext context, String title, String company) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopActionIcon(
                      CupertinoIcons.bookmark,
                      'Save',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.repeat,
                      'Repost',
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    _buildTopActionIcon(
                      CupertinoIcons.paperplane,
                      'Share',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SharePostScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      _buildListAction(CupertinoIcons.eye_slash, 'Hide', onTap: () {
                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.person, 'About this account', onTap: () {
                        Navigator.pop(context);
                      }),
                      const SizedBox(height: 20),
                      _buildListAction(CupertinoIcons.exclamationmark_bubble, 'Report', color: const Color(0xFFED4956), onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReportPostScreen(),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopActionIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F2EF),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: Colors.black87, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF5E5E5E), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildListAction(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, color: color ?? const Color(0xFF5E5E5E), size: 22),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? const Color(0xFF191919),
            ),
          ),
        ],
      ),
    );
  }
}
