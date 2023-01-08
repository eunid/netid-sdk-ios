# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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

### Fixed
- Url schemes error
- Corrected url for UniversalLinks
- Fixed a bug with different scopes for different flows
- Fixed a bug when using login flow with permission
- Fixed a bug when some claims were missing
- Make get/update permission possible in permission flow
- Fixed an edge case when resuming a session
- Fixed app2app redirect

