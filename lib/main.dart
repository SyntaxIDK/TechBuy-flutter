import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/device_capabilities_provider.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const TechBuyApp());
}

class TechBuyApp extends StatelessWidget {
  const TechBuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProductProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => DeviceCapabilitiesProvider()),
      ],
      child: Consumer<DeviceCapabilitiesProvider>(
        builder: (context, deviceProvider, child) {
          return MaterialApp(
            title: 'TechBuy - Premium Tech Store',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
