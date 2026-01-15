import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/calendar_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/login_screen.dart';
import 'providers/event_provider.dart';
import 'providers/shopping_provider.dart';
import 'providers/family_member_provider.dart';
import 'providers/current_user_provider.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDateFormatting('it', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FamilyMemberProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => EventProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CurrentUserProvider()),
      ],
      child: MaterialApp(
        title: 'Gestione Familiare',
        debugShowCheckedModeBanner: false,
        locale: const Locale('it', 'IT'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('it', 'IT'),
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 16),
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper to handle authentication and user identity selection
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Sign in anonymously if not already signed in
      if (_authService.currentUser == null) {
        await _authService.signInAnonymously();
      }
      
      // Check for saved user identity
      if (mounted) {
        final currentUserProvider =
            Provider.of<CurrentUserProvider>(context, listen: false);
        final familyMemberProvider =
            Provider.of<FamilyMemberProvider>(context, listen: false);

        final savedUserId = await currentUserProvider.loadSavedUserId();

        if (savedUserId != null) {
          // Wait for family members to finish loading
          await familyMemberProvider.waitForLoading();

          // Try to find the saved user in the family members list
          final members = familyMemberProvider.familyMembers;
          final savedMember = members.where((m) => m.id == savedUserId).toList();

          if (savedMember.isNotEmpty) {
            currentUserProvider.initializeWithMember(savedMember.first);
          } else {
            currentUserProvider.markInitialized();
          }
        } else {
          currentUserProvider.markInitialized();
        }
      }
      
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      print('Error initializing: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Initializing...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Watch current user provider to react to login/logout
    return Consumer<CurrentUserProvider>(
      builder: (context, currentUserProvider, child) {
        if (!currentUserProvider.isInitialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!currentUserProvider.hasUser) {
          return const LoginScreen();
        }

        return const MainScreen();
      },
    );
  }
}

/// Main screen with bottom navigation
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const CalendarScreen(),
    const ShoppingListScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        height: 70,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Calendario',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Spesa',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
