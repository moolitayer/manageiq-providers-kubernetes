# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)


## Unreleased as of Sprint 71 ending 2017-10-16

### Added
- Adding cve_url and image_tag to global image_inspector settings [(#120)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/120)
- Prometheus alerts [(#40)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/40)

## Unreleased as of Sprint 70 ending 2017-10-02

### Added
- Image scanning: Add image name to task name [(#105)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/105)

### Fixed
- Prefix ems_ref with object type in event hash [(#123)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/123)
- Dont return an empty set when something goes wrong [(#122)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/122)
- Fail on creating scanning job with image instance [(#119)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/119)
- Fix net_usage_rate_average units [(#118)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/118)
- Enable graph refresh (batch strategy) by default [(#112)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/112)
- Scanning::Job always cleanup all signals in cleanup [(#99)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/99)
- Convert quotas to numeric values [(#69)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/69)

## Unreleased as of Sprint 69 ending 2017-09-18

### Fixed
- Add mising metrics authentication [(#109)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/109)

## Unreleased as of Sprint 68 ending 2017-09-04

### Added
- Add prometheus capture context [(#71)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/71)
- Option needed for new ems_refresh.openshift.store_unused_images setting [(#11)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/11)

### Fixed
- Container Template: convert params to hashes [(#97)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/97)
- Skip invalid container_images [(#94)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/94)
- Add ContainerImage raise event post processing job [(#77)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/77)

## Unreleased as of Sprint 67 ending 2017-08-21

### Fixed
- Remove seemingly unnecessary ignoring of SIGTERM [(#96)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/96)

### Added
- Remove use_ar_object to speedup the saving [(#88)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/88)
- Update Hawkular version [(#56)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/56)

## Unreleased as of Sprint 66 ending 2017-08-07

### Fixed
- Fix fallouts from ContainerTemplate STI [(#81)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/81)

### Added
- Using the new options for image-scanning options [(#45)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/45)
- Collect container definition limits [(#22)](https://github.com/ManageIQ/manageiq-providers-kubernetes/pull/22)