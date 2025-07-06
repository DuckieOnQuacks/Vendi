import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      leading: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        title: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
          height: 32,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: [
          _buildSectionHeader('App Information'),
          _buildSectionCard([
            _buildInfoTile(
              title: 'Version',
              subtitle: _version,
              icon: Icons.info_outline,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              title: 'Developer',
              subtitle: 'Vendi Team',
              icon: Icons.code,
            ),
          ]),
          _buildSectionHeader('Legal'),
          _buildSectionCard([
            _buildInfoTile(
              title: 'Terms of Service',
              icon: Icons.description_outlined,
              onTap: () {
                // TODO: Navigate to Terms of Service page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Terms of Service coming soon'),
                  ),
                );
              },
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              title: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () {
                // TODO: Navigate to Privacy Policy page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy Policy coming soon'),
                  ),
                );
              },
            ),
          ]),
          _buildSectionHeader('Contact'),
          _buildSectionCard([
            _buildInfoTile(
              title: 'Email Support',
              subtitle: 'support@vendi.app',
              icon: Icons.email_outlined,
              onTap: () => _launchURL('mailto:support@vendi.app'),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              title: 'Website',
              subtitle: 'vendi.app',
              icon: Icons.language_outlined,
              onTap: () => _launchURL('https://vendi.app'),
            ),
          ]),
          _buildSectionHeader('Credits'),
          _buildSectionCard([
            _buildInfoTile(
              title: 'Icons and Assets',
              subtitle: 'Flutter Icons, Custom Design',
              icon: Icons.image_outlined,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildInfoTile(
              title: 'Third-Party Libraries',
              subtitle: 'See GitHub for full list',
              icon: Icons.library_books_outlined,
              onTap: () => _launchURL('https://github.com/yourusername/vendi'),
            ),
          ]),
        ],
      ),
    );
  }
}
