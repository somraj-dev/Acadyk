import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionsScreen extends StatefulWidget {
  const AppPermissionsScreen({super.key});

  @override
  State<AppPermissionsScreen> createState() => _AppPermissionsScreenState();
}

class _AppPermissionsScreenState extends State<AppPermissionsScreen> {
  bool _isLoading = true;

  Map<Permission, PermissionStatus> _statuses = {
    Permission.camera: PermissionStatus.denied,
    Permission.location: PermissionStatus.denied,
    Permission.notification: PermissionStatus.denied,
    Permission.photos: PermissionStatus.denied,
    Permission.calendarFullAccess: PermissionStatus.denied,
    Permission.microphone: PermissionStatus.denied,
  };

  @override
  void initState() {
    super.initState();
    _checkAllPermissions();
  }

  Future<void> _checkAllPermissions() async {
    setState(() => _isLoading = true);
    final Map<Permission, PermissionStatus> newStatuses = {};
    for (final perm in _statuses.keys) {
      try {
        final status = await perm.status;
        newStatuses[perm] = status;
      } catch (_) {
        newStatuses[perm] = PermissionStatus.denied;
      }
    }
    if (mounted) {
      setState(() {
        _statuses = newStatuses;
        _isLoading = false;
      });
    }
  }

  Future<void> _togglePermission(Permission perm) async {
    final currentStatus = _statuses[perm];
    if (currentStatus == PermissionStatus.permanentlyDenied) {
      await openAppSettings();
      return;
    }

    final newStatus = await perm.request();
    if (mounted) {
      setState(() {
        _statuses[perm] = newStatus;
      });
    }

    if (newStatus.isPermanentlyDenied) {
      if (mounted) {
        _showPermanentlyDeniedDialog(perm);
      }
    }
  }

  void _showPermanentlyDeniedDialog(Permission perm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'This permission has been disabled in Android system settings. Please enable it in Settings for optimal app performance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F172A);
    const textColor = Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'App Permissions',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_outlined, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Application Performance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Manage permissions for camera, location, notifications, storage & calendar for smooth operation.',
                                    style: TextStyle(fontSize: 12.5, color: Color(0xFF1E40AF), height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'Device Permissions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 1. Camera Permission
                      _buildPermissionTile(
                        perm: Permission.camera,
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        description: 'Take profile photos, scan QR codes & attach post media',
                        iconBgColor: const Color(0xFFECFDF5),
                        iconColor: const Color(0xFF059669),
                      ),

                      // 2. Location Permission
                      _buildPermissionTile(
                        perm: Permission.location,
                        icon: Icons.location_on_outlined,
                        title: 'Location Services',
                        description: 'Discover nearby campus events, colleges & MITS Gwalior updates',
                        iconBgColor: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                      ),

                      // 3. Notifications Permission
                      _buildPermissionTile(
                        perm: Permission.notification,
                        icon: Icons.notifications_active_outlined,
                        title: 'Push Notifications',
                        description: 'Receive instant alerts for placement drives, exam timetables & chats',
                        iconBgColor: const Color(0xFFEEF2FF),
                        iconColor: const Color(0xFF4F46E5),
                      ),

                      // 4. Photos & Media Storage
                      _buildPermissionTile(
                        perm: Permission.photos,
                        icon: Icons.photo_library_outlined,
                        title: 'Photos & Storage',
                        description: 'Save official certificates, download resumes & pick post images',
                        iconBgColor: const Color(0xFFF0FDF4),
                        iconColor: const Color(0xFF16A34A),
                      ),

                      // 5. Calendar Permission
                      _buildPermissionTile(
                        perm: Permission.calendarFullAccess,
                        icon: Icons.calendar_today_outlined,
                        title: 'Calendar Sync',
                        description: 'Sync exam schedules, hackathons & submission deadlines',
                        iconBgColor: const Color(0xFFFAF5FF),
                        iconColor: const Color(0xFF9333EA),
                      ),

                      // 6. Microphone Permission
                      _buildPermissionTile(
                        perm: Permission.microphone,
                        icon: Icons.mic_none_outlined,
                        title: 'Microphone',
                        description: 'Record audio notes & send voice messages in chats',
                        iconBgColor: const Color(0xFFFFF1F2),
                        iconColor: const Color(0xFFE11D48),
                      ),

                      const SizedBox(height: 24),

                      // System Settings Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => openAppSettings(),
                          icon: const Icon(Icons.settings, size: 20),
                          label: const Text(
                            'Open Android System Settings',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required Permission perm,
    required IconData icon,
    required String title,
    required String description,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final status = _statuses[perm] ?? PermissionStatus.denied;
    final bool isGranted = status.isGranted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isGranted ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGranted ? 'Allowed' : 'Denied',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isGranted ? const Color(0xFF15803D) : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isGranted,
            activeColor: const Color(0xFF10B981),
            onChanged: (val) => _togglePermission(perm),
          ),
        ],
      ),
    );
  }
}
