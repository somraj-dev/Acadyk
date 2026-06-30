import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'event_detail_screen.dart';
import '../services/opportunities_manager.dart';

class DiscoverOpportunitiesScreen extends StatefulWidget {
  const DiscoverOpportunitiesScreen({super.key});

  @override
  State<DiscoverOpportunitiesScreen> createState() => _DiscoverOpportunitiesScreenState();
}

class _DiscoverOpportunitiesScreenState extends State<DiscoverOpportunitiesScreen> {
  // Opportunities now resolved dynamically from OpportunitiesManager

  final Set<int> _savedIndices = {};
  final Set<int> _likedIndices = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F2EF),
      child: Column(
        children: [
          // Screen Title / Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: const Row(
              children: [
                Text(
                  'Discover Opportunities',
                  style: TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.tune_outlined, color: Color(0xFF4B5563), size: 24),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // List of Opportunities
          Expanded(
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: OpportunitiesManager.opportunitiesNotifier,
              builder: (context, currentOps, child) {
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: currentOps.length,
                  itemBuilder: (context, index) {
                    final op = currentOps[index];
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
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFE5E7EB),
                backgroundImage: op['logoUrl'] != null ? NetworkImage(op['logoUrl']) : null,
                child: op['logoUrl'] == null ? const Icon(Icons.business, color: Color(0xFF6B7280)) : null,
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
                onPressed: () {},
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
          Stack(
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
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      // Date
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                op['dates']!,
                                style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(width: 1, height: 20, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 6)),
                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_outlined, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                op['location']!,
                                style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Divider
                      Container(width: 1, height: 20, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 6)),
                      // Team
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline, color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                op['teamSizeText']!,
                                style: const TextStyle(color: Colors.white, fontSize: 10, height: 1.2),
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
}
