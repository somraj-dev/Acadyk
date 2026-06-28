import 'package:flutter/material.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0D1117);
    const textColor = Color(0xFFC9D1D9);
    const titleColor = Colors.white;
    const dividerColor = Color(0xFF30363D);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: textColor),
        title: const Text('Appearance', style: TextStyle(color: titleColor)),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: dividerColor, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Theme preferences',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: titleColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose how Acadyk looks to you. Select a single theme, or sync with your system and automatically switch between day and night themes. Selections are applied immediately and saved automatically.',
            style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text('Theme mode', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Sync with system', style: TextStyle(color: textColor, fontSize: 13)),
                    SizedBox(width: 8),
                    Icon(Icons.unfold_more, color: textColor, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('Acadyk theme will match your system active settings', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Light theme card
          _buildThemeCard(
            title: 'Light theme',
            icon: Icons.wb_sunny_outlined,
            description: 'This theme will be active when your system is set to "light mode"',
            isDark: false,
          ),
          const SizedBox(height: 24),

          // Dark theme card
          _buildThemeCard(
            title: 'Dark theme',
            icon: Icons.nightlight_round_outlined,
            description: 'This theme will be active when your system is set to "dark mode"',
            isDark: true,
            isActive: true, // Example showing Active badge
          ),

          const SizedBox(height: 32),
          const Divider(color: dividerColor),
          const SizedBox(height: 24),

          // Contrast
          const Text('Contrast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(height: 16),
          _buildContrastSettings(),

          const SizedBox(height: 32),
          const Divider(color: dividerColor),
          const SizedBox(height: 24),

          // Emoji skin tone preference
          const Text('Emoji skin tone preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(height: 8),
          const Text('Preferred default emoji skin tone', style: TextStyle(color: textColor, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 0,
            runSpacing: 12,
            children: [
              _buildEmojiOption('👋', isSelected: true),
              _buildEmojiOption('👋🏻'),
              _buildEmojiOption('👋🏼'),
              _buildEmojiOption('👋🏽'),
              _buildEmojiOption('👋🏾'),
              _buildEmojiOption('👋🏿'),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(color: dividerColor),
          const SizedBox(height: 24),

          // Tab size preference
          const Text('Tab size preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(height: 8),
          const Text('Choose the number of spaces a tab is equal to when rendering code', style: TextStyle(color: textColor, fontSize: 13)),
          const SizedBox(height: 12),
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21262D),
              border: Border.all(color: dividerColor),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('4 (Default)', style: TextStyle(color: textColor, fontSize: 13)),
                Icon(Icons.unfold_more, color: textColor, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const Divider(color: dividerColor),
          const SizedBox(height: 24),

          // Markdown editor font preference
          const Text('Markdown editor font preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
          const SizedBox(height: 8),
          const Text('Font preference for plain text editors that support Markdown styling (e.g. pull request and issue descriptions, comments.)', style: TextStyle(color: textColor, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.check_box_outline_blank, color: Color(0xFF8B949E), size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Use a fixed-width (monospace) font when editing Markdown', style: TextStyle(color: textColor, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required IconData icon,
    required String description,
    required bool isDark,
    bool isActive = false,
  }) {
    const borderColor = Color(0xFF30363D);
    final cardBgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final mockUiHeaderColor = isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    final mockUiBodyColor = isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA);
    final textGrey = isDark ? const Color(0xFF8B949E) : const Color(0xFF57606A);

    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: isActive ? const Color(0xFF58A6FF) : borderColor, width: isActive ? 2 : 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor)),
              color: isDark ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, color: textGrey, size: 16),
                    const SizedBox(width: 8),
                    Text(title, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1F6FEB)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Active', style: TextStyle(color: Color(0xFF58A6FF), fontSize: 12, fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: TextStyle(color: textGrey, fontSize: 12)),
                const SizedBox(height: 16),
                // Wireframe Mock UI
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(6),
                    color: mockUiHeaderColor,
                  ),
                  child: Column(
                    children: [
                      // Header part
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Container(width: 40, height: 12, decoration: BoxDecoration(color: textGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(6))),
                            const SizedBox(width: 16),
                            Container(width: 40, height: 12, decoration: BoxDecoration(color: textGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(6))),
                            const SizedBox(width: 16),
                            Container(width: 40, height: 12, decoration: BoxDecoration(color: textGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(6))),
                          ],
                        ),
                      ),
                      // Body part
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: mockUiBodyColor,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(width: 80, height: 10, decoration: BoxDecoration(color: textGrey.withOpacity(0.3), borderRadius: BorderRadius.circular(5))),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF21262D) : Colors.white,
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Container(width: 60, height: 8, decoration: BoxDecoration(color: const Color(0xFF238636), borderRadius: BorderRadius.circular(4))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF238636), borderRadius: BorderRadius.circular(2))),
                                        const SizedBox(width: 4),
                                        Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFFDA3633), borderRadius: BorderRadius.circular(2))),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF21262D) : Colors.white,
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(6),
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
                Text(isDark ? 'Dark default' : 'Light default', style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          // Footer color circles
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildThemeCircle(Colors.white, Colors.white, isSelected: !isDark),
                _buildThemeCircle(Colors.white, const Color(0xFFE3B341)),
                _buildThemeCircle(Colors.white, const Color(0xFFD73A49)),
                _buildThemeCircle(const Color(0xFF0D1117), const Color(0xFF0D1117), isSelected: isDark),
                _buildThemeCircle(const Color(0xFF0D1117), const Color(0xFFE3B341)),
                _buildThemeCircle(const Color(0xFF0D1117), const Color(0xFFD73A49)),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(color: Color(0xFF30363D), shape: BoxShape.circle),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCircle(Color leftColor, Color rightColor, {bool isSelected = false}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF30363D), width: isSelected ? 2 : 1),
      ),
      child: ClipOval(
        child: Row(
          children: [
            Expanded(child: Container(color: leftColor)),
            Expanded(child: Container(color: rightColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildContrastSettings() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF30363D)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _buildContrastRow('Increase contrast', 'Enable high contrast for light or dark mode (or both) based on your system settings', true),
          const Divider(height: 1, color: Color(0xFF30363D)),
          _buildContrastRow('Light mode', null, false),
          const Divider(height: 1, color: Color(0xFF30363D)),
          _buildContrastRow('Dark mode', null, false),
        ],
      ),
    );
  }

  Widget _buildContrastRow(String title, String? subtitle, bool isFirst) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                ],
              ],
            ),
          ),
          Row(
            children: [
              const Text('Off', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B949E),
                      shape: BoxShape.circle,
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

  Widget _buildEmojiOption(String emoji, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF8B949E), width: isSelected ? 4 : 1),
            ),
          ),
          const SizedBox(width: 6),
          Text(emoji, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
