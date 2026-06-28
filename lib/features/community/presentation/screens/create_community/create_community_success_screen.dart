import 'package:flutter/material.dart';
import '../community_profile_screen.dart';

class CreateCommunitySuccessScreen extends StatelessWidget {
  final String communityName;
  final String description;

  const CreateCommunitySuccessScreen({super.key, required this.communityName, required this.description});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0B141A);
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5A4D1A), // Brownish yellow
                  Color(0xFF2A2616), // Darker transition
                  Color(0xFF0B141A), // Background
                ],
              ),
            ),
          ),
          
          // Confetti dots
          Positioned(bottom: 120, right: 30, child: _buildConfettiSquare(Colors.redAccent, 12, 0.2)),
          Positioned(bottom: 200, left: 40, child: _buildConfettiSquare(Colors.orange, 8, -0.4)),
          Positioned(bottom: 40, left: 80, child: _buildConfettiSquare(Colors.greenAccent, 10, 0.5)),
          Positioned(bottom: 10, right: 10, child: _buildConfettiSquare(Colors.blueAccent, 14, -0.2)),
          Positioned(bottom: 80, right: 80, child: _buildConfettiSquare(Colors.redAccent, 12, 0.0)),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'You launched a new\ncommunity!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Community Preview Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1C), // Dark card color
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner part
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 100,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC107), // Yellow banner placeholder
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            // Simulated zigzag pattern could be added here if needed
                          ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: const Icon(Icons.edit, size: 16, color: Colors.black),
                            ),
                          ),
                          // Logo overlapping
                          Positioned(
                            left: 16,
                            bottom: -24,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.pinkAccent.shade100,
                                    child: const Icon(Icons.extension, color: Colors.pink, size: 32),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white.withOpacity(0.8),
                                    child: const Icon(Icons.edit, size: 12, color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32), // Space for overlapping logo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              communityName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '1 member',
                              style: TextStyle(
                                color: Color(0xFF8696A0),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description.isEmpty ? 'Community description goes here...' : description,
                              style: const TextStyle(
                                color: Color(0xFF8696A0),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Info Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Here's what you should know",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "We've applied some settings to help you get started. You can view and edit them anytime in your mod tools.",
                        style: TextStyle(color: Color(0xFFD3D3D3), fontSize: 14, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildCheckButton('Rules')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildCheckButton('Community Guide')),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2C),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            elevation: 0,
                          ),
                          child: const Text('View Next Steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CommunityProfileScreen(
                                  communityName: communityName,
                                  description: description,
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: const Text('Go To Community Page', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildCheckButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check, color: Colors.greenAccent, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildConfettiSquare(Color color, double size, double rotation) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: size,
        height: size,
        color: color,
      ),
    );
  }
}
