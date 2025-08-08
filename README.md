# Flat Bill Go

A Flutter app for managing utility bills and property details.

## Features

- 📊 **Bill Management**: Create, view, and manage utility bills
- 🏠 **Property Details**: Store property information
- 💰 **Cost Calculation**: Automatic calculation of electricity, water, and sanitation costs
- 📄 **PDF Export**: Export bills as PDF (works on all platforms)
- 📱 **Cross Platform**: Works on iOS, Android, and Web

## Live Demo

🌐 **Web App**: [https://garethbaumgart.github.io/flat-bill-go](https://garethbaumgart.github.io/flat-bill-go)

## Development

```bash
# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on iOS
flutter run -d ios

# Run on Android
flutter run -d android

# Run tests
flutter test

# Build for web
flutter build web
```

## Deployment

This app is automatically deployed to GitHub Pages when changes are pushed to the main branch.

### Manual Deployment

1. Build the web app:
   ```bash
   flutter build web
   ```

2. The built files are in `build/web/`

3. Deploy to any static hosting service (Netlify, Vercel, etc.)

## Architecture

- **State Management**: Riverpod
- **Storage**: SharedPreferences
- **PDF Generation**: pdf package
- **Platform**: Flutter (iOS, Android, Web)

## License

MIT License