import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/device_capabilities_provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TechBuyApp());
}

class TechBuyApp extends StatelessWidget {
  const TechBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => DeviceCapabilitiesProvider()),
      ],
      child: Consumer2<DeviceCapabilitiesProvider, AuthProvider>(
        builder: (context, deviceProvider, authProvider, child) {
          return MaterialApp(
            title: 'TechBuy - Premium Tech Store',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: authProvider.isAuthenticated
                ? const MainScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
