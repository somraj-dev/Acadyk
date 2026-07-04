import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingsUpgradeScreen extends StatefulWidget {
  const SettingsUpgradeScreen({super.key});

  @override
  State<SettingsUpgradeScreen> createState() => _SettingsUpgradeScreenState();
}

class _SettingsUpgradeScreenState extends State<SettingsUpgradeScreen> {
  int _activeTab = 0; // 0 for Premium, 1 for Premium+
  int _selectedPlan = 0; // 0 for Monthly, 1 for Annual

  final List<Map<String, dynamic>> _premiumFeatures = [
    {'icon': Icons.verified_outlined, 'title': 'Verified tick'},
    {'icon': CupertinoIcons.compass, 'title': 'Enhanced Grok access'},
    {'icon': Icons.dashboard_customize_outlined, 'title': 'Create Custom Timelines', 'info': true},
    {'icon': Icons.analytics_outlined, 'title': 'Advanced analytics', 'info': true},
    {'icon': Icons.star_outline, 'title': 'Less ads in your feeds'},
    {'icon': CupertinoIcons.chat_bubble_2, 'title': 'Boosted replies', 'info': true},
    {'icon': Icons.article_outlined, 'title': 'Write Articles'},
    {'icon': Icons.monetization_on_outlined, 'title': 'Get paid to post'},
    {'icon': Icons.add_circle_outline, 'title': 'Everything in Basic'},
  ];

  final List<Map<String, dynamic>> _premiumPlusFeatures = [
    {'icon': Icons.verified, 'title': 'Gold/Silver Verified tick'},
    {'icon': CupertinoIcons.compass_fill, 'title': 'Full Grok access'},
    {'icon': Icons.dashboard_customize, 'title': 'Unlimited Custom Timelines', 'info': true},
    {'icon': Icons.analytics, 'title': 'Deep analytics & insights', 'info': true},
    {'icon': Icons.star, 'title': 'No ads in your feeds'},
    {'icon': CupertinoIcons.chat_bubble_2_fill, 'title': 'Max boosted replies', 'info': true},
    {'icon': Icons.article, 'title': 'Write Articles & Newsletters'},
    {'icon': Icons.monetization_on, 'title': 'Double paid to post rewards'},
    {'icon': Icons.add_circle, 'title': 'Everything in Premium'},
  ];

  @override
  Widget build(BuildContext context) {
    final features = _activeTab == 0 ? _premiumFeatures : _premiumPlusFeatures;
    
    // Pricing details based on selected tab and plan
    final String monthlyPrice = _activeTab == 0 ? '₹235.00' : '₹470.00';
    final String monthlyRenewal = _activeTab == 0 ? '₹470.00' : '₹940.00';
    final String annualPrice = _activeTab == 0 ? '₹4,700.00' : '₹9,400.00';

    const Color bgColor = Colors.white;
    const Color cardBgColor = Color(0xFFF7F7F9);
    const Color textColor = Color(0xFF191919);
    const Color secondaryTextColor = Color(0xFF5E5E5E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: textColor, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Premium',
                    style: TextStyle(
                      color: _activeTab == 0 ? textColor : secondaryTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 70,
                    color: _activeTab == 0 ? textColor : Colors.transparent,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Premium+',
                    style: TextStyle(
                      color: _activeTab == 1 ? textColor : secondaryTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 80,
                    color: _activeTab == 1 ? textColor : Colors.transparent,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48), // balance leading close icon
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                
                // Features Container
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: features.map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(feature['icon'] as IconData, color: textColor, size: 20),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                feature['title'] as String,
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (feature['info'] == true)
                              const Icon(Icons.info_outline, color: secondaryTextColor, size: 16),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                const SizedBox(height: 24),

                // Subscriptions Duration Selection Row
                Row(
                  children: [
                    // Monthly option
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 0),
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: _selectedPlan == 0 ? textColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Monthly',
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '50% off',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$monthlyPrice for 2 months',
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Then $monthlyRenewal / month',
                                style: const TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Annual option
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedPlan = 1),
                        child: Container(
                          padding: const EdgeInsets.all(14.0),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: _selectedPlan == 1 ? textColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Annual',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '$annualPrice / year',
                                style: const TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 18), // matching height spacing
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Subscribe & Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Subscribed to ${_activeTab == 0 ? "Premium" : "Premium+"} (${_selectedPlan == 0 ? "Monthly" : "Annual"}) successfully!',
                          ),
                          backgroundColor: Colors.blue[600],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Subscribe & pay',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Renew info text
                Center(
                  child: Text(
                    _selectedPlan == 0
                        ? 'Renews at $monthlyRenewal/month until cancelled'
                        : 'Renews at $annualPrice/year until cancelled',
                    style: const TextStyle(
                      color: secondaryTextColor,
                      fontSize: 12.0,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Purchaser terms agreement text
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(color: secondaryTextColor, fontSize: 11.0, height: 1.4),
                      children: [
                        const TextSpan(text: 'By subscribing, you agree to our '),
                        TextSpan(
                          text: 'Purchaser Terms',
                          style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
                        ),
                        const TextSpan(text: ', and that subscriptions auto-renew until you cancel. '),
                        TextSpan(
                          text: 'Cancel anytime',
                          style: TextStyle(color: Colors.blue[700], decoration: TextDecoration.underline),
                        ),
                        const TextSpan(
                          text: ', at least 24 hours prior to renewal to avoid additional charges. Price subject to change. Manage your subscription through the platform you subscribed on.',
                        ),
                      ],
                    ),
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
}
