import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';

class DataSourceDemoScreen extends StatefulWidget {
  const DataSourceDemoScreen({super.key});

  @override
  State<DataSourceDemoScreen> createState() => _DataSourceDemoScreenState();
}

class _DataSourceDemoScreenState extends State<DataSourceDemoScreen> {
  String _customUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Source Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Cards
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Status',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              productProvider.hasInternetConnection
                                  ? Icons.wifi
                                  : Icons.wifi_off,
                              color: productProvider.hasInternetConnection
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Internet: ${productProvider.hasInternetConnection ? "Connected" : "Disconnected"}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.source,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text('Data Source: ${productProvider.dataSource}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text('Categories: ${productProvider.categories.length}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text('Total Products: ${productProvider.allProducts.length}'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        FutureBuilder<bool>(
                          future: productProvider.checkApiAvailability(),
                          builder: (context, snapshot) {
                            return Row(
                              children: [
                                Icon(
                                  Icons.api,
                                  color: snapshot.data == true ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Laravel API: ${snapshot.data == true ? "Available" : "Unavailable"}',
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Data Source Buttons
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Load Data From:',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () => productProvider.loadLocalProducts(),
                                icon: const Icon(Icons.storage),
                                label: const Text('Local File'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () => productProvider.loadOnlineProducts(),
                                icon: const Icon(Icons.cloud_download),
                                label: const Text('Online URL'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () async {
                                        try {
                                          await productProvider.loadApiProducts();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Laravel API Error: $e'),
                                              backgroundColor: Colors.red,
                                              duration: const Duration(seconds: 5),
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.api),
                                label: const Text('Laravel API'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () => productProvider.loadHybridProducts(),
                                icon: const Icon(Icons.merge_type),
                                label: const Text('Hybrid'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Custom URL Input
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Custom Online URL:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(
                            hintText: 'Enter JSON URL (e.g., GitHub raw URL)',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) => _customUrl = value,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: productProvider.isLoading || _customUrl.isEmpty
                                ? null
                                : () => productProvider.loadOnlineProducts(customUrl: _customUrl),
                            icon: const Icon(Icons.link),
                            label: const Text('Load from Custom URL'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Actions
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Actions:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () => productProvider.refreshData(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Refresh'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: productProvider.isLoading
                                    ? null
                                    : () => productProvider.checkInternetConnection(),
                                icon: const Icon(Icons.network_check),
                                label: const Text('Check Network'),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // API Test Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Testing Laravel API connection...')),
                              );

                              try {
                                final isHealthy = await productProvider.checkApiAvailability();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isHealthy
                                        ? 'Laravel API is working! ✅'
                                        : 'Laravel API is not available ❌'),
                                    backgroundColor: isHealthy ? Colors.green : Colors.red,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('API Test Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.bug_report),
                            label: const Text('Test Laravel API Connection'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading Indicator
                if (productProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading data...'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
