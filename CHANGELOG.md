# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-04-20

### Changed
- Use new permission management API 1.6 calls

## [1.1.0] - 2025-08-01

### Added
- Added special function to set an access token externaly. For debugging purposes only.

## [1.0.1] - 2023-06-05

### Fixed
- Fixed loading of custom logo when using the SDK via SPM/CocoaPods

## [1.0.0] - 2023-02-19

### Added
- Project setup
- Integration of AppAuth library
- NetIdService and related API functions
- AppAuthManager for the library authentication communication  
- Authorization UI 
- Necessary App2App utilities 
- Permission management webservices
- Permission management API functions
- Authorization View for Soft Login
- Hard- and SoftLogin option 
- Possibility to transfer claims via the sdk interface
- Preparations for using UniversalLinks
- Added added third flow combining permission and login
- Added possibility to change certain strings/logos in permission and login flow layers
- Added possibility to get back buttons to build an own authorization dialog
- Added LSApplicationQueriesSchemes in Info.plist
- Added demo app for button worflow
- Documented some functions

### Changed
- Added more information to user info
- Renamed hard/soft-flows to login/permission-flows
- Changed to new design
- Removed deprecated variable
- Do not display empty values in userinfo
- Integrated UI feedback
- Allow for empty/missing items in JSON
- Removed host/broker from config
- Make sub items of optinal items optional
- Use userinfo endpoint from discovery document
- Get rid of copy of id token
- Small cleanups
- Small ui fixes
- Can set TC String and IDConsent seperately now
- Reworked error handling
- More documentation
- Removed unused function
- claims is now a simple string on the external interface
- Change schemas for id apps
- Make use of new redirectUrl and host
- Updated resources
- Changed minimum iOS version to 14
- Removed unused plattform macos
- Added flexible bundle handling

### Fixed
- Url schemes error
- Corrected url for UniversalLinks
- Fixed a bug with different scopes for different flows
- Fixed a bug when using login flow with permission
- Fixed a bug when some claims were missing
- Make get/update permission possible in permission flow
- Fixed an edge case when resuming a session
- Fixed app2app redirect


