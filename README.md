# MΛZID (ADHD Companion)

A Flutter app that supports parents of children with ADHD. Parents manage
routines, tasks, activities and behavior observations; children complete
tasks, earn points and check in with their mood.

## Features

- **Parent dashboard:** routines, activities, tasks, observations, progress.
- **Child area:** PIN login, daily tasks with points and rewards, focus timer,
  mood check-in.
- **Email verification (OTP):** talks to the ASP.NET Core backend
  (`ADHD.Backend`).
- **Ask AI:** placeholder screen with a fixed reply (not connected to a real
  AI service yet).

> Not connected yet: email/password sign in, password reset, SMS
> verification, Google/Apple sign in.

## Getting started

```bash
flutter pub get
flutter run
```

### Backend address

The OTP screen calls the backend at `http://10.0.2.2:5187`, which is how the
Android emulator reaches the host machine. Change it in
`lib/core/app_config.dart` when running on a real device or in production.

## Project structure

```
lib/
  core/          shared colors and configuration
  screens/       parent-side screens (AI, progress, behavior tracking)
  main.dart      app entry, welcome, sign up, OTP, sign in
  parent.dart    parent dashboard
  child.dart     child state and screens
  tasks.dart, add_task.dart, add_routine.dart, add_activity_page.dart,
  daily_routine.dart, view_routine.dart, activity_calendar_page.dart
test/            widget tests
```

## Tests

```bash
flutter test
```
