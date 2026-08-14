import 'package:flutter/material.dart';
import '../../../../common/services/notification_service.dart';

class SettingsNotificationsScreen extends StatefulWidget {
  const SettingsNotificationsScreen({super.key});

  @override
  State<SettingsNotificationsScreen> createState() => _SettingsNotificationsScreenState();
}

class _SettingsNotificationsScreenState extends State<SettingsNotificationsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _likesEnabled = true;
  bool _commentsEnabled = true;
  bool _connectionsEnabled = true;
  bool _opportunitiesEnabled = true;
  bool _eventsEnabled = true;
  bool _messagesEnabled = true;
  bool _communitiesEnabled = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await NotificationService.getPreferences();
    if (prefs != null && mounted) {
      setState(() {
        _pushEnabled = prefs['pushEnabled'] ?? true;
        _emailEnabled = prefs['emailEnabled'] ?? true;
        _likesEnabled = prefs['likesEnabled'] ?? true;
        _commentsEnabled = prefs['commentsEnabled'] ?? true;
        _connectionsEnabled = prefs['connectionsEnabled'] ?? true;
        _opportunitiesEnabled = prefs['opportunitiesEnabled'] ?? true;
        _eventsEnabled = prefs['eventsEnabled'] ?? true;
        _messagesEnabled = prefs['messagesEnabled'] ?? true;
        _communitiesEnabled = prefs['communitiesEnabled'] ?? true;
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    final updated = {
      'pushEnabled': _pushEnabled,
      'emailEnabled': _emailEnabled,
      'likesEnabled': _likesEnabled,
      'commentsEnabled': _commentsEnabled,
      'connectionsEnabled': _connectionsEnabled,
      'opportunitiesEnabled': _opportunitiesEnabled,
      'eventsEnabled': _eventsEnabled,
      'messagesEnabled': _messagesEnabled,
      'communitiesEnabled': _communitiesEnabled,
      key: value,
    };
    await NotificationService.updatePreferences(updated);
  }

  @override
  Widget build(BuildContext context) {
    const tileTextColor = Color(0xFF262626);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: tileTextColor, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: tileTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.4,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            color: const Color(0xFFEFEFEF),
            height: 0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  color: Colors.white,
                  child: ListView(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
                        child: Text(
                          'Channels',
                          style: TextStyle(
                            color: tileTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildSwitchTile('Push Notifications', 'Receive push alerts on your device', _pushEnabled, (val) {
                        setState(() => _pushEnabled = val);
                        _updatePreference('pushEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Email Notifications', 'Receive email digest updates', _emailEnabled, (val) {
                        setState(() => _emailEnabled = val);
                        _updatePreference('emailEnabled', val);
                      }),
                      _buildDivider(),
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 12.0),
                        child: Text(
                          'Notification Triggers',
                          style: TextStyle(
                            color: tileTextColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildSwitchTile('Messages', 'Direct chat and group conversations', _messagesEnabled, (val) {
                        setState(() => _messagesEnabled = val);
                        _updatePreference('messagesEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Connections', 'Connection requests and network updates', _connectionsEnabled, (val) {
                        setState(() => _connectionsEnabled = val);
                        _updatePreference('connectionsEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Reactions & Likes', 'When members react to your posts', _likesEnabled, (val) {
                        setState(() => _likesEnabled = val);
                        _updatePreference('likesEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Comments & Replies', 'Threaded comments on your posts', _commentsEnabled, (val) {
                        setState(() => _commentsEnabled = val);
                        _updatePreference('commentsEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Opportunities & Jobs', 'Job alerts and applicant updates', _opportunitiesEnabled, (val) {
                        setState(() => _opportunitiesEnabled = val);
                        _updatePreference('opportunitiesEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Events & Workshops', 'Event reminders and registration alerts', _eventsEnabled, (val) {
                        setState(() => _eventsEnabled = val);
                        _updatePreference('eventsEnabled', val);
                      }),
                      _buildDivider(),
                      _buildSwitchTile('Communities & Clubs', 'Announcements and space activities', _communitiesEnabled, (val) {
                        setState(() => _communitiesEnabled = val);
                        _updatePreference('communitiesEnabled', val);
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF737373))),
      value: value,
      activeColor: const Color(0xFF0073B1),
      onChanged: onChanged,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF3F3F3),
    );
  }
}
