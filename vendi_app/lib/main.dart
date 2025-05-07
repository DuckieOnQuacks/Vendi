import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:vendi_app/backend/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'backend/classes/theme_provider.dart'; // Import your ThemeProvider class
import 'package:google_fonts/google_fonts.dart';

// Main function that runs when the app is launched
Future<void> main() async {
  // Ensuring that the widgets are initialized
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // Initializing Firebase
  await Firebase.initializeApp();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Running the MyApp widget wrapped with ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
}

// The main widget of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    // Use the primary color from ThemeProvider
    final primaryColor = themeProvider.primaryColor;
    final secondaryColor = primaryColor.withOpacity(0.8);
    
    // Define centralized color palette based on dynamic primary color
    final accentColor = HSLColor.fromColor(primaryColor).withLightness(0.6).toColor();
    final errorColor = Colors.red;
    final successColor = Colors.green;
    final warningColor = Colors.amber;
    final infoColor = Colors.blue;

    // Light mode colors
    const _lightBgColor = Colors.white;
    const _lightCardColor = Color(0xFFF5F5F5);
    const _lightTextPrimaryColor = Colors.black;
    const _lightTextSecondaryColor = Color(0xFF616161);
    const _lightDividerColor = Color(0xFFE0E0E0);
    const _lightSurfaceColor = Color(0xFFFAFAFA);
    const _lightSurfaceVariantColor = Color(0xFFEEEEEE);
    const _lightShadowColor = Color(0x1F000000);
    const _lightIconColor = Color(0xFF757575);

    // Dark mode colors
    const _darkBgColor = Color(0xFF121212);
    const _darkCardColor = Color(0xFF1E1E1E);
    const _darkTextPrimaryColor = Colors.white;
    const _darkTextSecondaryColor = Color(0xFFB0B0B0);
    const _darkDividerColor = Color(0xFF424242);
    const _darkSurfaceColor = Color(0xFF252525);
    const _darkSurfaceVariantColor = Color(0xFF2C2C2C);
    const _darkShadowColor = Color(0x4D000000);
    const _darkIconColor = Color(0xFFB0B0B0);

    // Light theme levels using dynamic primary color as base
    final lightLevelColors = [
      Colors.teal,
      Colors.deepPurple,
      Colors.amber.shade700,
      Colors.orange.shade800,
      Colors.red.shade700,
      Colors.indigo,
      Colors.deepPurple.shade900,
    ];

    // Dark theme levels
    final darkLevelColors = [
      Colors.teal.shade300,
      Colors.deepPurple.shade300,
      Colors.amber.shade400,
      Colors.orange.shade400,
      Colors.red.shade400,
      Colors.indigo.shade300,
      Colors.deepPurple.shade400,
    ];

    // Define color schemes
    final lightColorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: _lightSurfaceColor,
      background: _lightBgColor,
    );

    final darkColorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: accentColor,
      error: errorColor,
      surface: _darkSurfaceColor,
      background: _darkBgColor,
    );

    // Define light theme with dynamic primary color
    final lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: lightColorScheme,
      scaffoldBackgroundColor: _lightBgColor,
      cardColor: _lightCardColor,
      dividerColor: _lightDividerColor,
      iconTheme: const IconThemeData(color: _lightIconColor),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 16,
        ),
        bodyMedium: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 14,
        ),
        bodySmall: const TextStyle(
          color: _lightTextSecondaryColor,
          fontSize: 12,
        ),
        titleLarge: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _lightBgColor,
        foregroundColor: _lightTextPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actionsIconTheme: const IconThemeData(color: _lightIconColor),
        titleTextStyle: const TextStyle(
          color: _lightTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      shadowColor: _lightShadowColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _lightBgColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: _lightTextSecondaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : _lightCardColor;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor.withAlpha(128)
              : _lightDividerColor;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : Colors.transparent;
        }),
        side: const BorderSide(color: _lightTextSecondaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : _lightTextSecondaryColor;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: _lightDividerColor,
        circularTrackColor: _lightDividerColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _darkCardColor,
        contentTextStyle: const TextStyle(color: _darkTextPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    // Define dark theme with dynamic primary color
    final themeDark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: darkColorScheme,
      scaffoldBackgroundColor: _darkBgColor,
      cardColor: _darkCardColor,
      dividerColor: _darkDividerColor,
      iconTheme: const IconThemeData(color: _darkIconColor),
      textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 16,
        ),
        bodyMedium: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 14,
        ),
        bodySmall: const TextStyle(
          color: _darkTextSecondaryColor,
          fontSize: 12,
        ),
        titleLarge: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _darkBgColor,
        foregroundColor: _darkTextPrimaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        actionsIconTheme: const IconThemeData(color: _darkIconColor),
        titleTextStyle: const TextStyle(
          color: _darkTextPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      shadowColor: _darkShadowColor,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _darkTextPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: errorColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: _darkTextSecondaryColor),
        hintStyle: const TextStyle(color: _darkTextSecondaryColor),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: _darkTextSecondaryColor,
        tileColor: _darkCardColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _darkBgColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: _darkTextSecondaryColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : _darkCardColor;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor.withAlpha(128)
              : _darkDividerColor;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : Colors.transparent;
        }),
        side: const BorderSide(color: _darkTextSecondaryColor, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        checkColor: MaterialStateProperty.all(_darkTextPrimaryColor),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          return states.contains(MaterialState.selected)
              ? primaryColor
              : _darkTextSecondaryColor;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: _darkDividerColor,
        circularTrackColor: _darkDividerColor,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightCardColor,
        contentTextStyle: const TextStyle(color: _lightTextPrimaryColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: _darkTextPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: lightTheme,
      darkTheme: themeDark,
      home: const AuthPage(),
    );
  }
}
