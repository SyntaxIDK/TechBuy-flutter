# TechBuy Flutter - Online Data Fetching Guide

## What is Online JSON Data Fetching?

Your TechBuy app now supports loading product data from three different sources:

### 1. **Local JSON File** 📁
- Data stored in `assets/data/products.json`
- Always available, even without internet
- Fast loading, perfect for offline use

### 2. **Online JSON File** 🌐
- Data fetched from a URL on the internet (like GitHub)
- Can be updated without rebuilding the app
- Requires internet connection

### 3. **Hybrid Mode** 🔄
- Combines both local and online data
- Tries online first, falls back to local if needed
- Best user experience

## How to Host JSON on GitHub

1. **Create a GitHub Repository:**
   - Go to github.com and create a new repository
   - Make it public (private repos need authentication)

2. **Upload Your JSON File:**
   - Upload your `products.json` file to the repository
   - Commit the changes

3. **Get the Raw URL:**
   - Click on your JSON file in GitHub
   - Click the "Raw" button
   - Copy the URL (it looks like: `https://raw.githubusercontent.com/username/repo/main/products.json`)

4. **Update Your App:**
   - Replace the `_onlineDataUrl` in `ProductProvider` with your GitHub raw URL

## How to Use the New Features

### In Your ProductProvider:

```dart
// Load only from local file
await productProvider.loadLocalProducts();

// Load only from online URL
await productProvider.loadOnlineProducts();

// Load with hybrid approach (recommended)
await productProvider.loadHybridProducts();

// Load from custom URL
await productProvider.loadOnlineProducts(customUrl: "your-github-raw-url");

// Check current data source
String source = productProvider.dataSource; // 'local', 'online', or 'hybrid'

// Check internet connection
bool hasInternet = productProvider.hasInternetConnection;

// Refresh current data
await productProvider.refreshData();
```

### Demo Screen Usage:

I've created a demo screen (`DataSourceDemoScreen`) that shows:
- Current connection status
- Data source information
- Buttons to test different loading methods
- Custom URL input field

## Current Setup

✅ **Already Working:**
- Local JSON loading from `assets/data/products.json`
- HTTP dependency installed
- Connectivity checking

✅ **Newly Added:**
- Online JSON fetching capability
- Hybrid data loading
- Sample online data file (`assets/data/online_products.json`)
- Demo screen for testing

## Example GitHub Setup

If you want to host your products on GitHub:

1. Create a repo called `techbuy-data`
2. Upload your `products.json` file
3. Get the raw URL: `https://raw.githubusercontent.com/yourusername/techbuy-data/main/products.json`
4. Update the `_onlineDataUrl` constant in your `ProductProvider`

## Benefits of Online Data

- **Real-time Updates**: Change products without app updates
- **Dynamic Content**: Add seasonal products, promotions
- **Centralized Management**: One data source for multiple apps
- **A/B Testing**: Different data for different users
