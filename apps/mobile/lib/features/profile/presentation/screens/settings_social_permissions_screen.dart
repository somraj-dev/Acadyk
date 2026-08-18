import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'settings_mentions_screen.dart';

class SettingsSocialPermissionsScreen extends StatefulWidget {
  const SettingsSocialPermissionsScreen({super.key});

  @override
  State<SettingsSocialPermissionsScreen> createState() => _SettingsSocialPermissionsScreenState();
}

class _SettingsSocialPermissionsScreenState extends State<SettingsSocialPermissionsScreen> {
  bool _allowCommentsOnPins = true;
  bool _filterCommentsOnMyPins = false;
  bool _filterCommentsOnOthersPins = false;
  bool _showSimilarProducts = true;

  String _messagePermission = 'Everyone';
  String _mentionPermission = 'Anyone on Acadyk';

  @override
  Widget build(BuildContext context) {
    const titleColor = Color(0xFF0F172A);
    const activeSwitchColor = Color(0xFF355CEC);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Social permissions',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            color: Colors.white,
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              children: [
                // SECTION 1: Messages
                _buildSectionHeader('Messages'),
                _buildNavigationTile(
                  title: 'Message settings',
                  subtitle: 'Choose who can send you a message and add you to group conversations',
                  onTap: () => _showMessageSettingsModal(context),
                ),

                // SECTION 2: Comments
                _buildSectionHeader('Comments'),
                _buildSwitchTile(
                  title: 'Allow comments on your posts',
                  subtitle: 'Comments will be turned on by default for your new and existing posts',
                  value: _allowCommentsOnPins,
                  activeColor: activeSwitchColor,
                  onChanged: (val) {
                    setState(() => _allowCommentsOnPins = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'Filter comments on my posts',
                  subtitle: 'Hide comments from everyone on posts you created that contain specific words or phrases.',
                  value: _filterCommentsOnMyPins,
                  activeColor: activeSwitchColor,
                  onChanged: (val) {
                    setState(() => _filterCommentsOnMyPins = val);
                  },
                ),
                _buildSwitchTile(
                  title: 'Filter comments on others\' posts',
                  subtitle: 'Hide comments from others\' posts that contain specific words or phrases.',
                  value: _filterCommentsOnOthersPins,
                  activeColor: activeSwitchColor,
                  onChanged: (val) {
                    setState(() => _filterCommentsOnOthersPins = val);
                  },
                ),
                _buildNavigationTile(
                  title: '@Mentions',
                  subtitle: 'Choose who can mention you in a comment',
                  onTap: () async {
                    final selected = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SettingsMentionsScreen(
                          initialSelection: _mentionPermission,
                        ),
                      ),
                    );
                    if (selected != null && mounted) {
                      setState(() {
                        _mentionPermission = selected;
                      });
                    }
                  },
                ),

                // SECTION 3: Block list
                _buildSectionHeader('Block list'),
                _buildNavigationTile(
                  title: 'Blocked accounts',
                  subtitle: 'Manage people you\'ve blocked',
                  onTap: () => _showBlockedAccountsModal(context),
                ),

                // SECTION 4: Recommendations
                _buildSectionHeader('Shopping recommendations'),
                _buildSwitchTile(
                  title: 'Show similar products',
                  subtitle: 'People can shop for products and tools similar to what\'s shown in your posts using visual search.',
                  value: _showSimilarProducts,
                  activeColor: activeSwitchColor,
                  onChanged: (val) {
                    setState(() => _showSimilarProducts = val);
                  },
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 22.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F172A),
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildNavigationTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right,
              size: 22,
              color: Color(0xFF0F172A),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CupertinoSwitch(
            value: value,
            activeTrackColor: activeColor,
            inactiveTrackColor: const Color(0xFFE2E8F0),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showMessageSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Message settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose who can send you direct messages on Acadyk.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ...['Everyone', 'People you follow', 'No one'].map((option) {
                  final isSelected = _messagePermission == option;
                  return InkWell(
                    onTap: () {
                      setState(() => _messagePermission = option);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? const Color(0xFF355CEC) : const Color(0xFF94A3B8),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            option,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBlockedAccountsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block, size: 44, color: Color(0xFF94A3B8)),
                const SizedBox(height: 16),
                const Text(
                  'Blocked accounts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You haven\'t blocked any accounts yet. Blocked accounts won\'t be able to view your profile, messages, or comments.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
