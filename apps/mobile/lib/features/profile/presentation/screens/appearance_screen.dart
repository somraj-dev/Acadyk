import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/providers/theme_provider.dart';

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider;
    try {
      themeProvider = Provider.of<ThemeProvider>(context, listen: true);
    } catch (_) {
      themeProvider = ThemeProvider();
    }

    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

        final bgColor = isDarkTheme ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA);
        final textColor = isDarkTheme ? const Color(0xFFC9D1D9) : const Color(0xFF24292F);
        final titleColor = isDarkTheme ? Colors.white : Colors.black;
        final dividerColor = isDarkTheme ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
        final cardBgColor = isDarkTheme ? const Color(0xFF161B22) : Colors.white;

        return Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            iconTheme: IconThemeData(color: textColor),
            title: Text('Appearance', style: TextStyle(color: titleColor, fontWeight: FontWeight.w600)),
            elevation: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: dividerColor, height: 1),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text(
                'Theme preferences',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: titleColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose how Acadyk looks to you. Select a single theme, or sync with your system and automatically switch between day and night themes. Selections are applied immediately and saved automatically.',
                style: TextStyle(color: textColor, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Text('Theme mode', style: TextStyle(color: titleColor, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              // Theme Mode Selector Dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: cardBgColor,
                      border: Border.all(color: dividerColor),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ThemeMode>(
                        value: themeProvider.themeMode,
                        dropdownColor: cardBgColor,
                        icon: Icon(Icons.unfold_more, color: textColor, size: 18),
                        style: TextStyle(color: textColor, fontSize: 13, fontFamily: 'Inter'),
                        onChanged: (ThemeMode? newMode) {
                          if (newMode != null) {
                            themeProvider.setThemeMode(newMode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Sync with system'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light theme'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark theme'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getThemeModeDescription(themeProvider.themeMode),
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Light Theme Card
              _buildThemeCard(
                context: context,
                themeProvider: themeProvider,
                title: 'Light theme',
                icon: Icons.wb_sunny_outlined,
                description: 'This theme will be active when your system is set to "light mode"',
                isDarkCard: false,
                isActive: themeProvider.themeMode == ThemeMode.light ||
                    (themeProvider.themeMode == ThemeMode.system && !isDarkTheme),
              ),
              const SizedBox(height: 24),

              // Dark Theme Card
              _buildThemeCard(
                context: context,
                themeProvider: themeProvider,
                title: 'Dark theme',
                icon: Icons.nightlight_round_outlined,
                description: 'This theme will be active when your system is set to "dark mode"',
                isDarkCard: true,
                isActive: themeProvider.themeMode == ThemeMode.dark ||
                    (themeProvider.themeMode == ThemeMode.system && isDarkTheme),
              ),

              const SizedBox(height: 32),
              Divider(color: dividerColor),
              const SizedBox(height: 24),

              // Contrast Section
              Text('Contrast', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 16),
              _buildContrastSettings(context, themeProvider, isDarkTheme, cardBgColor, dividerColor, textColor),

              const SizedBox(height: 32),
              Divider(color: dividerColor),
              const SizedBox(height: 24),

              // Emoji Skin Tone Preference Section
              Text('Emoji skin tone preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 8),
              Text('Preferred default emoji skin tone', style: TextStyle(color: textColor, fontSize: 13)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildEmojiOption(themeProvider, 0, '👋'),
                  _buildEmojiOption(themeProvider, 1, '👋🏻'),
                  _buildEmojiOption(themeProvider, 2, '👋🏼'),
                  _buildEmojiOption(themeProvider, 3, '👋🏽'),
                  _buildEmojiOption(themeProvider, 4, '👋🏾'),
                  _buildEmojiOption(themeProvider, 5, '👋🏿'),
                ],
              ),

              const SizedBox(height: 32),
              Divider(color: dividerColor),
              const SizedBox(height: 24),

              // Tab Size Preference Section
              Text('Tab size preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 8),
              Text('Choose the number of spaces a tab is equal to when rendering code', style: TextStyle(color: textColor, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  border: Border.all(color: dividerColor),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: themeProvider.tabSize,
                    dropdownColor: cardBgColor,
                    icon: Icon(Icons.unfold_more, color: textColor, size: 18),
                    style: TextStyle(color: textColor, fontSize: 13, fontFamily: 'Inter'),
                    onChanged: (int? newSize) {
                      if (newSize != null) {
                        themeProvider.setTabSize(newSize);
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('2 spaces')),
                      DropdownMenuItem(value: 4, child: Text('4 (Default)')),
                      DropdownMenuItem(value: 8, child: Text('8 spaces')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              Divider(color: dividerColor),
              const SizedBox(height: 24),

              // Markdown Editor Font Preference Section
              Text('Markdown editor font preference', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: titleColor)),
              const SizedBox(height: 8),
              Text('Font preference for plain text editors that support Markdown styling (e.g. pull request and issue descriptions, comments.)', style: TextStyle(color: textColor, fontSize: 13, height: 1.4)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  themeProvider.setUseMonospaceMarkdown(!themeProvider.useMonospaceMarkdown);
                },
                child: Row(
                  children: [
                    Icon(
                      themeProvider.useMonospaceMarkdown ? Icons.check_box : Icons.check_box_outline_blank,
                      color: themeProvider.useMonospaceMarkdown ? const Color(0xFF1F6FEB) : const Color(0xFF8B949E),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Use a fixed-width (monospace) font when editing Markdown',
                        style: TextStyle(color: textColor, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Acadyk theme will match your system active settings';
      case ThemeMode.light:
        return 'Acadyk will always use the light theme layout';
      case ThemeMode.dark:
        return 'Acadyk will always use the dark theme layout';
    }
  }

  Widget _buildThemeCard({
    required BuildContext context,
    required ThemeProvider themeProvider,
    required String title,
    required IconData icon,
    required String description,
    required bool isDarkCard,
    required bool isActive,
  }) {
    const borderColor = Color(0xFF30363D);
    final cardBgColor = isDarkCard ? const Color(0xFF0D1117) : Colors.white;
    final mockUiHeaderColor = isDarkCard ? const Color(0xFF161B22) : const Color(0xFFF6F8FA);
    final mockUiBodyColor = isDarkCard ? const Color(0xFF0D1117) : const Color(0xFFFFFFFF);
    final textGrey = isDarkCard ? const Color(0xFF8B949E) : const Color(0xFF57606A);
    final accentColor = themeProvider.activeAccentColor;

    return GestureDetector(
      onTap: () {
        themeProvider.setThemeMode(isDarkCard ? ThemeMode.dark : ThemeMode.light);
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          border: Border.all(
            color: isActive ? const Color(0xFF58A6FF) : borderColor,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: const Border(bottom: BorderSide(color: borderColor)),
                color: isDarkCard ? const Color(0xFF161B22) : const Color(0xFFF6F8FA),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: textGrey, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: isDarkCard ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1F6FEB)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF1F6FEB).withOpacity(0.15),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Color(0xFF58A6FF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Body & Wireframe Mock UI
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: TextStyle(color: textGrey, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Wireframe Mock UI Preview
                  Container(
                    height: 140,
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor),
                      borderRadius: BorderRadius.circular(6),
                      color: mockUiHeaderColor,
                    ),
                    child: Column(
                      children: [
                        // Header bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(width: 40, height: 10, decoration: BoxDecoration(color: textGrey.withOpacity(0.4), borderRadius: BorderRadius.circular(5))),
                              const SizedBox(width: 12),
                              Container(width: 40, height: 10, decoration: BoxDecoration(color: textGrey.withOpacity(0.4), borderRadius: BorderRadius.circular(5))),
                              const SizedBox(width: 12),
                              Container(width: 40, height: 10, decoration: BoxDecoration(color: textGrey.withOpacity(0.4), borderRadius: BorderRadius.circular(5))),
                            ],
                          ),
                        ),
                        // Body part
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            color: mockUiBodyColor,
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(width: 80, height: 8, decoration: BoxDecoration(color: textGrey.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: isDarkCard ? const Color(0xFF21262D) : const Color(0xFFF3F4F6),
                                          border: Border.all(color: borderColor),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        padding: const EdgeInsets.all(6),
                                        child: Row(
                                          children: [
                                            Container(width: 50, height: 8, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(4))),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(width: 10, height: 10, decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(2))),
                                          const SizedBox(width: 4),
                                          Container(width: 10, height: 10, decoration: BoxDecoration(color: const Color(0xFFDA3633), borderRadius: BorderRadius.circular(2))),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: isDarkCard ? const Color(0xFF21262D) : const Color(0xFFF3F4F6),
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
                  Text(
                    isDarkCard ? 'Dark default' : 'Light default',
                    style: TextStyle(
                      color: isDarkCard ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // Footer Color Preset Selection Dots
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  isDarkCard ? ThemeProvider.darkBackgrounds.length : ThemeProvider.accentColors.length,
                  (index) {
                    final isSelectedPreset = isDarkCard
                        ? themeProvider.darkPresetIndex == index
                        : themeProvider.lightPresetIndex == index;
                    
                    final colorVal = isDarkCard
                        ? ThemeProvider.darkBackgrounds[index]
                        : ThemeProvider.accentColors[index];

                    return GestureDetector(
                      onTap: () {
                        if (isDarkCard) {
                          themeProvider.setDarkPresetIndex(index);
                          themeProvider.setThemeMode(ThemeMode.dark);
                        } else {
                          themeProvider.setLightPresetIndex(index);
                          themeProvider.setThemeMode(ThemeMode.light);
                        }
                      },
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorVal,
                          border: Border.all(
                            color: isSelectedPreset ? const Color(0xFF58A6FF) : const Color(0xFF30363D),
                            width: isSelectedPreset ? 3.0 : 1.5,
                          ),
                          boxShadow: isSelectedPreset
                              ? [BoxShadow(color: const Color(0xFF58A6FF).withOpacity(0.4), blurRadius: 4)]
                              : [],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContrastSettings(
    BuildContext context,
    ThemeProvider themeProvider,
    bool isDarkTheme,
    Color cardBgColor,
    Color dividerColor,
    Color textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: dividerColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _buildContrastRow(
            title: 'Increase contrast',
            subtitle: 'Enable high contrast for light or dark mode (or both) based on your system settings',
            trailing: const SizedBox.shrink(),
            textColor: textColor,
          ),
          Divider(height: 1, color: dividerColor),
          _buildContrastRow(
            title: 'Light mode',
            subtitle: null,
            trailing: Switch(
              value: themeProvider.highContrastLight,
              activeColor: const Color(0xFF238636),
              onChanged: (val) => themeProvider.setHighContrastLight(val),
            ),
            textColor: textColor,
          ),
          Divider(height: 1, color: dividerColor),
          _buildContrastRow(
            title: 'Dark mode',
            subtitle: null,
            trailing: Switch(
              value: themeProvider.highContrastDark,
              activeColor: const Color(0xFF238636),
              onChanged: (val) => themeProvider.setHighContrastDark(val),
            ),
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildContrastRow({
    required String title,
    required String? subtitle,
    required Widget trailing,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildEmojiOption(ThemeProvider themeProvider, int index, String emoji) {
    final isSelected = themeProvider.emojiSkinToneIndex == index;
    return GestureDetector(
      onTap: () {
        themeProvider.setEmojiSkinToneIndex(index);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? const Color(0xFF58A6FF) : const Color(0xFF8B949E),
                width: isSelected ? 5 : 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(emoji, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
