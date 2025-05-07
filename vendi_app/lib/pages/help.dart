import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineHelpPage extends StatefulWidget {
  const MachineHelpPage({Key? key}) : super(key: key);

  @override
  _MachineHelpPageState createState() => _MachineHelpPageState();
}

class _MachineHelpPageState extends State<MachineHelpPage> {
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodySmall?.color;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    'How to Use Vendi',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),

                // Machines section
                _buildSectionTitle('Machine Types', Icons.category_outlined),
                _buildHelpCard(
                  'assets/images/PinkMachine.png',
                  'Snack Machine',
                  'Machines that appear like this will mostly contain snacks.',
                  cardColor,
                  textColor,
                  secondaryTextColor,
                ),
                _buildHelpCard(
                  'assets/images/BlueMachine.png',
                  'Beverage Machine',
                  'Machines that appear like this will mostly contain beverages.',
                  cardColor,
                  textColor,
                  secondaryTextColor,
                ),
                _buildHelpCard(
                  'assets/images/YellowMachine.png',
                  'Supply Machine',
                  'Machines that appear like this will mostly contain non-food and non-drink items.',
                  cardColor,
                  textColor,
                  secondaryTextColor,
                ),

                const SizedBox(height: 24),

                // Features section
                _buildSectionTitle(
                    'App Features', Icons.tips_and_updates_outlined),
                _buildFeatureCard(
                  Icons.add,
                  'Adding Machines',
                  'To add a new machine, simply click the plus icon on the top right corner on the maps page.',
                  cardColor,
                  primaryColor,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.filter_alt,
                  'Filtering Machines',
                  'Use the filter to sort machines by snack, beverage, or supply types.',
                  cardColor,
                  primaryColor,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.favorite,
                  'Favorites',
                  'Tap the heart icon on any machine to add it to your Favorites (max 10). View all your saved machines in the Favorites tab.',
                  cardColor,
                  Colors.red,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.monetization_on,
                  'Points & Rewards',
                  'Earn points and level up:\n• +50 for each machine you add\n• +10 for each machine you report\nCheck your total points and levels on the Leaderboard tab.',
                  cardColor,
                  Colors.amber,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.edit,
                  'Updating Machines',
                  'Tap the edit icon on a machine\'s detail screen to correct its info:\n• Toggle card or cash payment options\n• Switch operational status on/off\n(Note: you must be within 50m to submit updates.)',
                  cardColor,
                  primaryColor,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.emoji_events,
                  'Achievements',
                  'Collect badges for achievements like adding machines or hitting point targets. Track every badge in Profile → Achievements.',
                  cardColor,
                  Colors.deepPurple,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.report,
                  'Reporting Machines',
                  'Spot a problem? Tap the report icon on a machine\'s detail screen to submit feedback. You earn +10 points per valid report.',
                  cardColor,
                  Colors.redAccent,
                  textColor,
                  secondaryTextColor,
                ),
                _buildFeatureCard(
                  Icons.person,
                  'Profile & Theme',
                  'Tap your profile picture to update it and watch the app theme change colors accordingly. In Settings, tap Reset to revert back to default theme colors.',
                  cardColor,
                  primaryColor,
                  textColor,
                  secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpCard(
    String imagePath,
    String title,
    String description,
    Color cardColor,
    Color? titleColor,
    Color? descriptionColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color cardColor,
    Color iconColor,
    Color? titleColor,
    Color? descriptionColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: descriptionColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
