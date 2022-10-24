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

### Changed
- Added more information to user info
- Renamed hard/soft-flows to login/permission-flows
- Changed to new design

### Fixed
- Url schemes error
- Corrected url for UniversalLinks
- Fixed a bug with different scopes for different flows

