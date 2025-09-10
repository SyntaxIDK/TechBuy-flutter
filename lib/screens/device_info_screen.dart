import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_capabilities_provider.dart';

class DeviceInfoScreen extends StatelessWidget {
  const DeviceInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Information'),
        actions: [
          Consumer<DeviceCapabilitiesProvider>(
            builder: (context, deviceProvider, child) {
              return IconButton(
                onPressed: () {
                  deviceProvider.refreshLocation();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
              );
            },
          ),
        ],
      ),
      body: Consumer<DeviceCapabilitiesProvider>(
        builder: (context, deviceProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Network Connectivity
                _buildInfoSection(
                  context,
                  title: 'Network Connectivity',
                  icon: Icons.wifi,
                  children: [
                    _buildInfoRow('Connection Type', deviceProvider.connectivityStatus),
                    _buildInfoRow('Status', deviceProvider.isConnected ? 'Connected' : 'Disconnected'),
                  ],
                ),

                // Battery Information
                _buildInfoSection(
                  context,
                  title: 'Battery Information',
                  icon: Icons.battery_full,
                  children: [
                    _buildInfoRow('Battery Level', '${deviceProvider.batteryLevel}%'),
                    _buildInfoRow('Battery State', _getBatteryStateText(deviceProvider.batteryState)),
                    _buildInfoRow('Status', deviceProvider.batteryStatusText),
                  ],
                ),

                // Location Services
                _buildInfoSection(
                  context,
                  title: 'Location Services',
                  icon: Icons.location_on,
                  children: [
                    _buildInfoRow('Permission', deviceProvider.locationPermissionGranted ? 'Granted' : 'Denied'),
                    if (deviceProvider.currentPosition != null) ...[
                      _buildInfoRow('Latitude', deviceProvider.currentPosition!.latitude.toStringAsFixed(6)),
                      _buildInfoRow('Longitude', deviceProvider.currentPosition!.longitude.toStringAsFixed(6)),
                      _buildInfoRow('Accuracy', '${deviceProvider.currentPosition!.accuracy.toStringAsFixed(1)}m'),
                      _buildInfoRow('Altitude', '${deviceProvider.currentPosition!.altitude.toStringAsFixed(1)}m'),
                      _buildInfoRow('Speed', '${deviceProvider.currentPosition!.speed.toStringAsFixed(1)} m/s'),
                    ] else if (deviceProvider.locationPermissionGranted) ...[
                      _buildInfoRow('Status', 'Getting location...'),
                    ] else ...[
                      _buildInfoRow('Status', 'Permission required'),
                    ],
                  ],
                ),

                // Motion Sensors
                _buildInfoSection(
                  context,
                  title: 'Motion Sensors',
                  icon: Icons.sensors,
                  children: [
                    const Text(
                      'Accelerometer',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('X-axis', deviceProvider.accelerometerX.toStringAsFixed(3)),
                    _buildInfoRow('Y-axis', deviceProvider.accelerometerY.toStringAsFixed(3)),
                    _buildInfoRow('Z-axis', deviceProvider.accelerometerZ.toStringAsFixed(3)),
                    const SizedBox(height: 16),
                    const Text(
                      'Gyroscope',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('X-axis', deviceProvider.gyroscopeX.toStringAsFixed(3)),
                    _buildInfoRow('Y-axis', deviceProvider.gyroscopeY.toStringAsFixed(3)),
                    _buildInfoRow('Z-axis', deviceProvider.gyroscopeZ.toStringAsFixed(3)),
                  ],
                ),

                // Light Sensor
                _buildInfoSection(
                  context,
                  title: 'Ambient Light Sensor',
                  icon: Icons.light_mode,
                  children: [
                    _buildInfoRow('Light Level', '${deviceProvider.lightLevel.toStringAsFixed(1)} lux'),
                    _buildInfoRow('Brightness', _getLightDescription(deviceProvider.lightLevel)),
                  ],
                ),

                // Contacts Information
                _buildInfoSection(
                  context,
                  title: 'Contacts Access',
                  icon: Icons.contacts,
                  children: [
                    _buildInfoRow('Permission', deviceProvider.contactsPermissionGranted ? 'Granted' : 'Denied'),
                    if (deviceProvider.contactsPermissionGranted) ...[
                      _buildInfoRow('Total Contacts', '${deviceProvider.contactCount}'),
                    ] else ...[
                      _buildInfoRow('Status', 'Permission required to access contacts'),
                    ],
                  ],
                ),

                // Live Sensor Visualization
                _buildInfoSection(
                  context,
                  title: 'Live Sensor Data',
                  icon: Icons.graphic_eq,
                  children: [
                    const Text(
                      'Real-time sensor readings:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // Accelerometer visualization
                    const Text('Accelerometer (m/s²)'),
                    const SizedBox(height: 8),
                    _buildSensorBar('X', deviceProvider.accelerometerX, Colors.red),
                    _buildSensorBar('Y', deviceProvider.accelerometerY, Colors.green),
                    _buildSensorBar('Z', deviceProvider.accelerometerZ, Colors.blue),

                    const SizedBox(height: 16),

                    // Gyroscope visualization
                    const Text('Gyroscope (rad/s)'),
                    const SizedBox(height: 8),
                    _buildSensorBar('X', deviceProvider.gyroscopeX, Colors.orange),
                    _buildSensorBar('Y', deviceProvider.gyroscopeY, Colors.purple),
                    _buildSensorBar('Z', deviceProvider.gyroscopeZ, Colors.teal),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorBar(String axis, double value, Color color) {
    // Normalize value for visualization (-10 to 10 range)
    final normalizedValue = (value.clamp(-10, 10) + 10) / 20;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              axis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: normalizedValue,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
            child: Text(
              value.toStringAsFixed(2),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String _getBatteryStateText(dynamic batteryState) {
    switch (batteryState.toString()) {
      case 'BatteryState.charging':
        return 'Charging';
      case 'BatteryState.discharging':
        return 'Discharging';
      case 'BatteryState.full':
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  String _getLightDescription(double lux) {
    if (lux < 1) return 'Very Dark';
    if (lux < 10) return 'Dark';
    if (lux < 50) return 'Dim';
    if (lux < 200) return 'Normal Indoor';
    if (lux < 500) return 'Bright Indoor';
    if (lux < 1000) return 'Very Bright';
    return 'Outdoor/Sunlight';
  }
}
