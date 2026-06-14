# Changelog

All notable changes to Mahrah Blood Bank are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [1.0.3] - 2026-04-20

### Added
- Cloudflare Worker reverse proxy for Supabase connectivity in environments where
  Supabase domains are restricted (emergency fix for Yemen)
- In-app mandatory update flow via the Google Play In-App Update API
- Comprehensive unit and widget test suite

### Changed
- Connectivity check now targets the Cloudflare Worker URL, eliminating false
  offline detection caused by direct Supabase domain checks
- Search screen simplified: auto-search triggers on district and blood type
  selection; text search and availability toggle removed

### Fixed
- App stuck on splash screen due to conflicting `home` and `onGenerateRoute`
  configuration in MaterialApp
- WhatsApp message text direction
- `mailto:` launch logic on the contact screen

## [1.0.2] - 2026-03-06

### Added
- Page transitions with smooth animations
- Shimmer loading states across list views
- Animated statistics counters on the home screen

### Changed
- About screen redesigned with updated layout and copyright year
- Search screen: auto-search by district and blood type; removed manual text
  search and availability filter toggle

### Fixed
- App stuck on splash screen (initial fix; fully resolved in 1.0.3)
- WhatsApp text direction and mailto launch logic on contact screen

## [1.0.1] - 2026-03-02

### Added
- Named route navigation via a centralized `AppRouter`
- Service locator dependency injection with GetIt
- Offline mode: Hive-based cache for donor data with connectivity monitoring
- Enhanced search screen with blood type chips and advanced filters

### Changed
- Performance improvements across list rendering and state updates
- Security hardening: Supabase credentials moved to `--dart-define` build-time
  injection with no hard-coded fallbacks in production builds

## [1.0.0] - 2025-12-05

### Added
- Initial public release
- Blood donor registry for Al-Mahrah Governorate (9 districts)
- Public donor search by blood type and district
- Direct donor contact via phone call and WhatsApp
- Blood donation awareness content with carousel
- Donor report submission (invalid or unreachable numbers)
- Hospital administration dashboard: manage donors, advanced search,
  suspension tracking, blood type and district reports
- Data export as Excel spreadsheets and PDF reports
- System administrator dashboard: hospital management, report review,
  system-wide statistics
- Firebase Crashlytics integration for production error tracking
- Row-Level Security (RLS) policies enforcing role-based data access
- IBM Plex Sans Arabic typography

[Unreleased]: https://github.com/salehbagomri/mahrah_blood_bank_app/compare/v1.0.3...HEAD
[1.0.3]: https://github.com/salehbagomri/mahrah_blood_bank_app/compare/v1.0.2...v1.0.3
[1.0.2]: https://github.com/salehbagomri/mahrah_blood_bank_app/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/salehbagomri/mahrah_blood_bank_app/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/salehbagomri/mahrah_blood_bank_app/releases/tag/v1.0.0
