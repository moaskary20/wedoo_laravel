# Handyman Flutter App

A Flutter mobile application for handyman services with location-based functionality and Arabic support.

## Features

### 🎯 Location Services
- **Automatic Location Detection**: Requests location permission on first launch
- **Coordinate Storage**: Saves latitude and longitude to SharedPreferences
- **Address Resolution**: Converts coordinates to readable addresses
- **Device Tracking**: Uses unique device ID for location tracking
- **Backend Integration**: Saves location data to Laravel backend API

### 🏠 Main Screens
1. **Location Screen**: Handles location permission and storage
2. **Main Selection Screen**: Two service options (صنايعي / محلات ومعارض)
3. **Category Grid**: 18 circular category icons in 3x6 grid
4. **Category Detail**: Individual category with action buttons

### 🛠 Categories (18 Total)
- سباكة (Plumbing)
- كهرباء (Electrical)
- نجارة (Carpentry)
- دهان (Painting)
- تكييف (HVAC)
- أرضيات (Flooring)
- أسقف (Roofing)
- بلاط (Tiling)
- زجاج (Glass Work)
- حدادة (Metal Work)
- تنظيف (Cleaning)
- بستنة (Gardening)
- أمن (Security)
- أقفال (Locksmith)
- إصلاح أجهزة (Appliance Repair)
- أثاث (Furniture)
- نقل (Moving)
- صيانة عامة (General Maintenance)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   └── category.dart           # Category data model
└── screens/
    ├── location_screen.dart    # Real location handling
    ├── demo_location_screen.dart # Demo location (no permissions)
    ├── main_screen.dart        # Main selection screen
    ├── category_grid_screen.dart # 18 categories grid
    └── category_detail_screen.dart # Category details
```

## Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Location Permissions
The app requires location permissions. For testing without permissions, the app uses `DemoLocationScreen` which simulates location data.

## Location Screen Features

### Real Location Screen (`location_screen.dart`)
- Requests location permissions
- Gets current GPS coordinates
- Resolves address from coordinates
- Saves to SharedPreferences
- Sends to backend API
- Handles permission denials gracefully

### Demo Location Screen (`demo_location_screen.dart`)
- Simulates location permission flow
- Uses demo coordinates (Cairo, Egypt)
- No actual location permissions required
- Perfect for testing and development

## SharedPreferences Storage

The app stores the following location data:

```dart
// Location coordinates
await prefs.setDouble('latitude', position.latitude);
await prefs.setDouble('longitude', position.longitude);

// Location metadata
await prefs.setBool('location_saved', true);
await prefs.setString('location_timestamp', DateTime.now().toIso8601String());
await prefs.setString('device_id', deviceId);

// Address information
await prefs.setString('address', address);
await prefs.setString('city', city);
await prefs.setString('country', country);
```

## API Integration

### Backend Endpoint
- **URL**: `http://localhost:8000/api/user-locations`
- **Method**: POST
- **Data**: Device ID, coordinates, address info

### Category Endpoint
- **URL**: `http://localhost:8000/api/categories`
- **Method**: GET
- **Response**: List of 18 categories with Arabic names and icons

## Error Handling

The app includes comprehensive error handling for:
- Location permission denials
- GPS service unavailability
- Network connectivity issues
- API communication failures
- Invalid coordinates

## UI/UX Features

- **Arabic RTL Support**: Proper right-to-left text layout
- **Circular Category Icons**: Beautiful 3-column grid layout
- **Loading States**: Smooth loading indicators
- **Error Recovery**: Retry buttons and fallback options
- **Responsive Design**: Works on different screen sizes

## Development Notes

### Switching Between Demo and Real Location
In `main.dart`, change the home widget:

```dart
// For testing (no permissions required)
home: const DemoLocationScreen(),

// For production (requires location permissions)
home: const LocationScreen(),
```

### Android Permissions
Required permissions in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

## Dependencies

- `geolocator`: Location services
- `geocoding`: Address resolution
- `shared_preferences`: Local storage
- `device_info_plus`: Device identification
- `http`: API communication

## Testing

Run the app with:
```bash
flutter run
```

The demo location screen will simulate the location flow without requiring actual permissions, making it perfect for development and testing.