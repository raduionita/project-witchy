import 'package:flutter/material.dart';

class CoupleSharingScreen extends StatefulWidget {
  const CoupleSharingScreen({super.key});

  @override
  State<CoupleSharingScreen> createState() => _CoupleSharingScreenState();
}

class _CoupleSharingScreenState extends State<CoupleSharingScreen> {
  bool _isSharingEnabled = false;
  String _partnerName = '';
  bool _shareCycleUpdates = true;
  bool _shareFertilityWindow = false;
  bool _shareSymptoms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Witchy for Couples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),
            _buildPartnerSetupSection(),
            const SizedBox(height: 16),
            _buildSharingPreferences(),
            const SizedBox(height: 16),
            _buildBenefitsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Your Journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Witchy for Couples helps you and your partner stay connected throughout your cycle, pregnancy, and health journey. '
              'You control what information is shared.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerSetupSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: _isSharingEnabled,
              onChanged: (value) {
                setState(() {
                  _isSharingEnabled = value;
                });
              },
              title: const Text('Enable Couple Sharing'),
              subtitle: const Text('Share select cycle information with your partner'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Partner\'s Name',
                border: OutlineInputBorder(),
                hintText: 'Enter your partner\'s name',
                prefixIcon: Icon(Icons.person),
              ),
              onChanged: (value) {
                setState(() {
                  _partnerName = value;
                });
              },
            ),
            if (_isSharingEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Couple sharing is now active for $_partnerName',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSharingPreferences() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What to Share',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _shareCycleUpdates,
              onChanged: (value) {
                setState(() {
                  _shareCycleUpdates = value;
                });
              },
              title: const Text('Cycle Updates'),
              subtitle: const Text('Share period start/end dates and cycle day'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              value: _shareFertilityWindow,
              onChanged: (value) {
                setState(() {
                  _shareFertilityWindow = value;
                });
              },
              title: const Text('Fertility Window'),
              subtitle: const Text('Share predicted fertile days'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            SwitchListTile(
              value: _shareSymptoms,
              onChanged: (value) {
                setState(() {
                  _shareSymptoms = value;
                });
              },
              title: const Text('Symptom Updates'),
              subtitle: const Text('Share selected symptoms with your partner'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Benefits of Couple Sharing',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildBenefitItem(Icons.favorite, 'Deepen connection through understanding', 'Your partner can better understand what you\'re going through'),
            _buildBenefitItem(Icons.notifications_active, 'Stay Informed', 'Get notified about important cycle events'),
            _buildBenefitItem(Icons.psychology, 'Support Each Other', 'Navigate pregnancy and health journeys together'),
            _buildBenefitItem(Icons.lock, 'Privacy First', 'You control exactly what information is shared'),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
            child: Icon(icon, size: 16, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
