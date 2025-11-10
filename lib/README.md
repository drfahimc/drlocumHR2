# DrLocumDr - Doctor Mobile App

## Project Structure

This Flutter project follows a clean architecture pattern with proper separation of concerns.

```
lib/
├── constants/          # App-wide constants
│   ├── app_colors.dart    # Color definitions
│   └── app_strings.dart   # String constants
│
├── models/            # Data models
│   ├── job_model.dart      # Job data model
│   └── schedule_model.dart # Schedule data model
│
├── screens/          # Screen widgets (full pages)
│   ├── doctor_dashboard.dart  # Main dashboard screen
│   └── my_jobs_screen.dart    # My Jobs screen
│
├── widgets/          # Reusable widget components
│   ├── common/           # Common widgets used across app
│   │   ├── bottom_nav_bar.dart
│   │   ├── empty_state.dart
│   │   ├── tab_bar_widget.dart
│   │   └── top_nav_bar.dart
│   ├── dashboard/        # Dashboard-specific widgets
│   │   ├── schedule_job_card.dart
│   │   └── stat_card.dart
│   └── jobs/             # Job-related widgets
│       └── job_card.dart
│
├── utils/            # Utility functions and helpers
│   └── README.md
│
├── main.dart         # App entry point
└── firebase_options.dart
```

## Architecture Principles

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Reusability**: Common widgets are extracted and reused
3. **Consistency**: Colors, strings, and styles are centralized
4. **Maintainability**: Clear folder structure makes it easy to find and modify code

## Widget Organization

### Common Widgets
- **TopNavBar**: Top navigation bar with badge, title, and notifications
- **BottomNavBar**: Bottom navigation bar with 4 tabs
- **TabBarWidget**: Reusable tab bar component
- **EmptyState**: Empty state display for lists

### Dashboard Widgets
- **StatCard**: Statistics card with icon, title, and value
- **ScheduleJobCard**: Card displaying schedule information

### Job Widgets
- **JobCard**: Card displaying job details with status and actions

## Models

All data models include:
- Factory constructors for JSON deserialization
- `toJson()` methods for serialization
- Type-safe properties

## Constants

- **AppColors**: Centralized color definitions
- **AppStrings**: All user-facing strings

## Best Practices

1. Always use constants from `AppColors` and `AppStrings`
2. Extract reusable widgets to appropriate folders
3. Use models for data structures
4. Keep screens focused on layout and state management
5. Delegate UI rendering to widget components

