import 'package:flutter/material.dart';
import 'models/user_model.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_screen.dart';
import 'screens/staff/staff_screen.dart';
import 'screens/customer/customer_screen.dart';
import 'screens/profile/profile_tab.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BaoAnApp());
}

class BaoAnApp extends StatelessWidget {
  const BaoAnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bảo An - Quản lý an toàn số',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const RootGate(),
    );
  }
}

class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        if (appState.currentUser == null) {
          return const LoginScreen();
        }
        return const MainShell();
      },
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();
    final role = appState.currentUser?.role ?? UserRole.customer;

    // Dynamically choose main dashboard based on User Role
    final Widget roleScreen;
    switch (role) {
      case UserRole.admin:
        roleScreen = const AdminScreen();
        break;
      case UserRole.staff:
        roleScreen = const StaffScreen();
        break;
      case UserRole.customer:
        roleScreen = const CustomerScreen();
        break;
    }

    final pages = [
      roleScreen,
      const ProfileTab(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppColors.primaryLight,
        destinations: [
          NavigationDestination(
            icon: Icon(role.icon, color: AppColors.textMuted),
            selectedIcon: Icon(role.icon, color: AppColors.primary),
            label: role == UserRole.admin
                ? 'Quản trị'
                : role == UserRole.staff
                    ? 'Dashboard'
                    : 'Góc gia đình',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded, color: AppColors.textMuted),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}
