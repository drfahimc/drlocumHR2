# DrLocumDr - Doctor Mobile Application

A comprehensive Flutter mobile application for doctors and HR managers to manage job postings, schedules, hospitals, and more. Built with Flutter and integrated with Firebase backend.

## 📱 Features

- **Dashboard**: View available jobs, schedules, and notifications
- **Job Management**: Browse, create, and manage job postings
- **Hospital Management**: Add, edit, and manage hospital information
- **Doctor Pool**: Manage your pool of doctors
- **Schedule Management**: View today's and tomorrow's schedules
- **Notifications**: Real-time notifications
- **Reports & Analytics**: Communicate with admin
- **Ratings & Feedback**: View feedback and ratings
- **Settings**: Customize app settings

## 🚀 Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.7.2 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter doctor`

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **VS Code** with Flutter extensions

4. **Git** for version control

5. **Firebase Account** (for backend services)

## 📦 Installation

### Step 1: Clone the Repository

```bash
git clone https://github.com/drfahimc/drlocumHR2.git
cd drlocumHR2
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Firebase Setup

#### Option A: Using Existing Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `drlocum-5d4e9`
3. Get your Firebase configuration

#### Option B: Create New Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Follow the setup wizard
4. Enable the following services:
   - **Authentication** (Email/Password)
   - **Cloud Firestore**
   - **Storage** (optional)

#### Configure Firebase for Flutter

1. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. Configure Firebase:
   ```bash
   flutterfire configure
   ```
   - Select your Firebase project
   - Select platforms: Android, iOS, Web (as needed)

3. This will generate `lib/firebase_options.dart`

### Step 4: Firestore Setup

#### Deploy Security Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Copy the contents of `firestore.rules` from this repository
3. Paste into the rules editor
4. Click **Publish**

**For Development/Testing (Temporary):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **Warning**: Development rules allow anyone to read/write. Only use for testing!

#### Deploy Indexes

1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index" for each required index (see `FIRESTORE_SETUP.md`)
3. Or use Firebase CLI:
   ```bash
   firebase deploy --only firestore:indexes
   ```

### Step 5: Enable Authentication

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable **Email/Password**
3. Click **Save**

### Step 6: Create Test User (Optional)

1. Go to Firebase Console → Authentication → Users
2. Click **Add user**
3. Enter email and password
4. Create corresponding document in Firestore `users` collection:
   ```json
   {
     "email": "test@example.com",
     "userType": "hr",
     "isActive": true,
     "isVerified": true,
     "createdAt": "2024-01-01T00:00:00Z",
     "updatedAt": "2024-01-01T00:00:00Z"
   }
   ```

## 🏃 Running the App

### Run on Web (Chrome)

```bash
flutter run -d chrome
```

### Run on Android

1. Connect an Android device or start an emulator
2. Run:
   ```bash
   flutter run
   ```

### Run on iOS (Mac only)

1. Connect an iOS device or start a simulator
2. Run:
   ```bash
   flutter run
   ```

### Run on Windows

```bash
flutter run -d windows
```

## 📁 Project Structure

```
drlocumdr/
├── lib/
│   ├── constants/          # App constants (colors, strings)
│   ├── models/             # Data models
│   ├── screens/            # App screens
│   ├── services/           # Firebase services
│   ├── widgets/             # Reusable widgets
│   ├── utils/              # Utility functions
│   ├── firebase_options.dart
│   └── main.dart           # App entry point
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── web/                    # Web-specific files
├── windows/                # Windows-specific files
├── firestore.rules         # Firestore security rules
├── firestore.indexes.json  # Firestore indexes
├── firebase.json           # Firebase configuration
└── pubspec.yaml            # Flutter dependencies
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory (optional):
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
```

### Firebase Configuration

The app uses `lib/firebase_options.dart` for Firebase configuration. This file is generated by FlutterFire CLI and should not be manually edited.

## 🐛 Troubleshooting

### Common Issues

#### 1. Firebase Initialization Error

**Error**: `PlatformException(channel-error, Unable to establish connection...)`

**Solution**:
- Ensure Firebase is properly configured for web
- Check `firebase_options.dart` has correct web configuration
- Verify Firebase SDK scripts are not manually added to `web/index.html`

#### 2. Permission Denied Error

**Error**: `[cloud_firestore/permission-denied] Missing or insufficient permissions`

**Solution**:
- Deploy Firestore security rules (see Step 4 above)
- Ensure user is authenticated (if using production rules)
- For testing, use development rules temporarily

#### 3. Missing Index Error

**Error**: `The query requires an index`

**Solution**:
- Click the link in the error message to create the index automatically
- Or manually create indexes (see `FIRESTORE_SETUP.md`)
- Wait for indexes to build (1-5 minutes)

#### 4. Package Not Found

**Error**: `Target of URI doesn't exist: 'package:...'`

**Solution**:
```bash
flutter pub get
flutter clean
flutter pub get
```

#### 5. Build Errors

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Additional Documentation

- **Firestore Setup**: See `FIRESTORE_SETUP.md` for detailed Firestore configuration
- **Quick Fix Guide**: See `QUICK_FIX.md` for quick troubleshooting
- **Backend Integration**: See `BACKEND_INTEGRATION_ANALYSIS.md` for backend details

## 🛠️ Development

### Adding New Features

1. Create models in `lib/models/`
2. Create services in `lib/services/`
3. Create screens in `lib/screens/`
4. Create widgets in `lib/widgets/`

### Code Style

- Follow Flutter/Dart style guide
- Use meaningful variable names
- Add comments for complex logic
- Keep widgets small and reusable

## 📝 Dependencies

Key dependencies:
- `firebase_core`: Firebase core functionality
- `cloud_firestore`: Firestore database
- `firebase_auth`: Authentication
- `firebase_storage`: File storage
- `url_launcher`: Open URLs, phone, maps
- `intl`: Date/time formatting

See `pubspec.yaml` for complete list.

## 🔐 Security Notes

- **Never commit** `API.json` or other credential files
- Use environment variables for sensitive data
- Keep Firestore security rules up to date
- Use production security rules in production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

[Add your license here]

## 👥 Support

For issues and questions:
- Open an issue on GitHub
- Check `QUICK_FIX.md` for common solutions
- Review `FIRESTORE_SETUP.md` for Firebase setup

## 🎯 Next Steps

1. ✅ Set up Firebase project
2. ✅ Deploy Firestore rules and indexes
3. ✅ Enable authentication
4. ✅ Create test users
5. ✅ Run the app
6. ✅ Test all features

---

**Happy Coding! 🚀**
