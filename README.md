# Highlights App

Highlights App is an unfinished Flutter project for saving and organizing highlight moments from shows, games, videos, podcasts, or any media where useful timestamps matter.

This repository is still a work in progress and is being kept so it can be picked up again later. The current codebase already has the foundation for records, collections, timestamps, local storage, image picking, and a dark/orange mobile UI, but it is not yet a finished production app.

## Current idea

The app is meant to help you mark memorable moments while watching or reviewing something.

Example use cases:

- Track highlights from anime, TV shows, or movies
- Save important podcast/video timestamps
- Organize highlights by collection, season, or episode
- Add notes and images to records or timestamp entries
- Keep a local searchable archive of moments worth revisiting

## Current status

Status: unfinished / paused

The project is not abandoned. It is being documented now so the intent is clear when development resumes later.

What currently exists:

- Flutter app scaffold
- Dark theme with orange/amber accents
- Record model
- Collection model
- Timestamp model
- Provider-based state management
- SQLite local database helper
- Main/home/settings screens
- Record screens for timing and timestamp capture
- Image picker dependency for attaching images
- Local persistence dependencies through `sqflite`, `path_provider`, and `shared_preferences`

What still likely needs work:

- UI polish and layout cleanup
- More complete playback/timer controls
- Timestamp editing flow refinement
- Better empty states and onboarding
- Testing on Android/device builds
- Possible data export/import
- App icon/splash asset verification
- General bug fixing and code cleanup

## Tech stack

- Flutter
- Dart
- Provider
- SQLite via `sqflite`
- `path_provider`
- `shared_preferences`
- `image_picker`
- `intl`
- `audioplayers`

## Project structure

```text
lib/
  main.dart
  models/
    collection.dart
    record.dart
    timestamp.dart
  providers/
    collection_provider.dart
    record_provider.dart
  screens/
    collection_info_screen.dart
    main_screen/
    record_screen/
  services/
    database_helper.dart
    navigation_service.dart
  sheets/
    edit_collection_sheet.dart
```

## How to run later

Make sure Flutter is installed, then from the project folder run:

```bash
flutter pub get
flutter run
```

For a quick code check:

```bash
flutter analyze
```

For tests:

```bash
flutter test
```

## Notes for future development

The package name in `pubspec.yaml` is currently:

```yaml
name: highlight_marker
```

The app title shown in Flutter is currently:

```dart
title: 'Highlights'
```

Before continuing development, it may be worth deciding whether the final project name should be `Highlights App`, `Highlight Marker`, or something else, then renaming the package/app consistently.

## Personal note

This is an unfinished app idea that will be picked up later. The main goal right now is to preserve the existing work and document what the project was supposed to become.
