// settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../backend/classes/theme_provider.dart';
import 'package:vendi_app/backend/classes/user.dart';
import 'package:vendi_app/pages/help.dart';
import 'package:vendi_app/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vendi_app/backend/message_helper.dart';
import 'package:vendi_app/pages/about.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _useTestMachines = false;
  bool _isDeleting = false; // Track deletion state

  @override
  void initState() {
    super.initState();
    _loadTestMachinesSetting();
  }

  Future<void> _loadTestMachinesSetting() async {
    final setting = await getTestMachinesSetting();
    if (mounted) {
      setState(() {
        _useTestMachines = setting;
      });
    }
  }

  // Helper method to create styled section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context)
              .colorScheme
              .onSurface, // Use primary color for header
        ),
      ),
    );
  }

  // Helper method to create styled cards for sections
  Widget _buildSectionCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        elevation: 1, // Subtle shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
        ),
        clipBehavior: Clip.antiAlias, // Clip content to rounded corners
        child: Column(
          children: children,
        ),
      ),
    );
  }
  // --- Build methods for individual settings ---

  Widget buildDarkModeSwitch(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SwitchListTile(
      title: const Text('Dark Mode'),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme(value);
        updateDarkModeSetting(value);
      },
      secondary: Icon(
        themeProvider.isDarkMode
            ? Icons.dark_mode_outlined
            : Icons.light_mode_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget buildResetThemeTile(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ListTile(
      title: const Text('Reset Theme Color'),
      subtitle: const Text('Revert to default theme color'),
      leading: Icon(
        Icons.color_lens_outlined,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        themeProvider.resetToDefaultColor();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme color reset to default.'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget buildHelpTile(BuildContext context) {
    return ListTile(
      title: const Text('Help'),
      leading: Icon(
        Icons.help_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MachineHelpPage()),
        );
      },
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16), // iOS-style chevron
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget buildLogoutTile(BuildContext context) {
    return ListTile(
      title: const Text('Logout'),
      subtitle: const Text('Sign out of your account'),
      leading: Icon(
        Icons.logout,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        showConfirmationDialog(
          context,
          title: 'Confirm Logout',
          message: 'Are you sure you want to log out of your account?',
          confirmText: 'Sign Out',
          onConfirm: () {
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
        );
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget buildDeleteAccountTile(BuildContext context) {
    return ListTile(
      title: const Text('Delete Account'),
      subtitle: const Text('Permanently delete your account and data'),
      leading: Icon(
        Icons.delete_forever,
        color: Colors.red,
      ),
      onTap: () {
        _showDeleteAccountDialog();
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  Widget buildAboutTile(BuildContext context) {
    return ListTile(
      title: const Text('About'),
      subtitle: const Text('App information and legal documents'),
      leading: Icon(
        Icons.info_outline,
        color: Theme.of(context).colorScheme.primary,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutPage()),
        );
      },
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
    );
  }

  // Delete account confirmation dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Delete Account'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Warning: This action cannot be undone!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 16),
              Text('Deleting your account will:'),
              SizedBox(height: 8),
              Text('• Remove all your personal data'),
              Text('• Delete all your machines from the app'),
              Text('• Revoke your access to the app'),
              SizedBox(height: 16),
              Text('Are you absolutely sure you want to delete your account?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            _isDeleting
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _deleteAccount();
                    },
                    child: Text('Delete Account'),
                  ),
          ],
        );
      },
    );
  }

  // Show a dialog to enter password for re-authentication
  void _showReauthDialog() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    bool isAuthenticating = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.security,
                      color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: 10),
                  Text('Confirm Identity'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('For security, please enter your password to continue:'),
                  SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: errorMessage,
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                isAuthenticating
                    ? Container(
                        padding: EdgeInsets.all(5),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (passwordController.text.isEmpty) {
                            setState(() {
                              errorMessage = 'Password is required';
                            });
                            return;
                          }

                          setState(() {
                            isAuthenticating = true;
                            errorMessage = null;
                          });

                          bool success =
                              await reauthenticateUser(passwordController.text);

                          if (success) {
                            Navigator.of(context).pop(true);
                            _proceedWithAccountDeletion();
                          } else {
                            setState(() {
                              isAuthenticating = false;
                              errorMessage =
                                  'Invalid password. Please try again.';
                            });
                          }
                        },
                        child: Text('Confirm'),
                      ),
              ],
            );
          },
        );
      },
    );
  }

  // Delete account function
  Future<void> _deleteAccount() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Close the warning dialog
      Navigator.of(context).pop();

      // Proceed with account deletion
      _proceedWithAccountDeletion();
    } catch (e) {
      // Handle any unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isDeleting = false;
      });
    }
  }

  // Handle the actual account deletion process
  Future<void> _proceedWithAccountDeletion() async {
    try {
      var result = await deleteUserAccount();

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      } else if (result['requiresReauth']) {
        // User needs to re-authenticate first
        _showReauthDialog();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                'Failed to delete account. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  // --- Main build method ---

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
          _buildSectionHeader('Theme'),
          _buildSectionCard([
            buildDarkModeSwitch(context),
            const Divider(height: 1, indent: 16, endIndent: 16),
            buildResetThemeTile(context),
          ]),
          _buildSectionHeader('Account'),
          _buildSectionCard([
            buildLogoutTile(context),
            const Divider(height: 1, indent: 16, endIndent: 16),
            buildDeleteAccountTile(context),
          ]),
          _buildSectionHeader('Support'),
          _buildSectionCard([
            buildHelpTile(context),
            const Divider(height: 1, indent: 16, endIndent: 16),
            buildAboutTile(context),
          ]),
        ],
      ),
    );
  }
}
