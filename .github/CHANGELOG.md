# CHANGELOG

All notable changes to the re-usable actions and workflows of this project are documented in this file.

The containers have their own [changelog](../CHANGELOG.md).
This project adheres to [Semantic Versioning](https://semver.org/).

## [2.3.1](https://github.com/philips-software/amp-devcontainer/compare/actions/v2.3.0...actions/v2.3.1) (2026-11-11)


### Bug Fixes

* Don't require sudo to update vscode extensions ([#1561](https://github.com/philips-software/amp-devcontainer/issues/1561)) ([34b1825](https://github.com/philips-software/amp-devcontainer/commit/34b18250a7edd7cce30b6a26e4f4f58f639def7b))


### Chores

* Pin node minimum ([#1553](https://github.com/philips-software/amp-devcontainer/issues/1553)) ([307cb26](https://github.com/philips-software/amp-devcontainer/commit/307cb26ec21b54d0e5ef6159aab45713a08676fc))

## [2.3.0](https://github.com/philips-software/amp-devcontainer/compare/actions/v2.2.0...actions/v2.3.0) (2026-11-10)


### Features

* Implement reusable release notes workflow ([#1549](https://github.com/philips-software/amp-devcontainer/issues/1549)) ([b13c71f](https://github.com/philips-software/amp-devcontainer/commit/b13c71f307daf8bca1e5086605db1e438ca1049f))


### Bug Fixes

* Verify attestations with the signing workflow ([#1552](https://github.com/philips-software/amp-devcontainer/issues/1552)) ([01645d1](https://github.com/philips-software/amp-devcontainer/commit/01645d126f4ad2b3d3f7caaddf2948b96bb148ed))

## [2.2.0](https://github.com/philips-software/amp-devcontainer/compare/actions/v2.1.0...actions/v2.2.0) (2026-11-10)


### Features

* Make release template rendering reusable ([#1537](https://github.com/philips-software/amp-devcontainer/issues/1537)) ([1b19c11](https://github.com/philips-software/amp-devcontainer/commit/1b19c11108ed39f4731945aa94c3497dbdf4289a))


### Chores

* Automate release notes summary ([#1541](https://github.com/philips-software/amp-devcontainer/issues/1541)) ([199b208](https://github.com/philips-software/amp-devcontainer/commit/199b208523f91f921d26b30d119c20ebea0014e6))
* Make render release notes idempotent ([#1540](https://github.com/philips-software/amp-devcontainer/issues/1540)) ([c001fa1](https://github.com/philips-software/amp-devcontainer/commit/c001fa15407bed0713106adcf37a1e2cf0d8902a))

## [2.1.0](https://github.com/philips-software/amp-devcontainer/compare/actions/v2.0.0...actions/v2.1.0) (2026-11-05)


### Features

* Add GitHub cli ([#1517](https://github.com/philips-software/amp-devcontainer/issues/1517)) ([740a93b](https://github.com/philips-software/amp-devcontainer/commit/740a93bac7764aeb17adf20dc069ba1184187930))


### Chores

* Update node version in actions ([#1515](https://github.com/philips-software/amp-devcontainer/issues/1515)) ([beb625c](https://github.com/philips-software/amp-devcontainer/commit/beb625ce65b07e1cdee2157bd08505c42519820c))

## [2.0.0](https://github.com/philips-software/amp-devcontainer/compare/actions/v1.2.0...actions/v2.0.0) (2026-10-26)


### ⚠ BREAKING CHANGES

* add code container user to replace root ([#1501](https://github.com/philips-software/amp-devcontainer/issues/1501))

### Features

* Add code container user to replace root ([#1501](https://github.com/philips-software/amp-devcontainer/issues/1501)) ([adf549b](https://github.com/philips-software/amp-devcontainer/commit/adf549ba6b0df1cdab12789e91e90cc54979eb8c))


### Chores

* Fix sonarqube findings ([#1505](https://github.com/philips-software/amp-devcontainer/issues/1505)) ([66681b4](https://github.com/philips-software/amp-devcontainer/commit/66681b43ace8a0ae5869f9fdde32dd05f62f1ea1))

## [1.2.0](https://github.com/philips-software/amp-devcontainer/compare/actions-v1.1.0...actions/v1.2.0) (2026-09-07)


### Features

* Group vs code extension updates in a single pull request ([#1439](https://github.com/philips-software/amp-devcontainer/issues/1439)) ([4f484e4](https://github.com/philips-software/amp-devcontainer/commit/4f484e4803400ea43e72cb1fcc7dbc8ccd33b23a))

## [1.1.0](https://github.com/philips-software/amp-devcontainer/compare/actions-v1.0.0...actions-v1.1.0) (2026-07-22)


### Features

* Extract common base image ([#1078](https://github.com/philips-software/amp-devcontainer/issues/1078)) ([30b2726](https://github.com/philips-software/amp-devcontainer/commit/30b272633d3f05f22e8fbce516ba6e8fb19f27d1))
* Release .github/actions independent from the containers ([#1376](https://github.com/philips-software/amp-devcontainer/issues/1376)) ([3f6a8f2](https://github.com/philips-software/amp-devcontainer/commit/3f6a8f22bb74295932956d9d080e8848727f2069))


### Bug Fixes

* Capture re-usable workflows as actions instead of scripts ([#1374](https://github.com/philips-software/amp-devcontainer/issues/1374)) ([3c233cd](https://github.com/philips-software/amp-devcontainer/commit/3c233cde76790ff021d53a843501c7503652f665))
* Container size diff merge issues ([#930](https://github.com/philips-software/amp-devcontainer/issues/930)) ([5d03602](https://github.com/philips-software/amp-devcontainer/commit/5d03602a1295b13c4109b7d51df17d3a9fb8259e))
* Don't checkout in generate-tool-inventory ([#1377](https://github.com/philips-software/amp-devcontainer/issues/1377)) ([2582be9](https://github.com/philips-software/amp-devcontainer/commit/2582be9ee414a3351f540484780e81bb20073907))
* Exclude release details when no github url is found ([#903](https://github.com/philips-software/amp-devcontainer/issues/903)) ([813ac63](https://github.com/philips-software/amp-devcontainer/commit/813ac63e04235adfab402180deb5dc29793a66e8))
* Resolve sonarqube security findings ([#1373](https://github.com/philips-software/amp-devcontainer/issues/1373)) ([a18bcf8](https://github.com/philips-software/amp-devcontainer/commit/a18bcf8b3ab78cd398193ef190c1f72992d3a700))


### Chores

* Image build improvements ([#833](https://github.com/philips-software/amp-devcontainer/issues/833)) ([62a2660](https://github.com/philips-software/amp-devcontainer/commit/62a2660e8995a9fda8793c4937bd1de7c727e584))
* Refactor ci and versioning scheme ([#815](https://github.com/philips-software/amp-devcontainer/issues/815)) ([93b6593](https://github.com/philips-software/amp-devcontainer/commit/93b65936545deefa54d06515eab5a9e021f8be76))
