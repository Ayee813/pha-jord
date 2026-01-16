# Phajord


A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# code structure 
```
lib/
│
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── strings.dart
│   │   └── assets.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── text_theme.dart
│   │
│   ├── localization/
│   │   ├── app_localizations.dart
│   │   └── language_provider.dart
│   │
│   └── utils/
│       ├── helpers.dart
│       └── validators.dart
│
├── features/
│   ├── home/
│   │   ├── home_page.dart
│   │   ├── home_controller.dart
│   │   └── home_widgets.dart
│   │
│   ├── settings/
│   │   ├── settings_page.dart
│   │   └── language_selector.dart
│   │
│   └── auth/
│       ├── login_page.dart
│       └── register_page.dart
│
├── shared/
│   ├── widgets/
│   │   ├── app_button.dart
│   │   ├── app_text_field.dart
│   │   └── app_dialog.dart
│   │
│   └── services/
│       ├── api_service.dart
│       └── storage_service.dart
│
└── routes/
    └── app_routes.dart
```