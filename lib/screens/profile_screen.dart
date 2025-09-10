import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_capabilities_provider.dart';
import 'device_info_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to TechBuy',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Demo User Account',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Authentication will be implemented with Laravel API or Firebase',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Device Capabilities Section
            Text(
              'Device Capabilities',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Consumer<DeviceCapabilitiesProvider>(
              builder: (context, deviceProvider, child) {
                return Column(
                  children: [
                    // Connectivity Status
                    _buildCapabilityCard(
                      context,
                      icon: Icons.wifi,
                      title: 'Network Connectivity',
                      subtitle: deviceProvider.connectivityStatus,
                      status: deviceProvider.isConnected,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Battery Status
                    _buildCapabilityCard(
                      context,
                      icon: Icons.battery_full,
                      title: 'Battery Status',
                      subtitle: deviceProvider.batteryStatusText,
                      status: deviceProvider.batteryLevel > 20,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Location Services
                    _buildCapabilityCard(
                      context,
                      icon: Icons.location_on,
                      title: 'Location Services',
                      subtitle: deviceProvider.locationPermissionGranted
                          ? (deviceProvider.currentPosition != null
                              ? 'Location: ${deviceProvider.currentPosition!.latitude.toStringAsFixed(4)}, ${deviceProvider.currentPosition!.longitude.toStringAsFixed(4)}'
                              : 'Getting location...')
                          : 'Permission required',
                      status: deviceProvider.locationPermissionGranted,
                      onTap: () {
                        if (deviceProvider.locationPermissionGranted) {
                          deviceProvider.refreshLocation();
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Sensors
                    _buildCapabilityCard(
                      context,
                      icon: Icons.sensors,
                      title: 'Motion Sensors',
                      subtitle: 'Accelerometer & Gyroscope Active',
                      status: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Light Sensor
                    _buildCapabilityCard(
                      context,
                      icon: Icons.light_mode,
                      title: 'Ambient Light',
                      subtitle: '${deviceProvider.lightLevel.toStringAsFixed(1)} lux',
                      status: deviceProvider.lightLevel > 0,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),

                    // Contacts
                    _buildCapabilityCard(
                      context,
                      icon: Icons.contacts,
                      title: 'Contacts Access',
                      subtitle: deviceProvider.contactsPermissionGranted
                          ? '${deviceProvider.contactCount} contacts found'
                          : 'Permission required',
                      status: deviceProvider.contactsPermissionGranted,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeviceInfoScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // App Settings Section
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildSettingsCard(
              context,
              icon: Icons.palette,
              title: 'Theme',
              subtitle: 'Follows system setting (Light/Dark mode)',
              onTap: () {
                _showThemeDialog(context);
              },
            ),

            _buildSettingsCard(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              subtitle: 'Manage your notification preferences',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification settings - Coming soon!'),
                  ),
                );
              },
            ),

            _buildSettingsCard(
              context,
              icon: Icons.help,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                _showHelpDialog(context);
              },
            ),

            _buildSettingsCard(
              context,
              icon: Icons.info,
              title: 'About TechBuy',
              subtitle: 'Version 1.0.0 - Premium Tech Store',
              onTap: () {
                _showAboutDialog(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool status,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: status ? Colors.green : Colors.red,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(
          status ? Icons.check_circle : Icons.cancel,
          color: status ? Colors.green : Colors.red,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings'),
        content: const Text(
          'This app automatically follows your device\'s theme setting. '
          'To change between light and dark mode, update your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TechBuy - Premium Tech Store'),
            SizedBox(height: 16),
            Text('Features:'),
            Text('• Browse MacBooks, iPhones, Android phones, and laptops'),
            Text('• Add products to favorites and cart'),
            Text('• Search for products'),
            Text('• View detailed product specifications'),
            Text('• Device capabilities integration'),
            SizedBox(height: 16),
            Text('This is a demo application showcasing Flutter development with state management and device capabilities.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'TechBuy',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.shopping_bag,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text('Premium Tech Store built with Flutter'),
        const SizedBox(height: 8),
        const Text('Features state management, device capabilities, and modern UI design.'),
        const SizedBox(height: 8),
        const Text('Ready for integration with Laravel API or Firebase for authentication and data management.'),
      ],
    );
  }
}
