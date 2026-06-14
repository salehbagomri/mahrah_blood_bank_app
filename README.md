# Mahrah Blood Bank

Blood donor management application for Al-Mahrah Governorate, Yemen.

![Version](https://img.shields.io/badge/version-1.0.3-blue)
![Platform](https://img.shields.io/badge/platform-Android-green)
![License](https://img.shields.io/badge/license-All%20Rights%20Reserved-red)

## Overview

Mahrah Blood Bank is a mobile application that maintains a registry of voluntary blood donors across Al-Mahrah Governorate, Yemen. The application enables the public to search for donors by blood type and district, while providing hospital administrators with a dedicated dashboard to manage donor records and generate statistical reports. A system administrator role handles hospital account management and donor report moderation.

The backend runs on Supabase (PostgreSQL) and routes through a Cloudflare Worker reverse proxy to ensure reliable connectivity from within Yemen, where direct access to Supabase domains may be restricted.

## Features

### Public

- Search blood donors by blood type (A+, A-, B+, B-, AB+, AB-, O+, O-) and district
- Direct contact via phone call or WhatsApp
- Blood donation awareness and educational content
- Submit reports for inaccurate or invalid donor records

### Hospital Administration

- Manage donor records: add, edit, suspend, and delete
- Advanced search with multiple filters
- Track last donation date and eligibility status
- Export donor data as Excel spreadsheets and PDF reports
- Dashboard with statistical summaries by blood type and district

### System Administration

- Hospital account management (create, edit credentials)
- Review and moderate donor reports submitted by the public
- System-wide donor statistics overview

## Technology

| Component | Technology |
|---|---|
| Framework | Flutter 3 / Dart 3.9 |
| Backend | Supabase (PostgreSQL + Auth + Row-Level Security) |
| Network proxy | Cloudflare Workers |
| State management | Provider / GetIt |
| Offline cache | Hive |
| Error tracking | Firebase Crashlytics |
| Typography | IBM Plex Sans Arabic |
| Export | Excel (`excel`) / PDF (`pdf`, `printing`) |

## Architecture

The application uses a layered architecture with Provider for reactive state management and GetIt as a service locator for dependency injection. Screens are organized by user role (`admin`, `hospital`, `donor`, `auth`, `home`, `info`) under `lib/screens/`.

Three user roles are enforced at two levels: the application layer (Provider-based auth state) and the database layer (Row-Level Security policies in Supabase). All network traffic routes through a Cloudflare Worker reverse proxy to maintain connectivity in environments where Supabase domains are restricted.

The Cloudflare Worker source is in `cloudflare-worker/worker.js` and can be deployed independently to any Cloudflare account.

## Getting Started

### Prerequisites

- Flutter SDK 3.9 or later
- A Supabase project with the required schema and RLS policies
- (Optional) A Cloudflare Worker configured as a reverse proxy

### Configuration

Supply your Supabase credentials at build time via `--dart-define`:

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or place them in a `.env.json` file and pass `--dart-define-from-file=.env.json`.

Firebase Crashlytics requires `google-services.json` (Android) placed in `android/app/`. The application runs without Firebase if the file is absent.

## Building

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Run tests
flutter test
```

## Project Information

| | |
|---|---|
| Application name | Mahrah Blood Bank (بنك دم المهرة) |
| Package ID | com.bagomri.mahrahbloodbank |
| Version | 1.0.3 (build 6) |
| Minimum Android | 5.0 (API 21) |
| Target Android | 14 (API 34) |
| UI language | Arabic (RTL) |
| Platform | Android |

## Privacy

This application collects donor contact information (name, phone number, blood type, district) for the purpose of facilitating voluntary blood donation in Al-Mahrah Governorate. The full privacy policy is available at:

https://salehbagomri.github.io/mahrah-blood-bank-privacy/

## License

Copyright (c) 2026 Saleh Bagomri. All rights reserved.

This source code is made publicly available for reference and inspection only. No permission is granted to use, copy, modify, merge, publish, distribute, sublicense, or sell any portion of this software without explicit written permission from the author.

For licensing inquiries: s.bagomri@gmail.com

## Contact

**Saleh Bagomri**
https://www.bagomri.com
s.bagomri@gmail.com
github.com/salehbagomri
